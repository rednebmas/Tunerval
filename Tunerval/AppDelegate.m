//
//  AppDelegate.m
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "AppDelegate.h"
#import <SBMusicUtilities/SBNote.h>
#import <AWSMobileAnalytics/AWSMobileAnalytics.h>
#import "MigrationManager.h"
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (DEBUGMODE == NO)
    {
        // Start mobile analytics
        MOBILE_ANALYTICS;
    }
    
    // seed randomness only once
    // http://nshipster.com/random/
    // used for duration of note
    srand48(arc4random());
    
    // get defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // if there is no set of selected intervals, set it.
    NSMutableArray *intervals = [defaults objectForKey:@"selected_intervals"];
    
    if (intervals == nil)
    {
        intervals = [[NSMutableArray alloc] init];
        [intervals addObject:[NSNumber numberWithInteger:IntervalTypeUnison]];
        [intervals addObject:[NSNumber numberWithInteger:IntervalTypeMajorSecondAscending]];
        [defaults setObject:intervals forKey:@"selected_intervals"];
    }
    
    // this needs to be done seperately for compatibility
    NSString *fromNote = [defaults objectForKey:@"from-note"];
    if (fromNote == nil)
    {
        [defaults setObject:@"A4" forKey:@"from-note"];
        [defaults setObject:@"A5" forKey:@"to-note"];
        
        [defaults setObject:@100 forKey:@"daily-goal"];
    }
    
    double noteDuration = [defaults doubleForKey:@"note-duration"];
    if (noteDuration == 0.0)
    {
        [defaults setDouble:0.65 forKey:@"note-duration"];
        [defaults setDouble:0.3 forKey:@"note-duration-variation"];
        [defaults setObject:@(YES) forKey:@"speak-interval-on"];
    }
    
    NSString *lastVersion = [defaults stringForKey:@"version-last"];
    if (lastVersion == nil)
    {
        [defaults setObject:@"1.2" forKey:@"version-last"];
        [defaults setInteger:ALL_INTERVALS_VALUE forKey:@"graph-selected-interval"];
        [defaults setInteger:3 forKey:@"graph-data-range"];
        
        /*
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"New stuff!"
                                    message:@"From now on, Tunerval will track your progress. Tap the new graph icon in the upper right to see how you're doing."
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"Nice"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        [alert addAction:ok];
        
        [self.window makeKeyAndVisible]; // hacky?
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
         */
    }
    
    if ([defaults objectForKey:@"practice-reminder-time"] == nil)
    {
        // set default practice reminder time
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setHour:18];
        [components setMinute:0];
        [components setSecond:0];
        [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
        NSDate *dateToFire = [calendar dateFromComponents:components];
        
        [defaults setObject:dateToFire forKey:@"practice-reminder-time"];
        
        // ask user for practice reminders
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"New feature: Practice Reminders"
                                    message:@"Daily practice is essential to improve your ear. Tunerval can now remind you to hit your daily goal."
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"Remind me!"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 // record to AWS analytics
                                 if (DEBUGMODE == NO)
                                 {
                                     id<AWSMobileAnalyticsEventClient> eventClient = [MOBILE_ANALYTICS eventClient];
                                     id<AWSMobileAnalyticsEvent> askForReminderEvent = [eventClient
                                                                                  createEventWithEventType:@"AskForReminder"];
                                     
                                     [askForReminderEvent addMetric:@(1.0) forKey:@"Answer"];
                                     [eventClient recordEvent:askForReminderEvent];
                                 }

                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self.window.rootViewController performSegueWithIdentifier:@"SettingsSegue" sender:self];
                             }];
        
        UIAlertAction *noThanks = [UIAlertAction
                             actionWithTitle:@"No thanks"
                             style:UIAlertActionStyleDestructive
                                   
                             handler:^(UIAlertAction * action)
                             {
                                 // record to AWS analytics
                                 if (DEBUGMODE == NO)
                                 {
                                     id<AWSMobileAnalyticsEventClient> eventClient = [MOBILE_ANALYTICS eventClient];
                                     id<AWSMobileAnalyticsEvent> askForReminderEvent = [eventClient
                                                                                        createEventWithEventType:@"AskForReminder"];
                                     
                                     [askForReminderEvent addMetric:@(0.0) forKey:@"Answer"];
                                     [eventClient recordEvent:askForReminderEvent];
                                 }

                                 UIAlertController *alert = [UIAlertController
                                                             alertControllerWithTitle:@"That's quite alright!"
                                                             message:@"You can enable practice reminders in settings at any time."
                                                             preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 UIAlertAction *ok = [UIAlertAction
                                                      actionWithTitle:@"Ok"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                                      {
                                                          [alert dismissViewControllerAnimated:YES completion:nil];
                                                      }];
                                 [alert addAction:ok];
                                 [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
                             }];
        
        [alert addAction:noThanks];
        [alert addAction:ok];
        
        [self.window makeKeyAndVisible]; // hacky?
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    
    // database stuff
    [MigrationManager checkForAndPerformPendingMigrations];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Notifications

- (void) application:(UIApplication*)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRegisterLocalNotificationWithSettings"
                                                        object:notificationSettings
                                                      userInfo:nil];
}

- (void) createNotification
{
    UILocalNotification *notifyAlarm = [[UILocalNotification alloc] init];
    if (notifyAlarm)
    {
        // get reminder time
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDate *practiceReminderTime = [defaults objectForKey:@"practice-reminder-time"];
    
        // if they've met their goal, reschedule to start tomorrow
        NSDate *beginningOfDay = [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
        NSString *goalMetKey = [NSString stringWithFormat:@"daily-goal-met-%f",
                                beginningOfDay.timeIntervalSince1970];
        if ([defaults boolForKey:goalMetKey])
        {
            practiceReminderTime = [self dateTomorrowForTime:practiceReminderTime];
        }
        
        // configure notification
        notifyAlarm.fireDate = practiceReminderTime;
        notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
        notifyAlarm.repeatInterval = NSCalendarUnitDay;
        notifyAlarm.alertBody = @"Daily practice is needed to improve your ear!";
        
        // create notification
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] scheduleLocalNotification:notifyAlarm];
    }
}

#pragma mark - Misc

- (NSDate*) dateTomorrowForTime:(NSDate*)dateTime
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
