//
//  WrongAnswerTeachingOverlayView.m
//  Tunerval
//
//  Created by Sam Bender on 6/15/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "WrongAnswerTeachingOverlayView.h"
#import "UIView+Helpers.h"

#define PRESSED_BUTTON_ALPHA 0.35f

@implementation WrongAnswerTeachingOverlayView

- (IBAction)dimButton:(UIButton *)sender
{
    [UIView transitionWithView:self
                      duration:.35
                       options:UIViewAnimationOptionCurveLinear
                    animations:^{
                        sender.alpha = PRESSED_BUTTON_ALPHA;
                    }
                    completion:^(BOOL completed){
                        if (self.sharpButton.alpha == PRESSED_BUTTON_ALPHA
                            && self.inTuneButton.alpha == PRESSED_BUTTON_ALPHA
                            && self.flatButton.alpha == PRESSED_BUTTON_ALPHA)
                        {
                            [self setHidden:YES animatedWithDuration:.5];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self removeFromSuperview];
                            });
                        }
                    }];
}

@end
