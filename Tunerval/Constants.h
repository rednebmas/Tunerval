//
//  Constants.h
//  Tunerval
//
//  Created by Sam Bender on 3/10/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ALL_INTERVALS_VALUE -1000
#define MOBILE_ANALYTICS [AWSMobileAnalytics mobileAnalyticsForAppId:@"redacted" identityPoolId: @"redacted"]

/**
 * Allows us to say if (DEBUGMODE == YES)
 */
#ifdef DEBUG
#define DEBUGMODE YES
#else
#define DEBUGMODE NO
#endif

#define FORCE_RELOAD_ON_VIEW_WILL_APPEAR_KEY @"force_reload_on_view_will_appear"

@class FMDatabase;

@interface Constants : NSObject

+ (FMDatabase*) dbConnection;

@end
