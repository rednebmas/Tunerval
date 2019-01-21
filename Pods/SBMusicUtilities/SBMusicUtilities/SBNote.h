//
//  SBNote.h
//  PitchEstimator
//
//  Created by Sam Bender on 12/24/15.
//  Copyright © 2015 Sam Bender. All rights reserved.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IntervalType) {
    IntervalTypeOctaveDescending            = -12,
    IntervalTypeMajorSeventhDescending      = -11,
    IntervalTypeMinorSeventhDescending      = -10,
    IntervalTypeMajorSixthDescending        = -9,
    IntervalTypeMinorSixthDescending        = -8,
    IntervalTypePerfectFifthDescending      = -7,
    IntervalTypeTritoneDescending           = -6,
    IntervalTypePerfectFourthDescending     = -5,
    IntervalTypeMajorThirdDescending        = -4,
    IntervalTypeMinorThirdDescending        = -3,
    IntervalTypeMajorSecondDescending       = -2,
    IntervalTypeMinorSecondDescending       = -1,
    IntervalTypeUnison                      = 0,
    IntervalTypeMinorSecondAscending        = 1,
    IntervalTypeMajorSecondAscending        = 2,
    IntervalTypeMinorThirdAscending         = 3,
    IntervalTypeMajorThirdAscending         = 4,
    IntervalTypePerfectFourthAscending      = 5,
    IntervalTypeTritoneAscending            = 6,
    IntervalTypePerfectFifthAscending       = 7,
    IntervalTypeMinorSixthAscending         = 8,
    IntervalTypeMajorSixthAscending         = 9,
    IntervalTypeMinorSeventhAscending       = 10,
    IntervalTypeMajorSeventhAscending       = 11,
    IntervalTypeOctaveAscending             = 12
};

typedef NS_ENUM(NSInteger, InstrumentType) {
    InstrumentTypeSineWave,
    InstrumentTypeRandom,
    InstrumentTypeSineWaveDrone,
    InstrumentTypePiano
};

@interface SBNote : NSObject
{
    @protected
    double _frequency;
}

// readonly
@property (nonatomic, readonly) int halfStepsFromA4;
@property (nonatomic, readonly) int octave;
@property (nonatomic, readonly) double frequency;
@property (nonatomic, retain, readonly) NSString *nameWithOctave;
@property (nonatomic, retain, readonly) NSString *nameWithoutOctave;
@property (nonatomic, retain, readonly) SBNote *transposed;

@property (nonatomic) int transpose; // half steps to transpose
@property (nonatomic) double duration;
@property (nonatomic) double loudness;
// changing this will change the frequency, but not the note name
@property (nonatomic) double centsOff;
@property (nonatomic) InstrumentType instrumentType;
@property (nonatomic, retain) NSString *title;

+ (id) noteWithFrequency:(double)frequency;
+ (id) noteWithName:(NSString*)name;
- (id) initWithFrequency:(double)frequency;
- (id) initWithName:(NSString*)name; // must include octave!
- (SBNote*) noteWithDifferenceInHalfSteps:(int)difference;
- (SBNote*) noteWithDifferenceInCents:(double)difference; // defaults to YES for adjust name
- (SBNote*) noteWithDifferenceInCents:(double)difference adjustName:(BOOL)adjustName;
- (BOOL)                   isNote:(SBNote*)note
      withinPitchToleranceInCents:(double)pitchTolerance
                    compareOctave:(BOOL)compareOctave;

//
// Class methods
//

// Default properties
+ (void) setDefaultInstrumenType:(InstrumentType)instrumentType;

// Musical math/constants
+ (NSArray*) noteNames;
+ (NSString*) instrumentNameForInstrumentType:(InstrumentType)instrumentType;
+ (NSString*) intervalTypeToDegree:(IntervalType)intervalType;
+ (NSString*) intervalTypeToIntervalName:(IntervalType)intervalType;
+ (NSArray*) ascendingIntervals;
+ (NSArray*) ascendingMajorIntervals;
+ (NSArray*) descendingIntervals;
+ (NSArray*) descendingIntervalsSmallestToLargest;
+ (NSDictionary*) intervalTypeToMajorSolfegeSymbol;
+ (NSString*) intervalTypeToIntervalShorthand:(IntervalType)intervalType;
+ (NSDictionary*) notesToMoveableDoForKey:(SBNote*)note;


@end
