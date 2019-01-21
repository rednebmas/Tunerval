//
//  AudioPlayer.h
//  PitchPerfect
//
//  Created by Sam Bender on 11/27/15.
//  Copyright © 2015 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EZAudio/EZAudio.h>

@class SBNote, SBPlayableNote;

@interface SBAudioPlayer : NSObject <EZOutputDataSource, EZAudioPlayerDelegate>

@property (nonatomic) float gain;
@property (nonatomic) float **micBuffer;
@property (nonatomic) BOOL micBufferFull;
@property (readonly, nonatomic, retain) NSMutableArray *notes;

+ (SBAudioPlayer*) sharedInstance;
- (void) play:(SBNote*)note;
- (void) playablePlay:(SBPlayableNote*)playableNote;
- (void) stop;

@end
