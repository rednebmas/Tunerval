//
//  Question.h
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SBMusicUtilities/SBNote.h>

@interface Question : NSObject

@property (nonatomic, retain) SBNote *referenceNote;
@property (nonatomic, retain) SBNote *questionNote;
@property (nonatomic) IntervalType interval;


/**
 * You can only this call this once per instantiation
 */
- (void) markStartTime;

/**
 * You can only this call this once per instantiation
 */
- (void) logToDBWithUserAnswer:(int)userAnswer
                 correctAnswer:(int)correctAnswer
                    difficulty:(double)difficulty
                 noteRangeFrom:(int)noteRangeFrom
                   noteRangeTo:(int)noteRangeTo;

- (void)incrementOnIncorrectAnswerListens;

@end
