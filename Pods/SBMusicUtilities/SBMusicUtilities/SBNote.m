//
//  SBNote.m
//  PitchEstimator
//
//  Created by Sam Bender on 12/24/15.
//  Copyright © 2015 Sam Bender. All rights reserved.
//

#import "SBNote.h"

#define A4_FREQUENCY 440.00
#define TWO_TO_THE_ONE_OVER_TWELVE 1.059463094359295264561825294946341700779204317494185628559
// http://pianoandsynth.com/wp-content/uploads/2009/05/music-keyboard.gif
// based on noteNames constant
#define HALF_STEPS_AWAY_FROM_A4_TO_NOTE_IN_4TH_OCTAVE @[@-9, @-8, @-7, @-6, @-5, @-4, @-3, @-2, @-1, @0, @1, @2]
#define SAMPLE_RATE 44100.0f

#define LocalizedString(key) \
        [[SBNote bundle] localizedStringForKey:(key) value:@"" table:nil]

static NSMutableDictionary *defaults;
static NSBundle *bundle;


@interface SBNote()

@property (nonatomic, readwrite) int halfStepsFromA4;
@property (nonatomic, readwrite) int octave;
@property (nonatomic, readwrite) double frequency;
@property (nonatomic, retain, readwrite) NSString *nameWithOctave;
@property (nonatomic, retain, readwrite) NSString *nameWithoutOctave;
@property (nonatomic, retain, readwrite) SBNote *transposed;

@end

@implementation SBNote

#pragma mark - Initialization

- (id) init
{
    self = [super init];
    if (self)
    {
        self.duration = 0.8;
        self.loudness = 1.0;
        _transpose = 0;
        
        InstrumentType instrumentType = [SBNote defaultInstrumentType];
        if (instrumentType == InstrumentTypeRandom)
        {
            // includes SineWaveDrone
            _instrumentType = 1 + arc4random() % 3;
        }
        else
        {
            _instrumentType = instrumentType;
        }
    }
    return self;
}

- (id) initWithFrequency:(double)frequency
{
    self = [self init];
    if (self)
    {
        _frequency = frequency;
        [self frequencyToNote:frequency];
    }
    return self;
}

- (id) initWithName:(NSString*)name
{
    self = [self init];
    if (self)
    {
        [self calculateFrequencyForNoteName:name];
    }
    return self;
}

/**
 * Class initializers
 */

+ (id) noteWithName:(NSString*)name
{
    return [[self alloc] initWithName:name];
}

+ (id) noteWithFrequency:(double)frequency
{
    return [[self alloc] initWithFrequency:frequency];
}

#pragma mark - Class defaults

+ (NSMutableDictionary*) defaults
{
    static dispatch_once_t defaultsOnceToken;
    dispatch_once(&defaultsOnceToken, ^{
        defaults = [SBNote defaultDefaults];
    });
    return defaults;
}

+ (NSMutableDictionary*) defaultDefaults
{
    return [@{
              @"instrumentType" : @0
              } mutableCopy];
}

+ (void) setDefaultInstrumenType:(InstrumentType)instrumentType
{
    NSNumber *instrumentTypeObj = [NSNumber numberWithInteger:instrumentType];
    [[SBNote defaults] setObject:instrumentTypeObj forKey:@"instrumentType"];
}

+ (InstrumentType) defaultInstrumentType
{
    return [[[SBNote defaults] objectForKey:@"instrumentType"] integerValue];
}

#pragma mark - Calculation methods

/**
 * Algorithm comes from a MATLAB script called freq2note
 */
- (void) frequencyToNote:(double)frequency
{
    if (frequency < 25.00)
    {
        return;
    }
    
    double centDiff = 1200 * log2(frequency / A4_FREQUENCY);
    double noteDiff = floor(centDiff / 100);
    
    double matlabModulus = centDiff - 100.0 * floor(centDiff / 100.0);
    if (matlabModulus > 50)
    {
        noteDiff = noteDiff + 1;
    }
    
    NSArray *noteNames = [SBNote noteNames];
    
    _centsOff = centDiff - noteDiff * 100;
    double noteNumber = noteDiff + 9 + 12 * 4;
    _octave = (int)floor((noteNumber)/12);
    int place = (int)fmod(noteNumber, 12) + 1;
    
    _nameWithOctave = [NSString stringWithFormat:@"%@%d", noteNames[place - 1], _octave];
    _nameWithoutOctave = [NSString stringWithFormat:@"%@", noteNames[place - 1]];
    
    _halfStepsFromA4 = [SBNote halfStepsFromA4FromNameWithoutOctave:_nameWithoutOctave
                                                              andOctave:_octave];
}

/**
 * Only takes octaves from 0 - 9
 * Does not support double flats or sharps
 */
- (void) calculateFrequencyForNoteName:(NSString*)name
{
    //
    // parse out name and octave
    //
    NSMutableString *letterName = [[NSMutableString alloc] init];
    int octave = 0;
    for (int i = 0; i < name.length; i++)
    {
        unichar charAtIndex = [name characterAtIndex:i];
        // unichar is a typealias for short int
        // in unicode, A is 0x41 and G is 0x47
        // # is 0x23, b is 0x62
        // 0 is 0x30, 9 is 0x39
        if ((charAtIndex >= 0x41 && charAtIndex <= 0x47)
            || charAtIndex == 0x23
            || charAtIndex == 0x62)
        {
            [letterName appendFormat:@"%C", charAtIndex];
        }
        else if (charAtIndex >= 0x30 && charAtIndex <= 0x39)
        {
            octave = [[NSString stringWithFormat:@"%C", charAtIndex] intValue];
            break;
        }
        else
        {
            [NSException raise:@"Invalid character exception" format:@"Invalid character while parsing note name: %@", name];
        }
    }
    
    self.octave = octave;
    self.nameWithOctave = name;
    self.nameWithoutOctave = [NSString stringWithFormat:@"%@", letterName];

    self.halfStepsFromA4 = [SBNote halfStepsFromA4FromNameWithoutOctave:self.nameWithoutOctave
                                                              andOctave:octave];
    _frequency = [SBNote frequencyForNoteWithHalfStepsFromA4:self.halfStepsFromA4];
}

- (BOOL)                   isNote:(SBNote*)note
      withinPitchToleranceInCents:(double)pitchTolerance
                    compareOctave:(BOOL)compareOctave
{
    BOOL sameName = [note.nameWithoutOctave isEqualToString:self.nameWithoutOctave];
    BOOL withinTolerance = fabs(note.centsOff) < pitchTolerance;
    
    return sameName && withinTolerance;
}

+ (int) halfStepsFromA4FromNameWithoutOctave:(NSString*)nameWithoutOctave andOctave:(int)octave
{
    // Note names need to not have enharmonics because we are using the index, so we must
    // check if the name without octave is a flat and convert it, otherwise index for object
    // will be not found.
    NSString *sharpToFlatConversion = [[self sharpToFlat] objectForKey:nameWithoutOctave];
    if (sharpToFlatConversion != nil)
    {
        nameWithoutOctave = sharpToFlatConversion;
    }
    
    int indexOfNoteName = (int)[[SBNote noteNames] indexOfObject:nameWithoutOctave];
    int halfStepsFromA4 = [HALF_STEPS_AWAY_FROM_A4_TO_NOTE_IN_4TH_OCTAVE[indexOfNoteName] intValue] + 12 * (octave - 4);
    
    return halfStepsFromA4;
}

/* CONFUSING METHOD NAME */
+ (double) frequencyForNoteWithHalfStepsFromA4:(int)halfStepsFromA4
{
    return A4_FREQUENCY * pow(TWO_TO_THE_ONE_OVER_TWELVE, halfStepsFromA4);
}

+ (double) frequencyForNoteFromA4InCents:(double)centsFromA4
{
    return A4_FREQUENCY * pow(TWO_TO_THE_ONE_OVER_TWELVE, centsFromA4 / 100.00);
}

#pragma mark - Setters

- (void) setTranspose:(int)transpose
{
    _transpose = transpose;
    
    if (transpose == 0)
    {
        self.transposed = nil;
        return;
    }
    
    double transposeFrequency = [SBNote frequencyForNoteWithHalfStepsFromA4:self.halfStepsFromA4 + transpose];
    self.transposed = [[SBNote alloc] initWithFrequency:transposeFrequency];
}

- (void)setCentsOff:(double)centsOff
{
    double centsFromA4 = (double)self.halfStepsFromA4 * 100.0 + centsOff;
    double newFrequency = [SBNote frequencyForNoteFromA4InCents:centsFromA4];
    _centsOff = centsOff;
    self.frequency = newFrequency;
}

#pragma mark - Misc

- (NSString*) description
{
    return [NSString stringWithFormat:@"%@ - %f Hz (%@%f cents), %.2fs, %@",
            self.nameWithOctave,
            self.frequency,
            self.centsOff < 0 ? @"" : @"+",
            self.centsOff,
            self.duration,
            [SBNote instrumentNameForInstrumentType:self.instrumentType]];
}

- (SBNote*) noteWithDifferenceInHalfSteps:(int)difference
{
    int newHalfStepsFromA4 = self.halfStepsFromA4 + difference;
    double newFrequency = [SBNote frequencyForNoteWithHalfStepsFromA4:newHalfStepsFromA4];
    SBNote *newNote = [[SBNote alloc] initWithFrequency:newFrequency];
    
    return newNote;
}

- (SBNote*) noteWithDifferenceInCents:(double)difference
{
    return [self noteWithDifferenceInCents:difference adjustName:YES];
}

- (SBNote*) noteWithDifferenceInCents:(double)difference adjustName:(BOOL)adjustName
{
    double centsFromA4 = (double)self.halfStepsFromA4 * 100.0 + difference;
    double newFrequency = [SBNote frequencyForNoteFromA4InCents:centsFromA4];
    
    SBNote *newNote;
    if (adjustName) {
        newNote = [[SBNote alloc] initWithFrequency:newFrequency];
    } else {
        // why? we want to use the sample for the note with this name
        newNote = [[SBNote alloc] initWithFrequency:self.frequency];
        newNote.centsOff = newNote.centsOff + difference;
    }
    
    return newNote;
}

#pragma mark - Misc class methods

+ (NSBundle*)bundle {
    // get bundle so we can localize
    if  (bundle == nil) {
        NSString *ourBunldeName = @"SBMusicUtilities.bundle";
        NSURL *frameworkURL = [[NSBundle bundleForClass:[SBNote class]] resourceURL];
        NSURL *bundleURL = [frameworkURL URLByAppendingPathComponent:ourBunldeName];
        bundle = [NSBundle bundleWithURL:bundleURL];
    }
    
    return bundle;
}

#pragma mark - Notation class methods

+ (NSArray*) noteNames
{
    static NSArray *_noteNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _noteNames = @[@"C", @"C#", @"D" , @"D#" , @"E" , @"F" , @"F#", @"G" , @"G#" , @"A" , @"A#" , @"B"];
    });
    return _noteNames;
}

+ (NSString*) instrumentNameForInstrumentType:(InstrumentType)instrumentType
{
    switch (instrumentType) {
        case InstrumentTypePiano:
            return @"Piano";
            
        case InstrumentTypeSineWave:
            return @"Sine Wave";
            
        default:
            return @"Unknown Instrument";
    }
}

+ (NSDictionary*) sharpToFlat
{
    static NSDictionary *_sharpToFlat;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharpToFlat = @{
                         @"Bb" : @"A#",
                         @"Eb" : @"D#",
                         @"Ab" : @"G#",
                         @"Db" : @"C#",
                         @"Gb" : @"F#",
                         @"Cb" : @"B",
                         @"Fb" : @"E"
                         };
    });
    return _sharpToFlat;
}

+ (NSDictionary*) intervalTypeToIntervalName
{
    static NSDictionary *_intervalTypeToName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _intervalTypeToName = @{
                                @0  : LocalizedString(@"Unison"),
                                @1  : LocalizedString(@"Minor Second"),
                                @2  : LocalizedString(@"Major Second"),
                                @3  : LocalizedString(@"Minor Third"),
                                @4  : LocalizedString(@"Major Third"),
                                @5  : LocalizedString(@"Perfect Fourth"),
                                @6  : LocalizedString(@"Tritone"),
                                @7  : LocalizedString(@"Perfect Fifth"),
                                @8  : LocalizedString(@"Minor Sixth"),
                                @9  : LocalizedString(@"Major Sixth"),
                                @10 : LocalizedString(@"Minor Seventh"),
                                @11 : LocalizedString(@"Major Seventh"),
                                @12 : LocalizedString(@"Octave")
                         };
    });
    return _intervalTypeToName;
}

+ (NSDictionary*) intervalTypeToIntervalShorthand
{
    static NSDictionary *_intervalTypeToShorthand;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _intervalTypeToShorthand = @{
                                     @0  : @"P1",
                                     @1  : @"m2",
                                     @2  : @"M2",
                                     @3  : @"m3",
                                     @4  : @"M3",
                                     @5  : @"P4",
                                     @6  : @"TT",
                                     @7  : @"P5",
                                     @8  : @"m6",
                                     @9  : @"M6",
                                     @10 : @"m7",
                                     @11 : @"M7",
                                     @12 : @"P8",
                                     };
    });
    return _intervalTypeToShorthand;
}

/**
 * Probably should be renamed to intervalTypeToMajorScaleDegree
 */
+ (NSDictionary*) intervalTypeToDegree
{
    static NSDictionary *_intervalTypeToDegree;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _intervalTypeToDegree = @{
                                @0  : @"One",
                                @2  : @"Two",
                                @4  : @"Three",
                                @5  : @"Four",
                                @7  : @"Five",
                                @9  : @"Six",
                                @11 : @"Seven",
                                @12 : @"Octave",
                                };
    });
    return _intervalTypeToDegree;
}

/**
 * https://en.wikipedia.org/wiki/Solf%C3%A8ge#Major
 */
+ (NSDictionary*) intervalTypeToMajorSolfegeSymbol
{
    static NSDictionary *_intervalTypeToName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _intervalTypeToName = @{
                                @0  : @"Do",
                                @1  : @"Ra",
                                @2  : @"Re",
                                @3  : @"Me",
                                @4  : @"Mi",
                                @5  : @"Fa",
                                @6  : @"Fi",
                                @7  : @"Sol",
                                @8  : @"Le",
                                @9  : @"La",
                                @10 : @"Te",
                                @11 : @"Ti",
                                @12 : @"Do",
                                };
    });
    return _intervalTypeToName;
}

+ (NSArray*) ascendingIntervals
{
    static NSArray *_ascendingIntervals;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ascendingIntervals = @[
                                [NSNumber numberWithInt:IntervalTypeMinorSecondAscending],
                                [NSNumber numberWithInt:IntervalTypeMajorSecondAscending],
                                [NSNumber numberWithInt:IntervalTypeMinorThirdAscending],
                                [NSNumber numberWithInt:IntervalTypeMajorThirdAscending],
                                [NSNumber numberWithInt:IntervalTypePerfectFourthAscending],
                                [NSNumber numberWithInt:IntervalTypeTritoneAscending],
                                [NSNumber numberWithInt:IntervalTypePerfectFifthAscending],
                                [NSNumber numberWithInt:IntervalTypeMinorSixthAscending],
                                [NSNumber numberWithInt:IntervalTypeMajorSixthAscending],
                                [NSNumber numberWithInt:IntervalTypeMinorSeventhAscending],
                                [NSNumber numberWithInt:IntervalTypeMajorSeventhAscending],
                                [NSNumber numberWithInt:IntervalTypeOctaveAscending]
                                ];
    });
    return _ascendingIntervals;
}

+ (NSArray*) ascendingMajorIntervals
{
    static NSArray *_ascendingMajorIntervals;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ascendingMajorIntervals = @[
                                [NSNumber numberWithInt:IntervalTypeUnison],
                                [NSNumber numberWithInt:IntervalTypeMajorSecondAscending],
                                [NSNumber numberWithInt:IntervalTypeMajorThirdAscending],
                                [NSNumber numberWithInt:IntervalTypePerfectFourthAscending],
                                [NSNumber numberWithInt:IntervalTypePerfectFifthAscending],
                                [NSNumber numberWithInt:IntervalTypeMajorSixthAscending],
                                [NSNumber numberWithInt:IntervalTypeMajorSeventhAscending],
                                [NSNumber numberWithInt:IntervalTypeOctaveAscending]
                                ];
    });
    return _ascendingMajorIntervals;
}

+ (NSArray*) descendingIntervals
{
    static NSArray *_descendingIntervals;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _descendingIntervals = @[
                                 [NSNumber numberWithInt:IntervalTypeOctaveDescending],
                                 [NSNumber numberWithInt:IntervalTypeMajorSeventhDescending],
                                 [NSNumber numberWithInt:IntervalTypeMinorSeventhDescending],
                                 [NSNumber numberWithInt:IntervalTypeMajorSixthDescending],
                                 [NSNumber numberWithInt:IntervalTypeMinorSixthDescending],
                                 [NSNumber numberWithInt:IntervalTypePerfectFifthDescending],
                                 [NSNumber numberWithInt:IntervalTypeTritoneDescending],
                                 [NSNumber numberWithInt:IntervalTypePerfectFourthDescending],
                                 [NSNumber numberWithInt:IntervalTypeMajorThirdDescending],
                                 [NSNumber numberWithInt:IntervalTypeMinorThirdDescending],
                                 [NSNumber numberWithInt:IntervalTypeMajorSecondDescending],
                                 [NSNumber numberWithInt:IntervalTypeMinorSecondDescending]
                                ];
    });
    return _descendingIntervals;
}

+ (NSArray*) descendingIntervalsSmallestToLargest
{
    static NSArray *_descendingIntervalsSmallestToLargest;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _descendingIntervalsSmallestToLargest = [[[SBNote descendingIntervals]
                                                  reverseObjectEnumerator] allObjects];
    });
    return _descendingIntervalsSmallestToLargest;
}

+ (NSString*) intervalTypeToDegree:(IntervalType)intervalType
{
    return [[SBNote intervalTypeToDegree] objectForKey:[NSNumber numberWithInt:intervalType]];
}

+ (NSString*) intervalTypeToIntervalName:(IntervalType)intervalType
{
    int intervalTypeInt = abs((int)intervalType);
    return [[SBNote intervalTypeToIntervalName] objectForKey:[NSNumber numberWithInt:intervalTypeInt]];
}

+ (NSString*) intervalTypeToIntervalShorthand:(IntervalType)intervalType
{
    int intervalTypeInt = abs((int)intervalType);
    return [[SBNote intervalTypeToIntervalShorthand] objectForKey:[NSNumber numberWithInt:intervalTypeInt]];
}

/**
 * Someday may just want to cache these results
 */
+ (NSDictionary*) notesToMoveableDoForKey:(SBNote*)note
{
    NSArray *noteNames = [SBNote noteNames];
    NSInteger startingIndex = [noteNames indexOfObject:note.nameWithoutOctave];
    NSDictionary *solfege = [SBNote intervalTypeToMajorSolfegeSymbol];
    
    NSMutableDictionary *notesToMoveableDo = [[NSMutableDictionary alloc] initWithCapacity:12];
    for (int i = 0; i < 12; i++)
    {
        NSInteger index = (startingIndex + i) % 12;
        NSString *note = [noteNames objectAtIndex:index];
        
        NSNumber *loopIndexNumber = [NSNumber numberWithInt:i];
        NSString *solfegeSymbol = [solfege objectForKey:loopIndexNumber];
        
        [notesToMoveableDo setObject:solfegeSymbol forKey:note];
    }
    
    return notesToMoveableDo;
}

@end
