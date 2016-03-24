//
//  ChartPickIntervalTableViewController.m
//  Tunerval
//
//  Created by Sam Bender on 3/23/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <PitchEstimator/SBNote.h>
#import "ChartPickIntervalTableViewController.h"

@interface ChartPickIntervalTableViewController ()

@property (nonatomic) IntervalType selectedInterval;

@end

@implementation ChartPickIntervalTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.selectedInterval = [defaults integerForKey:@"graph-selected-interval"];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView scrollToRowAtIndexPath:[self indexPathForInterval:self.selectedInterval]
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
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
    
    if (self.selectedInterval == [interval integerValue])
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
    
    NSIndexPath *selectedIndexPath = [self indexPathForInterval:self.selectedInterval];
    UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
    UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSNumber *newInterval = [self intervalForIndexPath:indexPath];
    self.selectedInterval = [newInterval integerValue];
    
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [[NSUserDefaults standardUserDefaults] setInteger:[newInterval integerValue]
                                               forKey:@"graph-selected-interval"];
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

- (NSIndexPath*) indexPathForInterval:(IntervalType)interval
{
    NSIndexPath *indexPath;
    
    if (interval == 0)
    {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else if (interval > 0)
    {
        indexPath = [NSIndexPath indexPathForRow:interval-1 inSection:1];
    }
    else
    {
        indexPath = [NSIndexPath indexPathForRow:-interval-1 inSection:2];
    }
    
    return indexPath;
}

#pragma mark - Actions

- (IBAction) dismiss:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
