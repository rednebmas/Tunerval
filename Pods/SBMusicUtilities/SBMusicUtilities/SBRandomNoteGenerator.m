//
//  RandomNoteGenerator.m
//  Pitch
//
//  Created by Sam Bender on 1/17/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <SBMusicUtilities/SBNote.h>
#import "SBRandomNoteGenerator.h"

@interface SBRandomNoteGenerator()

@property (nonatomic, retain) SBNote *fromNote;
@property (nonatomic, retain) SBNote *toNote;

@end

@implementation SBRandomNoteGenerator

- (void) setRangeFrom:(SBNote*)fromNote to:(SBNote*)toNote
{
    if (toNote.frequency < fromNote.frequency)
    {
        [NSException raise:@"Note range is negative" format:@""];
    }
    
    self.fromNote = fromNote;
    self.toNote = toNote;
}

- (SBNote*) nextNote
{
    return [self nextNoteWithinRangeForInterval:0];
}

- (SBNote*) nextNoteWithinRangeForInterval:(IntervalType)interval
{
    int range = self.toNote.halfStepsFromA4 - self.fromNote.halfStepsFromA4;
    if (range < interval) {
        NSLog(@"<<WARNING>> in nextNoteWithinRangeForInterval: interval was greater than range");
    }
    
    int lowerBound = 0;
    int upperBound = range;
    
    if (interval > 0)
    {
        upperBound -= (int)interval;
    }
    else
    {
        lowerBound = abs((int)interval);
    }
    
    int rndValue;
    if (upperBound - lowerBound == 0)
    {
        rndValue = 0;
    }
    else
    {
        rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
    }
    
    SBNote *note = [self.fromNote noteWithDifferenceInHalfSteps:rndValue];

    return note;
}

@end
