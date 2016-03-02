//
//  NSAttributedString+Utilities.h
//  Tunerval
//
//  Created by Sam Bender on 3/1/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (Utilities)

+ (NSAttributedString*)attributedStringForText:(NSString *)normalText
                                  andSubscript:(NSString *)subscriptText
                                  withFontSize:(CGFloat)fontSize;

@end
