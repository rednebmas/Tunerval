//
//  SBPlayableNote.h
//  Pitch
//
//  Created by Sam Bender on 1/17/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "SBNote.h"

@class EZAudioFile;

@interface SBPlayableNote : SBNote

@property (nonatomic, readwrite) double frequency;
@property (nonatomic, readonly) BOOL bufferInitialized;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) int waitFrames;
@property (nonatomic) double positionInSineWave;
@property (nonatomic) NSInteger durationInFramesLeft;
@property (nonatomic, readonly) NSInteger durationInFrames;
@property (nonatomic) double thetaIncrement;
@property (nonatomic, retain) NSDate *toneStart;
@property (nonatomic, retain) EZAudioFile *audioFile;

- (BOOL) sampleExists;
+ (void) setSamplesBaseFilePath:(NSString*)baseFilePath;
- (void) loadAudioFile;
- (void) initializeAudioBufferListWithChannelsPerFrame:(UInt32)channelsPerFrame
                                           interleaved:(BOOL)interleaved
                                         bytesPerFrame:(UInt32)bytesPerFrame
                                        capacityFrames:(UInt32)capacityFrames;
/*
 * Reads new frames into audio buffer list.
 * @returns true if End Of File (EOF, there are no frames left to read).
 */
- (BOOL) readIntoAudioBufferList:(AudioBufferList*)intoAudioBufferList
               forNumberOfFrames:(UInt32)numberOfFrames;


//
// Class methods
//

+ (AudioBufferList*) createAudioBufferListWithChannelsPerFrame:(UInt32)channelsPerFrame
                                                   interleaved:(BOOL)interleaved
                                                 bytesPerFrame:(UInt32)bytesPerFrame
                                                capacityFrames:(UInt32)capacityFrames;

@end
