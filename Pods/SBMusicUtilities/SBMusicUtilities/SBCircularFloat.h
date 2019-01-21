//
//  SBCircularFloat.h
//  PitchEstimation
//
//  Created by Sam Bender on 12/16/15.
//  Copyright © 2015 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBCircularFloat : NSObject

@property (nonatomic, readonly) float average;

- (id) initWithSize:(NSUInteger)size;
- (void) addValue:(float)value;

@end
