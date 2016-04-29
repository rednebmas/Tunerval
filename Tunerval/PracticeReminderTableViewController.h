//
//  PracticeReminderTableViewController.h
//  Tunerval
//
//  Created by Sam Bender on 4/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PracticeReminderTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *remindersEnabledSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@end
