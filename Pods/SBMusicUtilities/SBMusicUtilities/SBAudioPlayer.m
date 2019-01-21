//
//  AudioPlayer.m
//  PitchPerfect
//
//  Created by Sam Bender on 11/27/15.
//  Copyright © 2015 Sam Bender. All rights reserved.
//

#import "SBAudioPlayer.h"
#import "SBPlayableNote.h"
#import <math.h>

#define SAMPLE_RATE 44100

@interface SBAudioPlayer()

@property (nonatomic) BOOL playForDuration;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL tempBufferListAllocated;
@property (nonatomic) AudioBufferList *tempAudioBufferList;
// consists of SBPlayableNotes
@property (readwrite, nonatomic, retain) NSMutableArray *notes;
@property (nonatomic, retain) NSMutableArray *persistentDiscardNotes;

@end

@implementation SBAudioPlayer

#pragma mark - Initialization

- (id) init
{
    self = [super init];
    if (self)
    {
        self.notes = [[NSMutableArray alloc] init];
        self.persistentDiscardNotes = [[NSMutableArray alloc] init];
        self.gain = 0.9;
    }
    return self;
}

+ (SBAudioPlayer*) sharedInstance
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
        
        //
        // Turns on output if mute switch is off
        //
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error;
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error)
        {
            NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
        }
        [session setActive:YES error:&error];
        if (error)
        {
            NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
        }
    });
    return sharedInstance;
}

- (void) dealloc
{
    if (self.tempBufferListAllocated)
    {
        free(self.tempAudioBufferList);
    }
}

#pragma mark - Public

- (void) play:(SBNote*)note
{
    if (note == nil)
    {
        NSLog(@"Warning: play:(SBNote*)note, note was nil");
        return;
    }
    
    SBPlayableNote *playableNote = [[SBPlayableNote alloc] initWithName:note.nameWithOctave];
    playableNote.instrumentType = note.instrumentType;
    playableNote.duration = note.duration;
    playableNote.loudness = note.loudness;
    playableNote.centsOff = note.centsOff;
    playableNote.frequency = note.frequency;
    [self playablePlay:playableNote];
}

- (void) playablePlay:(SBPlayableNote*)playableNote
{
    if (playableNote == nil)
    {
        NSLog(@"Warning: play:(SBPlayableNote*)note, note was nil");
        return;
    }
    
    playableNote.toneStart = [NSDate date];
    if (playableNote.instrumentType == InstrumentTypePiano)
    {
        [playableNote loadAudioFile];
    }
    
    NSLog(@"<AudioPlayer> Add note (%@) to notes", playableNote);
    [self.notes addObject:playableNote];
    
    if (self.isPlaying == NO)
    {
        [self startOutput];
    }
}

- (void) stop
{
    if (self.notes != nil)
    {
        [self.notes removeAllObjects];
    }
    else
    {
        NSLog(@"Called 'stop' on AudioPlayer when there was nothing playing.");
    }
    
    self.isPlaying = NO;
    
    [[EZOutput sharedOutput] stopPlayback];
}

#pragma mark - Private

- (void) startOutput
{
    self.isPlaying = YES;
    
    EZOutput *sharedOutput = [EZOutput sharedOutput];
    if ([sharedOutput isPlaying])
    {
        NSLog(@"Warning: called startOutput when audio was already playing");
        return;
    }
    
    SBPlayableNote *note = self.notes[0];
    if (note.instrumentType == InstrumentTypePiano)
    {
        [sharedOutput setInputFormat:note.audioFile.clientFormat];
    }
    [sharedOutput setDataSource:self];
    [sharedOutput startPlayback];
}

- (OSStatus)        output:(EZOutput *)output
 shouldFillAudioBufferList:(AudioBufferList *)audioBufferList
        withNumberOfFrames:(UInt32)frames
                 timestamp:(const AudioTimeStamp *)timestamp
{
    /**
     * The following code fills the audio buffer list with the notes in the note array.
     */
    Float32 *bufferLeft = audioBufferList->mBuffers[0].mData;
    Float32 *bufferRight = audioBufferList->mBuffers[1].mData;
    
    // we have to clear the audio bufferlist because if we read a file in and the number of frames
    // is less than the size of the audio bufferlist then those ending frames will be added to
    // resulting in values greater than 1.0 or less than -1.0
    vDSP_vclr(bufferLeft, 1, frames);
    vDSP_vclr(bufferRight, 1, frames);
    
    if (self.micBufferFull)
    {
//        for (int i = 0; i < frames; i++)
//        {
//            bufferLeft[i] = 1.5 * self.micBuffer[0][i];
//            bufferRight[i] = 1.5 * self.micBuffer[0][i];
//        }
        self.micBufferFull = NO;
    }
    
    for (int i = 0; i < self.notes.count; i++)
    {
        SBPlayableNote *note = self.notes[i];
        
        if (note.waitFrames != 0)
        {
            note.waitFrames--;
            continue;
        }
        
        if (note.instrumentType == InstrumentTypeSineWave)
        {
            for (int frame = 0; frame < frames; frame++)
            {
                if (note.durationInFramesLeft <= 0)
                {
                    continue;
                }
                
                //
                // I bet casting to float fixes this problem. oh god.
                //
                Float32 value = (Float32)(sin(note.positionInSineWave) * note.loudness);
                
                // prevents the clicking sound at end of a note
                static const NSInteger fadeOutFrames = 300;
                static const NSInteger fadeInFrames = 500; // 500
                NSInteger framesUsed = note.durationInFrames - note.durationInFramesLeft; // 0 index
                if (note.durationInFramesLeft <= fadeOutFrames)
                {
                    ///////// frames left             ///  total frames
                    value *= (Float32)(note.durationInFramesLeft) / (Float32)(fadeOutFrames);
                }
                else if (framesUsed < fadeInFrames) // fade in
                {
                    value *= (Float32)(framesUsed) / (Float32)(fadeInFrames);
                }
                
                bufferLeft[frame] += value;
                bufferRight[frame] += value;
                note.positionInSineWave += note.thetaIncrement;
                note.durationInFramesLeft--;
            }
            
            if (note.durationInFramesLeft == 0)
            {
                [self.persistentDiscardNotes addObject:note];
            }
        }
        else if (note.instrumentType == InstrumentTypePiano)
        {
            UInt32 bufferSize; // amount of frames actually read
            BOOL eof; // end of file
            
            BOOL interleaved = [EZAudioUtilities isInterleaved:note.audioFile.clientFormat];
            if (interleaved)
            {
                NSLog(@"WARNING: audio file client format is interleaved");
            }
            
            // make sure we've allocated our temp bufferlist
            if (self.tempBufferListAllocated == NO)
            {
                UInt32 bytesPerFrame = note.audioFile.clientFormat.mBytesPerFrame;
                UInt32 channelsPerFrame = note.audioFile.clientFormat.mChannelsPerFrame;
                self.tempAudioBufferList = [SBPlayableNote
                                            createAudioBufferListWithChannelsPerFrame:channelsPerFrame
                                            interleaved:interleaved
                                            bytesPerFrame:bytesPerFrame
                                            capacityFrames:frames];
            }
            
            if (note.bufferInitialized == NO)
            {
                UInt32 bytesPerFrame = note.audioFile.clientFormat.mBytesPerFrame;
                UInt32 channelsPerFrame = note.audioFile.clientFormat.mChannelsPerFrame;
                [note initializeAudioBufferListWithChannelsPerFrame:channelsPerFrame
                                                        interleaved:interleaved
                                                      bytesPerFrame:bytesPerFrame
                                                     capacityFrames:frames];
            }
            
            // for some reason if we don't do this we get an error, something to do with mp3
            // maybe
            SInt64 diff = note.audioFile.totalFrames - note.audioFile.frameIndex;
            
            // if (diff > 0)
            {
                // clear temp buffer first
                Float32 *tempBufferLeft = self.tempAudioBufferList->mBuffers[0].mData;
                Float32 *tempBufferRight = self.tempAudioBufferList->mBuffers[1].mData;
                vDSP_vclr(tempBufferLeft, 1, frames);
                vDSP_vclr(tempBufferRight, 1, frames);
                
                //
                // Read in to temporary buffer list
                //
                /*
                [note.audioFile readFrames:frames
                           audioBufferList:self.tempAudioBufferList
                                bufferSize:&bufferSize
                                       eof:&eof];
                 */
                eof = [note readIntoAudioBufferList:self.tempAudioBufferList
                            forNumberOfFrames:frames];
                
                //
                // Add to output buffer list
                //
                vDSP_vadd(bufferLeft, 1, tempBufferLeft, 1, bufferLeft, 1, frames);
                vDSP_vadd(bufferRight, 1, tempBufferRight, 1, bufferRight, 1, frames);
            }
            /* else
            {
                eof = YES;
            } */
            
            // reset temporary bufferlist size
            // http://stackoverflow.com/a/23579336/337934
            AudioBuffer *buffer;
            for(int j = 0; j < self.tempAudioBufferList->mNumberBuffers; j++)
            {
                buffer = &( self.tempAudioBufferList->mBuffers[ j ] );
                buffer->mDataByteSize = audioBufferList->mBuffers[0].mDataByteSize;
            }
            
            // remove note if we are done
            if (eof)
            {
                [self.persistentDiscardNotes addObject:note];
            }
        }
    }
    
    if (self.persistentDiscardNotes.count > 0)
    {
        [self.notes removeObjectsInArray:self.persistentDiscardNotes];
        [self.persistentDiscardNotes removeAllObjects];
    }
    
    if (self.notes.count == 0)
    {
         // [self stop];
    }
    
    // apply gain
    if (self.gain != 1.0)
    {
        vDSP_vsmul ( bufferLeft, 1, &_gain, bufferLeft, 1, frames);
        vDSP_vsmul ( bufferRight, 1, &_gain, bufferRight, 1, frames);
    }
    
    return noErr;
}

#pragma mark - Misc

// http://stackoverflow.com/a/3796721/337934
- (AudioBufferList*) createAudioBufferListWithChannelsPerFrame:(UInt32)channelsPerFrame
                                                   interleaved:(BOOL)interleaved
                                                 bytesPerFrame:(UInt32)bytesPerFrame
                                                capacityFrames:(UInt32)capacityFrames
{
    if (self.tempBufferListAllocated == YES)
    {
        free(self.tempAudioBufferList);
    }
    else
    {
        self.tempBufferListAllocated = YES;
    }
    
    AudioBufferList *bufferList = NULL;
    
    UInt32 numBuffers = interleaved ? 1 : channelsPerFrame;
    UInt32 channelsPerBuffer = interleaved ? channelsPerFrame : 1;
    
    bufferList = calloc(1, offsetof(AudioBufferList, mBuffers) + (sizeof(AudioBuffer) * numBuffers));
    
    bufferList->mNumberBuffers = numBuffers;
    
    for(UInt32 bufferIndex = 0; bufferIndex < bufferList->mNumberBuffers; ++bufferIndex) {
        bufferList->mBuffers[bufferIndex].mData = calloc(capacityFrames, bytesPerFrame);
        bufferList->mBuffers[bufferIndex].mDataByteSize = capacityFrames * bytesPerFrame;
        bufferList->mBuffers[bufferIndex].mNumberChannels = channelsPerBuffer;
    }
    
    return bufferList;
}

@end
