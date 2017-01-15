//
//  PushNotificationHandler.h
//  Tunerval
//
//  Created by Sam Bender on 12/30/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationHandler : NSObject

+ (void) askForReminderFrom:(UIViewController*)viewController completion:(void(^)(BOOL accepted))completion;
+ (NSDate*) dateTomorrowForTime:(NSDate*)dateTime;

@end
