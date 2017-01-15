//
//  PushNotificationHandler.m
//  Tunerval
//
//  Created by Sam Bender on 12/30/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushNotificationHandler.h"
#import "SBEventTracker.h"

@implementation PushNotificationHandler

#pragma mark - Public

+ (void) askForReminderFrom:(UIViewController*)viewController completion:(void(^)(BOOL accepted))completion
{
    __weak UIViewController* weakViewController = viewController;
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Congrats on completing your daily goal!"
                                message:@"Daily practice is essential to improving your ear. Would you like Tunerval to send you daily practice reminders?"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Remind me!"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action)
                         {
                             // record to AWS analytics
                             [SBEventTracker trackAskForReminderWithValue:YES];
                             
                             if (completion) {
                                 completion(YES);
                             }
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    UIAlertAction *noThanks = [UIAlertAction
                               actionWithTitle:@"No thanks"
                               style:UIAlertActionStyleDestructive
                               
                               handler:^(UIAlertAction * action)
                               {
                                   [SBEventTracker trackAskForReminderWithValue:NO];
                                   [PushNotificationHandler
                                    tellUserHowToEnablePracticeReminders:weakViewController
                                    handler:^{
                                        if (completion) {
                                            completion(NO);
                                        }
                                    }];
                               }];
    
    [alert addAction:noThanks];
    [alert addAction:ok];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

+ (void)tellUserHowToEnablePracticeReminders:(UIViewController*)viewController handler:(void(^)(void))handler
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"That's quite alright!"
                                message:@"You can enable practice reminders in settings at any time."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             if (handler) handler();
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];
    [viewController presentViewController:alert animated:YES completion:nil];
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

#pragma mark - Private

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

@end
