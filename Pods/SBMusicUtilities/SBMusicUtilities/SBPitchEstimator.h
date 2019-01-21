//
//  PitchEstimator.h
//  PitchEstimator
//
//  Created by Sam Bender on 12/23/15.
//  Copyright © 2015 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

#define RECOMMENDED_FFT_WINDOW_SIZE 4096 * 2

@class EZAudioFFTRolling;

@interface SBPitchEstimator : NSObject

@property (nonatomic, readonly) float loudness;
@property (nonatomic, readonly) float fundamentalFrequency;
@property (nonatomic, readonly) vDSP_Length fundamentalFrequencyIndex;
// delta frequency between bins
@property (nonatomic, readonly) float binSize;
@property (nonatomic) float *oneIfHarmonicOtherwiseZero;
@property (nonatomic, retain) NSString *debugString;

+ (float) loudness:(float**)buffer ofSize:(UInt32)size;

- (void) processAudioBuffer:(float**)buffer ofSize:(UInt32)size;
- (void) processFFT:(EZAudioFFTRolling*)fft withFFTData:(float*)fftData ofSize:(vDSP_Length)size;

@end
