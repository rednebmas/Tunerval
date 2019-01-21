//
//  SBCircular.m
//  PitchEstimation
//
//  Created by Sam Bender on 12/16/15.
//  Copyright © 2015 Sam Bender. All rights reserved.
//

#import "SBCircular.h"

@interface SBCircular()

@property (nonatomic) long long index;
@property (nonatomic, readwrite) NSUInteger size;

@end

@implementation SBCircular

- (id) initWithSize:(NSUInteger)size
{
    self = [self init];
    if (self)
    {
        self.size = size;
    }
    return self;
}

- (NSUInteger) next
{
    return [self circularIndexForIndex:self.index++];
}

- (NSUInteger) circularIndexForIndex:(NSUInteger)index
{
    return (self.index + index) % self.size;
}

@end
