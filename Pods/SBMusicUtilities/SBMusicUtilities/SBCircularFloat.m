//
//  SBCircularFloat.m
//  PitchEstimation
//
//  Created by Sam Bender on 12/16/15.
//  Copyright © 2015 Sam Bender. All rights reserved.
//

#import "SBCircularFloat.h"
#import "SBCircular.h"
#import "SBMath.h"

@interface SBCircularFloat()

@property (nonatomic) SBCircular *circularCounter;
@property (nonatomic) float* data;
@property (nonatomic, readwrite) float average;

@end

@implementation SBCircularFloat

- (id) initWithSize:(NSUInteger)size
{
    self = [super init];
    if (self)
    {
        self.average = 0.0;
        self.circularCounter = [[SBCircular alloc] initWithSize:size];
        
        self.data = malloc(size * sizeof(float));
        for (int i = 0; i < size; i++)
        {
            self.data[i] = 0;
        }
    }
    return self;
}

- (void) dealloc
{
    free(self.data);
}

- (void) addValue:(float)value
{
    NSUInteger index = [self.circularCounter next];
    self.data[index] = value;
}

- (float) average
{
    return [SBMath meanOf:self.data ofSize:(UInt32)self.circularCounter.size];
}

@end
