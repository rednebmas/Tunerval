//
//  ChartViewController.h
//  Tunerval
//
//  Created by Sam Bender on 3/19/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BEMSimpleLineGraphView;

@interface ChartViewController : UIViewController

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *lineGraph;

@end
