//
//  PracticeReminderTableViewController.h
//  Tunerval
//
//  Created by Sam Bender on 4/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PracticeReminderTableViewController : UITableViewController

// when we ask the user if they want push notifications enabled, we don't want them to have to
// press the "Enable" switch.
@property (nonatomic) BOOL enableReminderSwitchOnViewDidAppear;
@property (weak, nonatomic) IBOutlet UISwitch *remindersEnabledSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@end
