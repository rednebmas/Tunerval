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

@end

@implementation ChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureLineGraph];
    
    /*
    _chartView.delegate = self;
    
    _chartView.descriptionText = @"";
    _chartView.noDataTextDescription = @"No data to display.";
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis removeAllLimitLines];
    leftAxis.customAxisMax = 102.0;
    leftAxis.customAxisMin = 0.0;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    leftAxis.drawZeroLineEnabled = YES;
    leftAxis.zeroLineColor = [UIColor whiteColor];
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    leftAxis.labelTextColor = [UIColor whiteColor];
    // leftAxis.axisLineColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    leftAxis.axisLineColor = [UIColor whiteColor];
    leftAxis.gridColor = [UIColor whiteColor];
    leftAxis.gridColor = [UIColor whiteColor];
    
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.axisLineColor = [UIColor whiteColor];
    xAxis.gridColor = [UIColor whiteColor];
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelTextColor = [UIColor whiteColor];
    
    _chartView.rightAxis.enabled = NO;
    
    [_chartView.viewPortHandler setMaximumScaleY: 4.f];
    [_chartView.viewPortHandler setMaximumScaleX: 4.f];
    
    _chartView.legend.form = ChartLegendFormLine;
    
    [_chartView animateWithXAxisDuration:2.0 easingOption:ChartEasingOptionEaseInOutQuart];
    
    [self setDataCount:10 range:20.0];
     */
}

- (void)setDataCount:(int)count range:(double)range
{
    /*
    NSArray *yValsData = [ScoresData data];
    count = (int)[yValsData count];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        [xVals addObject:[@(i) stringValue]];
    }
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        double val = [yValsData[i] doubleValue];
        [yVals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    
    LineChartDataSet *set1 = [[LineChartDataSet alloc] initWithYVals:yVals label:@"DataSet 1"];
    
    set1.lineDashLengths = @[@5.f, @2.5f];
    set1.highlightLineDashLengths = @[@5.f, @2.5f];
    [set1 setColor:UIColor.whiteColor];
    [set1 setCircleColor:[UIColor.whiteColor colorWithAlphaComponent:.9]];
    set1.lineWidth = 1.0;
    set1.circleRadius = 2.0;
    set1.drawCircleHoleEnabled = NO;
    set1.valueFont = [UIFont systemFontOfSize:9.f];
    set1.valueTextColor = UIColor.whiteColor;
    //set1.fillAlpha = 65/255.0;
    //set1.fillColor = UIColor.blackColor;
    
    NSArray *gradientColors = @[
                                (id)[[UIColor whiteColor] colorWithAlphaComponent:0.0].CGColor,
                                (id)[[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor
                                ];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    
    set1.fillAlpha = 1.f;
    set1.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
    set1.drawFilledEnabled = YES;
    
    CGGradientRelease(gradient);
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    
    _chartView.data = data;
    */
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
    return 100;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index
{
    return (CGFloat)arc4random() + .5;
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
