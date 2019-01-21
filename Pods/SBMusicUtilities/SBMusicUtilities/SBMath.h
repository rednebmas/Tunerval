//
//  SBMath.h
//  PitchEstimation
//
//  Created by Sam Bender on 11/26/15.
//  Copyright © 2015 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct FloatRange {
    float start;
    float end;
} FloatRange;

@interface SBMath : NSObject

+ (BOOL) value:(double)value withinTolerance:(double)tolerance ofProjected:(double)projected;
/*
 * This will return different results than Objective-C's built in modulus for negative numbers
 *
 * http://www.mathworks.com/help/matlab/ref/mod.html
 * b = mod(a,m) returns the remainder after division of a by m, where a is the dividend and m is the divisor. This function is often called the modulo operation and is computed using b = a - m.*floor(a./m). The mod function follows the convention that mod(a,0) returns a.
 */
+ (float) matlabModulus:(float)a of:(float)m;
+ (float) meanOf:(float*)values ofSize:(UInt32)size;
+ (double) meanOfDouble:(double*)values ofSize:(UInt32)size;
+ (float) standardDeviationOf:(float*)values ofSize:(UInt32)size;
+ (float) convertValue:(float)value inRangeToNormal:(FloatRange)range;
+ (float) convertValue:(float)value inRangeToNormalLogarithmicValue:(FloatRange)range;

@end
