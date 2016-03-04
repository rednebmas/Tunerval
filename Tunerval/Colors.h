//
//  Colors.h
//  Tunerval
//
//  Created by Sam Bender on 3/4/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromHex(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface Colors : NSObject

+ (NSArray*) colorSetForDay:(NSInteger)day;

@end
