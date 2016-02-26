//
//  EZWindowFunctions.m
//  EZAudio
//
//  Created by Sam Bender on 12/3/15.
//  Copyright © 2015 Andrew Breckenridge. All rights reserved.
//

#import "EZAudioWindowFunctions.h"

@implementation EZAudioWindowFunctions

+ (void) gaussianWindow:(float*)buffer length:(UInt32)length
{
    float factor;
    float n;
    float lengthOverTwo = length / 2;
    for (float i = 0; i < length; i++)
    {
        n = i - lengthOverTwo;
        factor = powf(M_E, (- 96 * (n * n)) / (2 * length * length));
        
        int intI = (int)i;
        buffer[intI] = 1.0 * factor;
    }
}

@end
