//
//  ScoresData.h
//  Tunerval
//
//  Created by Sam Bender on 3/19/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PitchEstimator/SBNote.h>

@interface ScoresData : NSObject

+ (NSArray*) difficultyDataForInterval:(IntervalType)interval;

@end
