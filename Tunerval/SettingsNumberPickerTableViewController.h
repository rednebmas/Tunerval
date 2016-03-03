//
//  SettingsNumberPickerTableViewController.h
//  Tunerval
//
//  Created by Sam Bender on 3/3/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SecondsPickerView;

@interface SettingsNumberPickerTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet SecondsPickerView *numberPicker;

@end
