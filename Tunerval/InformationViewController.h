//
//  InformationViewController.h
//  Pitch
//
//  Created by Sam Bender on 1/23/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InformationViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;


@end
