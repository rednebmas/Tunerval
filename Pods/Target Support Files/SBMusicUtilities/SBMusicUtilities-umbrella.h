#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SBAudioPlayer.h"
#import "SBCircular.h"
#import "SBCircularFloat.h"
#import "SBMath.h"
#import "SBMusicUtilities.h"
#import "SBNote.h"
#import "SBPitchEstimator.h"
#import "SBPlayableNote.h"
#import "SBRandomNoteGenerator.h"

FOUNDATION_EXPORT double SBMusicUtilitiesVersionNumber;
FOUNDATION_EXPORT const unsigned char SBMusicUtilitiesVersionString[];

