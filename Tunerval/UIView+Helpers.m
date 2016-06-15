//
//  UIView+Helpers.m
//  Cast 2
//
//  Created by Sam Bender on 8/23/15.
//  Copyright (c) 2015 Sam Bender. All rights reserved.
//

#import "UIView+Helpers.h"

@implementation UIView (Helpers)

- (void) setHidden:(BOOL)hidden
      withDuration:(CGFloat)duration
      onCompletion:(void(^)())callback
{
    if (duration == 0) [self setHidden:hidden];
    
    if (self.hidden || self.alpha == 0)
    {
        [self setHidden:NO];
        self.alpha = 0;
        [UIView transitionWithView:self
                          duration:duration
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            [self setAlpha:1.0];
                        } completion:^(BOOL finished) {
                            [self setAlpha:1.0];
                            
                            if (callback != nil)
                            {
                                callback();
                            }
                        }];
    }
    else
    {
        self.alpha = 1;
        [self setNeedsDisplay];
        [UIView transitionWithView:self
                          duration:duration
                           options:UIViewAnimationOptionCurveLinear
                        animations:^{
                            [self setAlpha:0.0];
                        } completion:^(BOOL finished) {
                            [self setHidden:YES];
                            
                            if (callback != nil)
                            {
                                callback();
                            }
                        }];
    }
}

- (void) setHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self setHidden:hidden withDuration:animated ? 0.2 : 0 onCompletion:nil];
}

- (void) setHidden:(BOOL)hidden animatedWithDuration:(CGFloat)duration
{
    [self setHidden:hidden withDuration:duration onCompletion:nil];
}

- (void) centerIn:(CGRect)rect withSize:(CGSize)size
{
    self.frame = [self centeredFrameIn:rect withSize:size];
}

- (void) centerIn:(CGRect)rect withSize:(CGSize)size originOffset:(CGPoint)offset;
{
    CGRect newFrame = [self centeredFrameIn:rect withSize:size];
    newFrame.origin.x += offset.x;
    newFrame.origin.y += offset.y;
    self.frame = newFrame;
}

- (void) alignBottomToCenterIn:(CGRect)rect withSize:(CGSize)size;
{
    CGRect newFrame = [self centeredFrameIn:rect withSize:size];
    newFrame.origin.y -= size.height / 2;
    self.frame = newFrame;
}

- (void) alignTopToBottomIn:(CGRect)rect withSize:(CGSize)size originOffset:(CGPoint)offset
{
    CGFloat x = rect.size.width  / 2 - (size.width  / 2) + offset.x;
    CGFloat y = rect.size.height + offset.y;
    
    CGRect newFrame = CGRectMake(x, y, size.width, size.height);
    self.frame = newFrame;
}

- (CGRect) centeredFrameIn:(CGRect)rect
{
    return [self centeredFrameIn:rect withSize:self.frame.size];
}

- (CGRect) centeredFrameIn:(CGRect)rect withSize:(CGSize)size
{
    CGFloat x = rect.size.width  / 2 - (size.width  / 2);
    CGFloat y = rect.size.height / 2 - (size.height / 2);
    
    CGRect newFrame = CGRectMake(x, y, size.width, size.height);
    return newFrame;
}

@end
