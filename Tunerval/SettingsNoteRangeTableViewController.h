//
//  SetingsNoteRangeTableViewController.h
//  Tunerval
//
//  Created by Sam Bender on 3/1/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotePickerView.h"

@interface SettingsNoteRangeTableViewController : UITableViewController <NotePickerViewProtocol>

@property (weak, nonatomic) IBOutlet NotePickerView *fromPickerView;
@property (weak, nonatomic) IBOutlet NotePickerView *toPickerView;

@end
