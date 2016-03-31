//
//  SettingsTableViewController.m
//  Tunerval
//
//  Created by Sam Bender on 2/27/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

@import MessageUI;
#import <SBMusicUtilities/SBNote.h>
#import "SettingsTableViewController.h"
#import "ViewController.h"
#import "NSAttributedString+Utilities.h"
#import "SettingsNumberPickerTableViewController.h"
#import "SecondsPickerView.h"

@interface SettingsTableViewController ()
{
    NSUserDefaults *defaults;
}

@property (nonatomic, retain) NSMutableArray *intervals;
@property (nonatomic, retain) UILabel *usageLabel;


@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    defaults = [NSUserDefaults standardUserDefaults];
    self.intervals = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selected_intervals"] mutableCopy];
    [self.navigationItem setTitle:@"Settings"];
    [self createFooter];
    
    self.dailyGoalProgressTextField.delegate = self;
    [self addDoneButtonToTextField];
    
    [self.speakIntervalSwitch setOn:[[defaults objectForKey:@"speak-interval-on"] boolValue]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setIntervalsSelectedLabelText];
    [self setNoteRangeSelectedLabelText];
    [self setContentForDailyProgressTextField];
    [self setNoteDurationAndVariationValueLabels];
}

- (void) setNoteDurationAndVariationValueLabels
{
    double noteDuration = [defaults doubleForKey:@"note-duration"];
    double noteDurationVariation = [defaults doubleForKey:@"note-duration-variation"];
    
    [self.noteDurationValueLabel setText:[NSString stringWithFormat:@"%.2fs", noteDuration]];
    [self.noteDurationVariationValueLabel setText:[NSString
                                                   stringWithFormat:@"%.2fs", noteDurationVariation]];
}

- (void) setContentForDailyProgressTextField
{
    NSNumber *goal = [[NSUserDefaults standardUserDefaults] objectForKey:@"daily-goal"];
    NSInteger goalInteger = [goal integerValue];
    [self.dailyGoalProgressTextField setText:[NSString stringWithFormat:@"%lu", goalInteger]];
}

- (void) setNoteRangeSelectedLabelText
{
    NSString *fromNoteString = [[NSUserDefaults standardUserDefaults] objectForKey:@"from-note"];
    NSString *toNoteString = [[NSUserDefaults standardUserDefaults] objectForKey:@"to-note"];
    SBNote *fromNote = [SBNote noteWithName:fromNoteString];
    SBNote *toNote = [SBNote noteWithName:toNoteString];
    
    NSString *fromNoteOctaveString = [NSString stringWithFormat:@"%d", fromNote.octave];
    NSString *toNoteOctaveString = [NSString stringWithFormat:@"%d", toNote.octave];
    
    NSMutableAttributedString *fromAttributed = [[NSAttributedString
                                                  attributedStringForText:fromNote.nameWithoutOctave
                                                  andSubscript:fromNoteOctaveString
                                                  withFontSize:17.0] mutableCopy];
    NSAttributedString *toAttributed = [NSAttributedString
                                        attributedStringForText:[NSString stringWithFormat:@" - %@", toNote.nameWithoutOctave]
                                        andSubscript:toNoteOctaveString
                                        withFontSize:17.0];
    [fromAttributed appendAttributedString:toAttributed];
    
    [self.noteRangeSelectedLabel setAttributedText:fromAttributed];
}

- (void) setIntervalsSelectedLabelText
{
    NSArray *selectedIntervals = [[NSUserDefaults standardUserDefaults]
                                  objectForKey:@"selected_intervals"];
    NSArray *sorted = [selectedIntervals sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *intervalNames = [[NSMutableArray alloc] initWithCapacity:sorted.count];
    for (int i = 0; i < sorted.count; i++)
    {
        IntervalType interval = [[sorted objectAtIndex:i] integerValue];
        NSString *directionalArrow;
        if (interval > 0)
        {
            directionalArrow = @"↑";
        }
        else if (interval == 0)
        {
            directionalArrow = @"";
        }
        else
        {
            directionalArrow = @"↓";
        }
        
        NSString *intervalName =  [NSString stringWithFormat:@" %@%@",
                                   [SBNote intervalTypeToIntervalShorthand:interval],
                                   directionalArrow
                                   ];
        [intervalNames addObject:intervalName];
    }
    
    [self.intervalsSelectedLabel setText:[intervalNames componentsJoinedByString:@", "]];
}

- (void) createFooter
{
    // create info section
    UIView *footerView = [[UIView alloc] init];
    CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, 60);
    footerView.frame = frame;
    self.usageLabel = [[UILabel alloc] init];
    self.usageLabel.textColor = [UIColor darkGrayColor];
    self.usageLabel.numberOfLines = 0;
    self.usageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    frame.origin.y = - 12;
    frame.size.width -= 35;
    frame.origin.x += 35.0 / 2.0;
    self.usageLabel.frame = frame;
    [self.usageLabel setTextAlignment:NSTextAlignmentCenter];
    [footerView addSubview:self.usageLabel];
    self.tableView.tableFooterView = footerView;
    
    NSInteger questionsAnsweredTotal = [[NSUserDefaults standardUserDefaults] integerForKey:@"questions-answered-total"];
    NSNumber *questionsAnsweredTotalNumber = [NSNumber numberWithInteger:questionsAnsweredTotal];
    NSString *text = [NSString
                      localizedStringWithFormat:@"%@ questions answered in total", questionsAnsweredTotalNumber];
    [self.usageLabel setText:text];
}

- (void) addDoneButtonToTextField
{
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(doneEditingDailyProgress)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.dailyGoalProgressTextField.inputAccessoryView = keyboardToolbar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)speakIntervalValueChanged:(UISwitch *)sender
{
    NSNumber *on = [NSNumber numberWithBool:sender.on];
    [defaults setObject:on forKey:@"speak-interval-on"];
}


- (void) doneEditingDailyProgress
{
    [self.view endEditing:YES];
    
    NSInteger dailyGoalIntegerVal = [self.dailyGoalProgressTextField.text integerValue];
    if (dailyGoalIntegerVal < 25)
    {
        [self setContentForDailyProgressTextField];
        return;
    }
    
    NSNumber *numberVal = [NSNumber numberWithInteger:dailyGoalIntegerVal];
    [[NSUserDefaults standardUserDefaults] setObject:numberVal forKey:@"daily-goal"];
}

#pragma mark - Table view

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            NSString *messageBody = [NSString stringWithFormat:@"\n\n--\nI've answered %d questions.",
                                     (int)[defaults integerForKey:@"questions-answered-total"]];
            
            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
            mail.mailComposeDelegate = self;
            [mail setSubject:@"Tunerval Feedback"];
            [mail setMessageBody:messageBody isHTML:NO];
            [mail setToRecipients:@[@"rednebmas+tunerval@gmail.com"]];
            
            [self presentViewController:mail animated:YES completion:nil];
        }
        else
        {
            NSLog(@"This device cannot send email");
        }
    }
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NoteDurationSegue"])
    {
        SettingsNumberPickerTableViewController *vc = (SettingsNumberPickerTableViewController*)segue.destinationViewController;
        [vc.navigationItem setTitle:@"Note Duration"];
        [vc loadViewIfNeeded];
        vc.numberPicker.min = 0.1;
        vc.numberPicker.max = 2.0;
        vc.numberPicker.step = .05;
        vc.numberPicker.defaultValue = 0.8;
        vc.numberPicker.settingsKey = @"note-duration";
        
        [vc.numberPicker generateSecondsList];
    }
    else if ([segue.identifier isEqualToString:@"NoteDurationVariationSegue"])
    {
        SettingsNumberPickerTableViewController *vc = (SettingsNumberPickerTableViewController*)segue.destinationViewController;
        [vc.navigationItem setTitle:@"Note Variation Duration"];
        [vc loadViewIfNeeded];
        vc.numberPicker.min = 0.0;
        vc.numberPicker.max = 2.0;
        vc.numberPicker.step = .1;
        vc.numberPicker.defaultValue = 0.1;
        vc.numberPicker.settingsKey = @"note-duration-variation";
        
        [vc.numberPicker generateSecondsList];
    }
}

#pragma mark - Mail delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
