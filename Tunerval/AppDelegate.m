//
//  AppDelegate.m
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "AppDelegate.h"
#import <PitchEstimator/SBNote.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // seed randomness only once
    // http://nshipster.com/random/
    // used for duration of note
    srand48(arc4random());
    
    // if there is no set of selected intervals, set it.
    NSMutableArray *intervals = [[NSUserDefaults standardUserDefaults] objectForKey:@"selected_intervals"];
    
    if (intervals == nil)
    {
        intervals = [[NSMutableArray alloc] init];
        [intervals addObject:[NSNumber numberWithInteger:IntervalTypeMinorSecondAscending]];
        [[NSUserDefaults standardUserDefaults] setObject:intervals forKey:@"selected_intervals"];
    }
    
    // this needs to be done seperately for compatibility
    NSString *fromNote = [[NSUserDefaults standardUserDefaults] objectForKey:@"from-note"];
    if (fromNote == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"C4" forKey:@"from-note"];
        [[NSUserDefaults standardUserDefaults] setObject:@"C5" forKey:@"to-note"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@100 forKey:@"daily-goal"];
    }
    
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
