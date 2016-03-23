//
//  ChartsOverviewViewController.m
//  Tunerval
//
//  Created by Sam Bender on 3/19/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "ChartsOverviewViewController.h"

@interface ChartsOverviewViewController ()

@end

@implementation ChartsOverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction) dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Misc

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
