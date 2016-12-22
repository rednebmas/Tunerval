//
//  InformationViewController.m
//  Pitch
//
//  Created by Sam Bender on 1/23/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "InformationViewController.h"
#import "SBEventTracker.h"

@interface InformationViewController ()

@end

@implementation InformationViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [SBEventTracker trackScreenViewForScreenName:@"Information"];
    
    NSString *urlString = @"https://s3-us-west-2.amazonaws.com/sambender.com/tunerval/index.html";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *httpRequest = [NSURLRequest requestWithURL:url];
    
    self.webView.delegate = self;
    [self.webView loadRequest:httpRequest];
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

@end
