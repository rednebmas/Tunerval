//
//  NotePickerView.m
//  Tunerval
//
//  Created by Sam Bender on 3/1/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <PitchEstimator/SBNote.h>
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
    NSArray *noteNames = [SBNote noteNames];
    
    for (int octave = 1; octave < 8; octave++)
    {
        NSString *octaveString = [NSString stringWithFormat:@"%d", octave];
        for (NSString *note in noteNames)
        {
            NSAttributedString *str = [NSAttributedString attributedStringForText:note
                                                                     andSubscript:octaveString
                                                                     withFontSize:22.0];
            [self.notesAttributed addObject:str];
            [self.notes addObject:[NSString stringWithFormat:@"%@%@", note, octaveString]];
        }
    }
}

#pragma mark - Pickerview data source

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 12 * 7;
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
