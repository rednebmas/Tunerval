//
//  ChartViewController.h
//  Tunerval
//
//  Created by Sam Bender on 3/19/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LineChartView;

@interface ChartViewController : UIViewController

@property (weak, nonatomic) IBOutlet LineChartView *chartView;

@end
