//
//  ChartViewController.m
//  Tunerval
//
//  Created by Sam Bender on 3/19/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "ChartViewController.h"
#import "ScoresData.h"
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>

@interface ChartViewController () <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (nonatomic, retain) NSArray *data;

@end

@implementation ChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureLineGraph];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger dataRange = [defaults integerForKey:@"graph-data-range"];
    [self.dataRangeSegmentedControl setSelectedSegmentIndex:dataRange];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
    [self.lineGraph reloadGraph];
}

- (void) loadData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // interval
    IntervalType interval = [defaults integerForKey:@"graph-selected-interval"];
    [self.pickIntervalButton setTitle:[SBNote intervalTypeToIntervalName:interval]
                             forState:UIControlStateNormal];
    
    // data duration
    NSInteger dataRange = [defaults integerForKey:@"graph-data-range"];
    NSDate *dateForRange = [self dateForDataRange:dataRange];
    
    // get data
    self.data = [ScoresData difficultyDataForInterval:interval
                                   afterUnixTimestamp:[dateForRange timeIntervalSince1970]];
    
//    self.data = [ScoresData runningAverageDifficultyAfterUnixTimeStamp:[dateForRange timeIntervalSince1970]];
}

/**
 * @param range
 * 0 = today
 * 1 = week
 * 2 = month
 * 3 = all
 */
- (NSDate*) dateForDataRange:(NSInteger)range
{
    NSDate *date = [NSDate date];
    switch (range) {
        case 0:
            date = [date dateByAddingTimeInterval:-60*60*24];
            break;
            
        case 1:
            date = [date dateByAddingTimeInterval:-60*60*24*7];
            break;
            
        case 2:
            date = [date dateByAddingTimeInterval:-60*60*24*31];
            break;
            
        case 3:
            date = [NSDate dateWithTimeIntervalSince1970:0];
            break;
            
        default:
            break;
    }
    
    return date;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Line graph configuration

- (void) configureLineGraph
{
    self.lineGraph.delegate = self;
    self.lineGraph.dataSource = self;
    self.lineGraph.colorTop = [UIColor clearColor];
    self.lineGraph.colorBottom = [UIColor clearColor];
    self.lineGraph.colorYaxisLabel = [UIColor whiteColor];
    self.lineGraph.colorTouchInputLine = [UIColor whiteColor];
    self.lineGraph.enableYAxisLabel = YES;
    self.lineGraph.enableReferenceYAxisLines = YES;
    self.lineGraph.enablePopUpReport = YES;
    self.lineGraph.enableReferenceYAxisLines = YES;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 0.6,
        1.0, 1.0, 1.0, 0.0
    };
    
    // Apply the gradient to the bottom portion of the graph
    self.lineGraph.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
 
}

#pragma mark - Line graph delegate

- (NSInteger) numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph
{
    return self.data.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index
{
    return [self.data[index] floatValue];
}

- (CGFloat) maxValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 101.0;
}

- (CGFloat) minValueForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 0.0;
}

- (NSInteger) numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 4;
}

- (CGFloat) baseValueForYAxisOnLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 0.0;
}

- (CGFloat) incrementValueForYAxisOnLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 25.0;
}

- (CGFloat) staticPaddingForLineGraph:(BEMSimpleLineGraphView *)graph
{
    return 10.0;
}

- (NSString*) yAxisPrefixOnLineGraph:(BEMSimpleLineGraphView *)graph
{
    return @"±";
}

- (NSString*) yAxisSuffixOnLineGraph:(BEMSimpleLineGraphView *)graph
{
    return @"c";
}

- (NSString*) popUpPrefixForlineGraph:(BEMSimpleLineGraphView *)graph
{
    return @"±";
}

- (NSString*) popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph
{
    return @"c";
}

#pragma mark - Actions

- (IBAction) dismiss:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dataRangeValueChanged:(UISegmentedControl *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sender.selectedSegmentIndex forKey:@"graph-data-range"];
    
    [self loadData];
    [self.lineGraph reloadGraph];
}

@end
