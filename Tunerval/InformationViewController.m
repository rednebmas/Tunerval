//
//  InformationViewController.m
//  Pitch
//
//  Created by Sam Bender on 1/23/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "InformationViewController.h"

@interface InformationViewController ()

@end

@implementation InformationViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *urlString = @"https://dl.dropboxusercontent.com/u/5301042/tunerval/tunerval.html";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *httpRequest = [NSURLRequest requestWithURL:url];
    
    self.webView.delegate = self;
    [self.webView loadRequest:httpRequest];
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web view delegate

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Actions

- (IBAction) doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
