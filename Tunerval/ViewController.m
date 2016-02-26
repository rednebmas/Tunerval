//
//  ViewController.m
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <PitchEstimator/SBNote.h>
#import "ViewController.h"
#import "AudioPlayer.h"

@interface ViewController ()
{
    int answer;
    double differenceInCents;
}

@property (nonatomic, retain) UIColor *backgroundColor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [SBNote setDefaultInstrumenType:InstrumentTypeSineWave];
    [self delayAskQuestion];
    differenceInCents = 25.0;
    self.backgroundColor = self.view.backgroundColor;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) flashBackgroundColor:(UIColor*)color {
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration: 0.25
                     animations: ^{
                         weakSelf.view.backgroundColor = color;
                     }
                     completion: ^(BOOL finished) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [weakSelf unflashBackgroundColor];
                         });
                     }
     ];
}

- (void) unflashBackgroundColor {
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration: 0.25
                     animations: ^{
                         weakSelf.view.backgroundColor = weakSelf.backgroundColor;
                     }
                     completion: ^(BOOL finished) {
                     }
     ];
}

- (void) delayAskQuestion {
    double delayTimeInSeconds = 1.0;
    __weak id weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf askQuestion];
    });
}

- (void) askQuestion {
    [self.label setText:@""];
    
    SBNote *a4 = [SBNote noteWithName:@"A4"];
    a4.duration = 1.0;
    
    SBNote *smallDiff;
    int random = arc4random_uniform(3);
    answer = random;
    if (random == 0) {
        smallDiff = [a4 noteWithDifferenceInCents:100.0 + differenceInCents];
        NSLog(@"higher");
    } else if (random == 1) {
        smallDiff = [a4 noteWithDifferenceInCents:100.0];
        NSLog(@"on it");
    } else {
        smallDiff = [a4 noteWithDifferenceInCents:100.0 - differenceInCents];
        NSLog(@"lower");
    }
    
    [[AudioPlayer sharedInstance] play:a4];
    
    NSLog(@"%@", smallDiff);
    
    double delayTimeInSeconds = 1.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[AudioPlayer sharedInstance] play:smallDiff];
    });
}

- (void) answer:(int)value {
    if (value == answer) {
        [self correct];
    } else {
        [self incorrect:value];
    }
    
    [self delayAskQuestion];
}

- (void) incorrect:(int)value {
    
    NSString *correctAnswer;
    switch (answer) {
        case 0:
            correctAnswer = @"higher";
            break;
            
        case 1:
            correctAnswer = @"on it";
            break;
            
        case 2:
            correctAnswer = @"lower";
            break;
            
        default:
            correctAnswer = @"???";
            break;
    }
    
    [self.label setText:[NSString stringWithFormat:@"Incorrect (answer was %@)", correctAnswer]];
    differenceInCents = 25.0;
    [self.centsDifference setText:[NSString stringWithFormat:@"±%.1fc", differenceInCents]];
    [self flashBackgroundColor:[UIColor redColor]];
}

- (void) correct {
    [self.label setText:@"Correct"];
    differenceInCents = differenceInCents * .9;
    [self.centsDifference setText:[NSString stringWithFormat:@"±%.1fc", differenceInCents]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)up:(id)sender {
    [self answer:0];
}

- (IBAction)center:(id)sender {
    [self answer:1];
}

- (IBAction)down:(id)sender {
    [self answer:2];
}


@end
