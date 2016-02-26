//
//  EZWindowFunctions.h
//  EZAudio
//
//  Created by Sam Bender on 12/3/15.
//  Copyright © 2015 Andrew Breckenridge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZAudioWindowFunctions : NSObject

+ (void) gaussianWindow:(float*)buffer length:(UInt32)length;

@end
