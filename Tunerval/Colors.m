//
//  Colors.m
//  Tunerval
//
//  Created by Sam Bender on 3/4/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "Colors.h"

@implementation Colors

+ (NSArray*) colorSetForDay:(NSInteger)day
{
    static NSArray *colors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Add 7 to brightness for replay button bg
        colors = @[
                                     @[
                                         UIColorFromHex(0xC04351),
                                         UIColorFromHex(0xC65562) // replay button background
                                         ],
                                     @[
                                         UIColorFromHex(0x6B1AA2),
                                         UIColorFromHex(0x821DCA)
                                         ],
                                     @[
                                         UIColorFromHex(0x008BB2),
                                         UIColorFromHex(0x1997C6)
                                         ],
                                     @[ // dark greenish
                                         UIColorFromHex(0x283D3B),
                                         UIColorFromHex(0x2E4A46)
                                         ],
                                     @[
                                         UIColorFromHex(0x574B90),
                                         UIColorFromHex(0x6053A0)
                                         ],
                                     @[
                                         UIColorFromHex(0x537780),
                                         UIColorFromHex(0x5E8791)
                                         ],
                                     @[
                                         UIColorFromHex(0x29A19C),
                                         UIColorFromHex(0x2CB2AE)
                                         ],
                                     ];
    });
    return colors[day % colors.count];
}


@end
