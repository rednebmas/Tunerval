//
//  PracticeRemindersNotificationsDisabledView.m
//  Tunerval
//
//  Created by Sam Bender on 4/28/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "PracticeRemindersNotificationsDisabledView.h"

@implementation PracticeRemindersNotificationsDisabledView

- (IBAction)takeMeToSettings:(id)sender
{
    NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:appSettings];
}

@end
