//
//  Question.h
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PitchEstimator/SBNote.h>

@interface Question : NSObject

@property (nonatomic, retain) SBNote *referenceNote;
@property (nonatomic, retain) SBNote *questionNote;
@property (nonatomic) IntervalType interval;

@end
