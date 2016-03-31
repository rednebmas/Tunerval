//
//  SettingsTableViewController.h
//  Tunerval
//
//  Created by Sam Bender on 2/27/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *intervalsSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteRangeSelectedLabel;
@property (weak, nonatomic) IBOutlet UITextField *dailyGoalProgressTextField;
@property (weak, nonatomic) IBOutlet UISwitch *speakIntervalSwitch;
@property (weak, nonatomic) IBOutlet UILabel *noteDurationValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteDurationVariationValueLabel;

@end
