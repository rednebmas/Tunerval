//
//  ViewController.h
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBRoundProgressView;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *centsDifference;
@property (weak, nonatomic) IBOutlet UILabel *hearAgainIntervalLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *replayButton;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *intervalDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *intervalNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *spotOnButton;
@property (weak, nonatomic) IBOutlet UIButton *flatButton;
@property (weak, nonatomic) IBOutlet UIButton *sharpButton;
@property (weak, nonatomic) IBOutlet MBRoundProgressView *dailyProgressView;

@end

