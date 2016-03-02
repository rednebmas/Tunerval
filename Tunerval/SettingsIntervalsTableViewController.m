//
//  SettingsTableViewController.m
//  Tunerval
//
//  Created by Sam Bender on 2/27/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <PitchEstimator/SBNote.h>
#import "SettingsIntervalsTableViewController.h"
#import "ViewController.h"

@interface SettingsIntervalsTableViewController ()

@property (nonatomic, retain) NSMutableArray *intervals;
@property (nonatomic, retain) UILabel *usageLabel;

@end

@implementation SettingsIntervalsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.intervals = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selected_intervals"] mutableCopy];
    [self.navigationItem setTitle:@"Intervals"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    if (section == 0)
    {
        rows = 1;
    }
    else
    {
        rows = 12;
    }
        
    return rows;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    switch (section) {
        case 1:
            title = @"Ascending intervals";
            break;
            
        case 2:
            title = @"Descending intervals";
            break;
            
        default:
            title = @"";
            break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"
                                                            forIndexPath:indexPath];
    
    // get the data
    NSNumber *interval = [self intervalForIndexPath:indexPath];
    
    // configure cell
    if (indexPath.section != 0)
    {
        [cell.textLabel setText:[SBNote intervalTypeToIntervalName:[interval integerValue]]];
    }
    else
    {
        [cell.textLabel setText:@"Unison"];
    }
    
    if ([self.intervals containsObject:interval])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // add/remove checkmark to cell
    NSNumber *interval = [self intervalForIndexPath:indexPath];
    if ([self.intervals containsObject:interval])
    {
        if (self.intervals.count > 1)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.intervals removeObject:interval];
        }
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.intervals addObject:interval];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.intervals forKey:@"selected_intervals"];
}

#pragma mark - Helper

- (NSNumber*) intervalForIndexPath:(NSIndexPath*)indexPath
{
    NSNumber *interval;
    if (indexPath.section == 0)
    {
        interval = [NSNumber numberWithInteger:IntervalTypeUnison];
    }
    else if (indexPath.section == 1)
    {
        interval = [[SBNote ascendingIntervals] objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 2)
    {
        interval = [[SBNote descendingIntervalsSmallestToLargest] objectAtIndex:indexPath.row];
    }
    
    return interval;
}

#pragma mark - Actions

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
