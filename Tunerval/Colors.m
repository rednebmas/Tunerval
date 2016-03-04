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
        colors = @[
                                     @[
                                         UIColorFromHex(0x6CCA25),
                                         UIColorFromHex(0x4EB222) // replay button background
                                         ],
                                     @[
                                         UIColorFromHex(0xC04351),
                                         UIColorFromHex(0xC65562)
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
                                         ]
                                     ];
    });
    return colors[day % colors.count];
}


@end
