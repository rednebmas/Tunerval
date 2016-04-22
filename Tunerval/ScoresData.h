//
//  ScoresData.h
//  Tunerval
//
//  Created by Sam Bender on 3/19/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SBMusicUtilities/SBNote.h>

@interface ScoresData : NSObject

// An array of dictionaries which represent a score
@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) NSArray *dataYVals;

- (void) loadDataForInterval:(IntervalType)interval afterUnixTimestamp:(double)timestamp;
- (void) loadRunningAverageDifficultyAfterUnixTimeStamp:(double)timestamp;

@end
