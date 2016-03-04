//
//  Animation.m
//  Tunerval
//
//  Created by Sam Bender on 3/3/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Animation.h"

@implementation Animation

+ (void) slideInAndOut:(UIView*)view amount:(CGFloat)amount
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         view.transform = CGAffineTransformTranslate(view.transform, view.frame.size.width * amount, 0);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
                                          }];
                     }];
}

+ (void) scalePop:(UIView*)view toScale:(CGFloat)scale
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(scale, scale);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.25
                                          animations:^{
                                              view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                          }];
                     }];
}

+ (void) rotateWiggle:(UIView *)view
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         view.transform = CGAffineTransformMakeRotation(-M_PI/32);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              view.transform = CGAffineTransformMakeRotation(M_PI/32);
                                          }
                                          completion:^(BOOL finshed){
                                              [UIView animateWithDuration:.25
                                                               animations:^{
                                                                   view.transform = CGAffineTransformMakeRotation(0);
                                                               }];
                                          }];
                         
                     }];
}

/**
 * http://stackoverflow.com/questions/11571420/catransform3drotate-rotate-for-360-degrees
 */
+ (void) rotateOverXAxis:(UIView*)view forwards:(BOOL)isForwards
{
    CALayer *layer = view.layer;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -50;
    layer.transform = transform;
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = .75;
    if (isForwards)
    {
        animation.values = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 0 * M_PI / 2, 1, 0, 0)],
                            [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * M_PI / 2, 1, 0, 0)],
                            [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 2 * M_PI / 2, 1, 0, 0)],
                            [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 3 * M_PI / 2, 1, 0, 0)],
                            [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 4 * M_PI / 2, 1, 0, 0)],
                            nil];
    }
    else
    {
        animation.values = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 0 * -M_PI / 2, 1, 0, 0)],
                            [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * -M_PI / 2, 1, 0, 0)],
                            [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 2 * -M_PI / 2, 1, 0, 0)],
                            [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 3 * -M_PI / 2, 1, 0, 0)],
                            [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 4 * -M_PI / 2, 1, 0, 0)],
                            nil];
    }
    
    [layer addAnimation:animation forKey:animation.keyPath];
}

+ (void) flashBackgroundColor:(UIColor*)color ofView:(UIView*)view
{
    UIColor *originalBGColor = view.backgroundColor;
    [UIView animateWithDuration: 0.25
                     animations: ^{
                         view.backgroundColor = color;
                     }
                     completion: ^(BOOL finished) {
                         [UIView animateWithDuration: 0.25
                                          animations: ^{
                                              view.backgroundColor = originalBGColor;
                                          }];
                     }
     ];
}

@end
