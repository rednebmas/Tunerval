//
//  PushNotificationHandler.m
//  Tunerval
//
//  Created by Sam Bender on 12/30/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "PushNotificationHandler.h"
#import <UIKit/UIKit.h>

@implementation PushNotificationHandler

- (void)generateNotification 
{
    UILocalNotification *notifyAlarm = [[UILocalNotification alloc] init];
    if (notifyAlarm)
    {
        // get reminder time
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDate *practiceReminderTime = [defaults objectForKey:@"practice-reminder-time"];
        
        //
        // if they've met their goal, reschedule to start tomorrow
        //
        NSDate *beginningOfDay = [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
        NSString *goalMetKey = [NSString stringWithFormat:@"daily-goal-met-%f",
                                beginningOfDay.timeIntervalSince1970];
        if ([defaults boolForKey:goalMetKey])
        {
            practiceReminderTime = [PushNotificationHandler dateTomorrowForTime:practiceReminderTime];
        }
        
    }
}

/*
- (void)scheduleStreakReminderOn:(NSDate*)date notification:(UILocalNotification*)notification
{
    // must call scheduleGenericRepeatingNotificationStarting:notification: first because it cancels
    // all local notifications.
    NSDate *nextDay = [self dateTomorrowForTime:date];
    [self scheduleStreakReminderOn:nextDay notification:[UILocalNotification new]]
    
    
    notification.fireDate = date;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = @"Practice reminder! Short doses of daily practice are the key to improving your ear!";
    
    // create notification
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
} */

/**
 * Warning: cancels all local notifications!
 */
- (void)scheduleGenericRepeatingNotificationStarting:(NSDate*)date
                                        notification:(UILocalNotification*)notification
{
    // configure notification
    notification.fireDate = date;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.repeatInterval = NSCalendarUnitDay;
    notification.alertBody = @"Practice reminder! Short doses of daily practice are the key to improving your ear!";
    
    // create notification
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (NSDate*) dateTomorrowForTime:(NSDate*)dateTime
{
    // time components
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDateComponents *timeComponents = [calendar components:NSUIntegerMax fromDate:dateTime];
    
    // tomorrow components
    NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval:60*60*24];
    NSDateComponents *tomorrowComponents = [calendar components:NSUIntegerMax fromDate:tomorrow];
    
    // change time of tomorrow components
    [tomorrowComponents setHour:timeComponents.hour];
    [tomorrowComponents setMinute:timeComponents.minute];
    
    return [calendar dateFromComponents:tomorrowComponents];
}

@end
