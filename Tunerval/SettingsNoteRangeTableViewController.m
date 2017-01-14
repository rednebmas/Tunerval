//
//  SetingsNoteRangeTableViewController.m
//  Tunerval
//
//  Created by Sam Bender on 3/1/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <SBMusicUtilities/SBNote.h>
#import "SettingsNoteRangeTableViewController.h"

@interface SettingsNoteRangeTableViewController ()

@end

@implementation SettingsNoteRangeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Note Range"];
    
    self.fromPickerView.protocolReciever = self;
    self.toPickerView.protocolReciever = self;
    
    NSString *fromNote = [[NSUserDefaults standardUserDefaults] objectForKey:@"from-note"];
    NSString *toNote = [[NSUserDefaults standardUserDefaults] objectForKey:@"to-note"];
    [self.fromPickerView selectNote:[SBNote noteWithName:fromNote] animated:NO];
    [self.toPickerView selectNote:[SBNote noteWithName:toNote] animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Pickerview delegate

- (void) notePickerView:(NotePickerView*)pickerView
             pickedNote:(SBNote*)note
{
    if (pickerView == self.fromPickerView)
    {
        // we need to ensure that the to note is greater than or equal to the from note
        NSString *toNoteName = [[NSUserDefaults standardUserDefaults] objectForKey:@"to-note"];
        SBNote *toNote = [SBNote noteWithName:toNoteName];
        if (note.frequency <= toNote.frequency)
        {
            [[NSUserDefaults standardUserDefaults] setObject:note.nameWithOctave forKey:@"from-note"];
        }
        else
        {
            NSString *fromNoteName = [[NSUserDefaults standardUserDefaults] objectForKey:@"from-note"];
            SBNote *fromNote = [SBNote noteWithName:fromNoteName];
            [self.fromPickerView selectNote:fromNote animated:YES];
        }
    }
    else
    {
        // we need to ensure that the to note is greater than or equal to the from note
        NSString *fromNoteName = [[NSUserDefaults standardUserDefaults] objectForKey:@"from-note"];
        SBNote *fromNote = [SBNote noteWithName:fromNoteName];
        if (note.frequency >= fromNote.frequency)
        {
            [[NSUserDefaults standardUserDefaults] setObject:note.nameWithOctave forKey:@"to-note"];
        }
        else
        {
            NSString *toNoteName = [[NSUserDefaults standardUserDefaults] objectForKey:@"to-note"];
            SBNote *toNote = [SBNote noteWithName:toNoteName];
            [self.toPickerView selectNote:toNote animated:YES];
        }
    }
}

@end
