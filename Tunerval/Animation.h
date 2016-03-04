//
//  Animation.h
//  Tunerval
//
//  Created by Sam Bender on 3/3/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Animation : NSObject

+ (void) scalePop:(UIView*)view toScale:(CGFloat)scale;
+ (void) rotateWiggle:(UIView*)view;
+ (void) rotateOverXAxis:(UIView*)view forwards:(BOOL)isForwards;
+ (void) flashBackgroundColor:(UIColor*)color ofView:(UIView*)view;

@end
