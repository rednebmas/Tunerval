//
//  AppDelegate.m
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "AppDelegate.h"
#import <SBMusicUtilities/SBNote.h>
#import "MigrationManager.h"
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
        [defaults setObject:@"A6" forKey:@"to-note"];
        
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
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"New stuff!"
                                    message:@"From now on, Tunerval will track your progress. Tap the new graph icon in the upper right to see how you're doing."
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        
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

@end
