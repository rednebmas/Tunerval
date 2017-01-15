//
//  NotePickerView.m
//  Tunerval
//
//  Created by Sam Bender on 3/1/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <SBMusicUtilities/SBNote.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CoreText.h>
#import "NotePickerView.h"
#import "NSAttributedString+Utilities.h"

@interface NotePickerView()

@property (nonatomic, retain) NSMutableArray *notes;
@property (nonatomic, retain) NSMutableArray *notesAttributed;

@end

@implementation NotePickerView

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self generateNotes];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (void) generateNotes
{
    self.notesAttributed = [[NSMutableArray alloc] init];
    self.notes = [[NSMutableArray alloc] init];
    
    SBNote *E2 = [SBNote noteWithName:@"A1"]; // Lowest available is E2
    SBNote *C6 = [SBNote noteWithName:@"A6"]; // Highest available is C6
    SBNote *currentNote = [E2 noteWithDifferenceInHalfSteps:0];
    while (currentNote.halfStepsFromA4 <= C6.halfStepsFromA4) {
        NSString *octaveString = [NSString stringWithFormat:@"%d", currentNote.octave];
        NSAttributedString *str = [NSAttributedString attributedStringForText:currentNote.nameWithoutOctave
                                                                 andSubscript:octaveString
                                                                 withFontSize:22.0];
        [self.notesAttributed addObject:str];
        [self.notes addObject:currentNote.nameWithOctave];
        
        currentNote = [currentNote noteWithDifferenceInHalfSteps:1];
    }
}

#pragma mark - Pickerview data source

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.notesAttributed.count;
}

#pragma mark - Pickerview delegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel*)view;
    if (!label)
    {
        label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    // Fill the label text here
    [label setAttributedText:self.notesAttributed[row]];
    
    return label;
}

#pragma mark - Public

- (void) selectNote:(SBNote*)note animated:(BOOL)animated;
{
    NSString *noteName = [note nameWithOctave];
    NSInteger index = [self.notes indexOfObject:noteName];
    [self selectRow:index inComponent:0 animated:animated];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    SBNote *note = [SBNote noteWithName:[self.notesAttributed[row] string]];
    if (self.protocolReciever != nil)
    {
        [self.protocolReciever notePickerView:self pickedNote:note];
    }
}

@end
