//
//  SettingsTableViewController.h
//  Tunerval
//
//  Created by Sam Bender on 2/27/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *intervalsSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteRangeSelectedLabel;
@property (weak, nonatomic) IBOutlet UITextField *dailyGoalProgressTextField;

@end
