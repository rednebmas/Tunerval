//
//  SettingsInstrumentTableViewController.m
//  Tunerval
//
//  Created by Sam Bender on 7/9/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <SBMusicUtilities/SBNote.h>
#import "SettingsInstrumentTableViewController.h"
#import "InstrumentTableViewCell.h"

@interface SettingsInstrumentTableViewController ()

@property (nonatomic, strong) NSArray *instrumentNames;
@property (nonatomic, strong) NSArray *instrumentValues;
@property (nonatomic, strong) NSMutableArray *selectedInstruments;
@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation SettingsInstrumentTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Instruments"];
    [self.tableView setDelegate:self];
    [self removeTableCellButtonClickDelay];
    [self addRestorePurchasesBarButtonItem];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    self.selectedInstruments = [[self.defaults objectForKey:@"instruments"] mutableCopy];
    self.instrumentNames = @[
                             @"Sine Wave",
                             @"Piano"
                             ];
    self.instrumentValues = @[
                              @(InstrumentTypeSineWave),
                              @(InstrumentTypePiano)
                              ];
}

- (void) removeTableCellButtonClickDelay
{
    self.tableView.delaysContentTouches = NO;
    for (UIView *currentView in self.tableView.subviews) {
        if ([currentView isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)currentView).delaysContentTouches = NO;
            break;
        }
    }
}

- (void) addRestorePurchasesBarButtonItem
{
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(restorePurchases)];
    [self.navigationItem setRightBarButtonItem:bbi];
}

#pragma mark - Tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.instrumentNames.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstrumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstrumentTableViewCell"];
    
    if (indexPath.row == 0)
    {
        [cell hideBuyButton];
    }
    
    NSNumber *instrument = self.instrumentValues[indexPath.row];
    [cell setCheckMarkHidden:![self.selectedInstruments containsObject:instrument]];
    [cell.instrumentNameLabel setText:self.instrumentNames[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    InstrumentType instrument = [self.instrumentValues[indexPath.row] integerValue];
    if (![self canSelectInstrument:instrument])
    {
        return;
    }
    
    InstrumentTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell toggleCheckMark];
    if (cell.isSelected) {
        [self.selectedInstruments addObject:@(instrument)];
    } else {
        [self.selectedInstruments removeObject:@(instrument)];
    }
    
    [self.defaults setObject:self.selectedInstruments forKey:@"instruments"];
}

#pragma mark - Actions

- (BOOL)canSelectInstrument:(InstrumentType)instrument
{
    return self.selectedInstruments.count > 0;
}

#pragma mark - Actions

- (void) restorePurchases
{
    
}

@end
