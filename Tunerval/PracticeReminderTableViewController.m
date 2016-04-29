//
//  PracticeReminderTableViewController.m
//  Tunerval
//
//  Created by Sam Bender on 4/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "PracticeReminderTableViewController.h"
#import "PracticeRemindersNotificationsDisabledView.h"

@interface PracticeReminderTableViewController ()
{
    NSUserDefaults *defaults;
}

@property (nonatomic, retain) PracticeRemindersNotificationsDisabledView *notificationsDisabledView;

@end

@implementation PracticeReminderTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    [self setupView];
}

- (void) setupView
{
    BOOL remindersEnabled = [defaults boolForKey:@"practice-reminders-enabled"];
    NSDate *practiceReminderTime = [defaults objectForKey:@"practice-reminder-time"];
    
    self.remindersEnabledSwitch.on = remindersEnabled;
    self.timePicker.date = practiceReminderTime;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userNotificationSettingsUpdate:)
                                                 name:@"DidRegisterLocalNotificationWithSettings"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:@"UIApplicationWillEnterForegroundNotification"
                                               object:nil];
}

/**
 * If user enables push notifications after being taken to settings if they are disabled,
 * this will hide the push notifications are disabled message.
 */
- (void) applicationWillEnterForeground:(NSNotification*)notification
{
    self.notificationsDisabledView.hidden = [self localNotificationsEnabled];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void) userNotificationSettingsUpdate:(NSNotification*)notification
{
    if (self.remindersEnabledSwitch.on)
    {
        [self determineNotificationsDisabledViewVisibility];
    }
}

#pragma mark - Tableview

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return nil;
    }
    else if (section == 0)
    {
        if (self.remindersEnabledSwitch.on == YES && [self localNotificationsEnabled] == NO)
        {
            self.notificationsDisabledView.hidden = NO;
        }
        else
        {
            self.notificationsDisabledView.hidden = YES;
        }
        
        return self.notificationsDisabledView;
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height;
    switch (section) {
        case 0:
            if (self.remindersEnabledSwitch.on == YES && [self localNotificationsEnabled] == NO)
            {
                CGFloat labelWidth = tableView.frame.size.width
                                     - 2 * self.notificationsDisabledView.label.frame.origin.x;
                height = 75 + [self heightForLabel:self.notificationsDisabledView.label
                                         withWidth:labelWidth];
            }
            else
            {
                height = 35;
            }
            break;
            
        default:
            height = 35;
            break;
    }
    return height;
}

- (CGFloat) heightForLabel:(UILabel*)label withWidth:(CGFloat)width
{
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:label.text
                                          attributes:@{ NSFontAttributeName: label.font
                                                        }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGFloat height = rect.size.height;
    
    return height;
}

#pragma mark - Actions

- (IBAction) remindersEnabledValueChanged:(UISwitch*)sender
{
    if (sender.on)
    {
        if (![self localNotificationsEnabled])
        {
            UIApplication *application = [UIApplication sharedApplication];
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
        else
        {
            self.notificationsDisabledView.hidden = YES;
        }
    }
    else
    {
        [self determineNotificationsDisabledViewVisibility];
    }
    
    [defaults setObject:@(sender.on) forKey:@"practice-reminders-enabled"];
}

- (IBAction) timePickerValueChanged:(id)sender
{
    [defaults setObject:self.timePicker.date forKey:@"practice-reminder-time"];
}

#pragma mark - Getters

- (PracticeRemindersNotificationsDisabledView*) notificationsDisabledView
{
    if (_notificationsDisabledView == nil)
    {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"PracticeRemindersNotificationsDisabledView"
                                                          owner:self
                                                        options:nil];
        UIView *view = [nibViews objectAtIndex:0];
        
        self.notificationsDisabledView = (PracticeRemindersNotificationsDisabledView*)view;
    }
    
    return _notificationsDisabledView;
}

#pragma mark - Misc

- (BOOL) localNotificationsEnabled
{
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    return grantedSettings.types != UIUserNotificationTypeNone;
}

- (void) determineNotificationsDisabledViewVisibility
{
    [self.tableView beginUpdates];
    
    if (self.remindersEnabledSwitch.on && [self localNotificationsEnabled] == NO)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .25 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
             self.notificationsDisabledView.hidden = NO;
        });
    }
    else
    {
        self.notificationsDisabledView.hidden = YES;
    }
    
    [self.tableView endUpdates];
}

@end
