//
//  AppDelegate.m
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "AppDelegate.h"
#import <SBMusicUtilities/SBNote.h>
#import <SBMusicUtilities/SBPlayableNote.h>
#import <AWSMobileAnalytics/AWSMobileAnalytics.h>
#import <SBRatePrompt/SBRatePrompt.h>
#import "MigrationManager.h"
#import "Constants.h"
#import "PushNotificationHandler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (DEBUGMODE == NO)
    {
        // Start mobile analytics
        MOBILE_ANALYTICS;
        NSLog(@"Analytics started");
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
        
        [defaults setObject:@25 forKey:@"daily-goal"];
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
        [components setHour:9];
        [components setMinute:0];
        [components setSecond:0];
        [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
        NSDate *dateToFire = [calendar dateFromComponents:components];
        
        [defaults setObject:dateToFire forKey:@"practice-reminder-time"];
    }
    
    if ([defaults integerForKey:@"last-build-number"] == 0)
    {
        [defaults setInteger:12 forKey:@"last-build-number"];
        
        // fix not registering for notifications
        UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if ([defaults boolForKey:@"practice-reminders-enabled"]
            && grantedSettings.types != UIUserNotificationTypeNone)
        {
            [self createNotification];
        }
    }
    
    // database stuff
    [MigrationManager checkForAndPerformPendingMigrations];
    
    // set samples base directory
    [SBPlayableNote setSamplesBaseFilePath:[self applicationDocumentsDirectory].path];
    
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
            practiceReminderTime = [PushNotificationHandler dateTomorrowForTime:practiceReminderTime];
        }
        
        // configure notification
        notifyAlarm.fireDate = practiceReminderTime;
        notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
        notifyAlarm.repeatInterval = NSCalendarUnitDay;
        notifyAlarm.alertBody = @"Practice Reminder! Short doses of daily practice are the key to improving your musical ear!";
        
        // create notification
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] scheduleLocalNotification:notifyAlarm];
    }
}

#pragma mark - Misc

- (NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
