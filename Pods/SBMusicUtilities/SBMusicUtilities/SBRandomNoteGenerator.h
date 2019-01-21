//
//  RandomNoteGenerator.h
//  Pitch
//
//  Created by Sam Bender on 1/17/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SBMusicUtilities/SBNote.h>

@interface SBRandomNoteGenerator : NSObject

@property (nonatomic, retain, readonly) SBNote *fromNote;
@property (nonatomic, retain, readonly) SBNote *toNote;

- (void) setRangeFrom:(SBNote*)fromNote to:(SBNote*)toNote;
// returns a note within the range
- (SBNote*) nextNote;
- (SBNote*) nextNoteWithinRangeForInterval:(IntervalType)interval;

@end
