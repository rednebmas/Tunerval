//
//  ChartViewController.m
//  Tunerval
//
//  Created by Sam Bender on 3/19/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <SBGraph/SBGraphView.h>
#import "ChartViewController.h"
#import "ScoresData.h"
#import "Constants.h"
#import "Colors.h"
#import "SBEventTracker.h"

@interface ChartViewController () <SBGraphViewDelegate>

@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) NSMutableArray *xReferenceIndices;
@property (nonatomic, retain) ScoresData *scoreData;

@end

@implementation ChartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SBEventTracker trackScreenViewForScreenName:@"Chart"];
    [self configureLineGraph];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger dataRange = [defaults integerForKey:@"graph-data-range"];
    [self.dataRangeSegmentedControl setSelectedSegmentIndex:dataRange];
    
    UIColor *bgColor = [[Colors colorSetForDay:[defaults integerForKey:@"total-days-goal-met"]] firstObject];
    self.view.backgroundColor = bgColor;
    self.lineGraph.backgroundColor = bgColor;
    self.lineGraph.touchInputPointRadius = 8.0;
    [self.pickIntervalButton setBackgroundColor:[UIColor whiteColor]];
    [self.pickIntervalButton setTitleColor:self.view.backgroundColor forState:UIControlStateNormal];
    [self.exitButton setTitleColor:bgColor forState:UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
    if (self.data != nil && self.data.count > 0)
    {
        [self.lineGraph reloadData];
    }
}

- (void) loadData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // interval
    IntervalType interval = [defaults integerForKey:@"graph-selected-interval"];
    
    // data duration
    NSInteger dataRange = [defaults integerForKey:@"graph-data-range"];
    NSDate *dateForRange = [self dateForDataRange:dataRange];
    
    // get data
    IntervalType all = ALL_INTERVALS_VALUE;
    ScoresData *scoresData = [[ScoresData alloc] init];
    if (interval == all)
    {
        [self.pickIntervalButton setTitle:@"All intervals average"
                                 forState:UIControlStateNormal];
        [scoresData loadRunningAverageDifficultyAfterUnixTimeStamp:[dateForRange timeIntervalSince1970]];
        self.scoreData = scoresData;
        self.data = scoresData.dataYVals;
    }
    else
    {
        [self.pickIntervalButton setTitle:[SBNote intervalTypeToIntervalName:interval]
                                 forState:UIControlStateNormal];
        [scoresData loadDataForInterval:interval afterUnixTimestamp:[dateForRange timeIntervalSince1970]];
        self.scoreData = scoresData;
        self.data = scoresData.dataYVals;
    }
    
    //
    // X reference indices
    //
    self.xReferenceIndices = [[NSMutableArray alloc] init];
    
    NSInteger increment = MAX(1, (self.data.count + 1) / 3); // increment must be at least 1!
    NSInteger i = increment;
    while (i < self.data.count) {
        NSNumber *index = [NSNumber numberWithInteger:i];
        i += increment;
        
        [self.xReferenceIndices addObject:index];
    }
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
            date = [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
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
    self.lineGraph.enableXAxisLabels = NO;
    self.lineGraph.touchInputPointRadius = 6.0;
    self.lineGraph.colorTouchInputPoint = [[UIColor whiteColor] colorWithAlphaComponent:.65];
    
    // gradient
    UIColor *gradientFrom = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    UIColor *gradientTo = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    [self.lineGraph setGradientFromColor:gradientFrom  toColor:gradientTo];
    
    // margins
    SBGraphMargins margins = self.lineGraph.margins;
    margins.top += 10;
    margins.left += 12;
    margins.right = 15;
    margins.bottom = 15;
    self.lineGraph.margins = margins;
}

#pragma mark - SBGraphView delegate

- (CGFloat) yMin
{
    return 0;
}

- (CGFloat) yMax
{
    return 100;
}

- (NSArray*) yValues
{
    return self.data;
}

- (NSArray*) yValuesForReferenceLines
{
    return @[ @(25.0f), @(50.0f), @(75.0f) ];
}

- (NSArray*) xIndicesForReferenceLines
{
    return self.xReferenceIndices;
}

- (void) label:(UILabel *)label forYValue:(CGFloat)yValue
{
    UIFont *font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightThin];
    [label setFont:font];
    [label setText:[NSString stringWithFormat:@"±%.0fc", yValue]];
}

- (void) noDataLabel:(UILabel *)noDataLabel
{
    [noDataLabel setTextColor:[UIColor whiteColor]];
}

- (void) touchInputInfoLabel:(UILabel *)label forXIndex:(NSInteger)index
{
    NSDictionary *resultDict = self.scoreData.data[index];
    [label setTextAlignment:NSTextAlignmentLeft];
    
    IntervalType selectedIntervals = [[NSUserDefaults standardUserDefaults]
                                      integerForKey:@"graph-selected-interval"];
    IntervalType all = ALL_INTERVALS_VALUE;
    NSMutableString *text = [[NSMutableString alloc] init];
    if (selectedIntervals == all)
    {
        IntervalType interval = [resultDict[@"interval"] integerValue];
        NSString *intervalName = [SBNote intervalTypeToIntervalShorthand:interval];
        [text appendFormat:
         @"  Average value: ±%.1fc\n"
         @"  --\n"
         @"  Interval: %@\n",
         // insertions
         [self.data[index] floatValue],
         intervalName
         ];
    }
    
    [text appendFormat:
     @"  Difficulty: ±%.1fc\n"
     @"  Duration to answer: %.1fs\n"
     @"  Date: %@",
     [resultDict[@"difficulty"] floatValue],
     [resultDict[@"time_to_answer"] floatValue],
     [self formattedDateStringForUnixTimestamp:resultDict[@"created_at"]]
     ];
    
    [label setText:text];
}

#pragma mark - Actions

- (IBAction) dismiss:(id)sender
{
    // [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dataRangeValueChanged:(UISegmentedControl *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sender.selectedSegmentIndex forKey:@"graph-data-range"];
    
    [self loadData];
    [self.lineGraph reloadData];
}

#pragma mark - Misc

- (NSString*) formattedDateStringForUnixTimestamp:(NSString*)timestamp
{
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[timestamp doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/dd/yy h:mm a"];
    
    return [dateFormatter stringFromDate:time];
}

@end
