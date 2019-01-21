//
//  SBMath.m
//  PitchEstimation
//
//  Created by Sam Bender on 11/26/15.
//  Copyright © 2015 Sam Bender. All rights reserved.
//

#import "SBMath.h"

@implementation SBMath

/*
 * http://stackoverflow.com/questions/19472747/convert-linear-scale-to-logarithmic
 */
+ (float) convertValue:(float)value inRangeToNormalLogarithmicValue:(FloatRange)range
{
    float k = 1/(log(range.end)-log(range.start));
    float c = -k * log(range.start);
    float result = k * log(value) + c;
    return result;
}

+ (float) convertValue:(float)value inRangeToNormal:(FloatRange)range
{
    float valueRange = range.end - range.start;
    float result = (range.start - value) / valueRange;
    return result;
}

+ (float) standardDeviationOf:(float*)values ofSize:(UInt32)size
{
    float mean = [SBMath meanOf:values ofSize:size];
    
    float sumOfMeanDifference = 0;
    for (int i = 0 ; i < size; i++)
    {
        sumOfMeanDifference += powf(values[i] - mean, 2);
    }
    
    float standardDeviation = sqrt(sumOfMeanDifference / (size - 1));
    return standardDeviation;
}

+ (float) meanOf:(float*)values ofSize:(UInt32)size
{
    float sum = 0;
    for (int i = 0 ; i < size; i++)
    {
        sum += values[i];
    }
    float mean = sum / (float)size;
    return mean;
}

+ (double) meanOfDouble:(double*)values ofSize:(UInt32)size
{
    double sum = 0;
    for (int i = 0 ; i < size; i++)
    {
        sum += values[i];
    }
    double mean = sum / (double)size;
    return mean;
}


+ (float) matlabModulus:(float)a of:(float)m
{
    return a - m * floorf(a / m);
}

+ (BOOL) value:(double)value withinTolerance:(double)tolerance ofProjected:(double)projected
{
    return value < projected + tolerance && value > projected - tolerance;
}

@end
