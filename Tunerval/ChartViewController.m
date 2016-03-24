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
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadInterval];
    [self.lineGraph reloadGraph];
}

- (void) loadInterval
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    IntervalType interval = [defaults integerForKey:@"graph-selected-interval"];
    
    [self.pickIntervalButton setTitle:[SBNote intervalTypeToIntervalName:interval]
                             forState:UIControlStateNormal];
    self.data = [ScoresData difficultyDataForInterval:interval];
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
    self.lineGraph.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    self.lineGraph.enableYAxisLabel = YES;
    self.lineGraph.enableReferenceYAxisLines = YES;
    self.lineGraph.enablePopUpReport = YES;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
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

#pragma mark - Actions

- (IBAction) dismiss:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
