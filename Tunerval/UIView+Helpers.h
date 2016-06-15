//
//  UIView+Helpers.h
//  Cast 2
//
//  Created by Sam Bender on 8/23/15.
//  Copyright (c) 2015 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Helpers)

- (void) setHidden:(BOOL)hidden animated:(BOOL)animated;
- (void) setHidden:(BOOL)hidden animatedWithDuration:(CGFloat)duration;
- (void) setHidden:(BOOL)hidden
      withDuration:(CGFloat)duration
      onCompletion:(void(^)())callback;

- (void) centerIn:(CGRect)rect withSize:(CGSize)size originOffset:(CGPoint)offset;
- (void) centerIn:(CGRect)rect withSize:(CGSize)size;
- (void) alignBottomToCenterIn:(CGRect)rect withSize:(CGSize)size;
- (void) alignTopToBottomIn:(CGRect)rect withSize:(CGSize)size originOffset:(CGPoint)offset;

- (CGRect) centeredFrameIn:(CGRect)rect withSize:(CGSize)size;
- (CGRect) centeredFrameIn:(CGRect)rect;

@end
