//
//  NSAttributedString+Utilities.m
//  Tunerval
//
//  Created by Sam Bender on 3/1/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "NSAttributedString+Utilities.h"

@implementation NSAttributedString (Utilities)

+ (NSAttributedString*)attributedStringForText:(NSString *)normalText
                                  andSubscript:(NSString *)subscriptText
                                  withFontSize:(CGFloat)fontSize
{
    NSString *combined = [NSString stringWithFormat:@"%@%@", normalText, subscriptText];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]
                                             initWithString:combined];
    // style normal text
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:fontSize]
                       range:NSMakeRange(0, normalText.length)];
    
    // style subscript
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:fontSize/2.0]
                       range:NSMakeRange(normalText.length, subscriptText.length)];
    [attrString addAttribute:NSBaselineOffsetAttributeName
                       value:@(-fontSize/4.0)
                       range:NSMakeRange(normalText.length, subscriptText.length)];
    
    return attrString;
}

@end
