//
//  SBCircular.h
//  PitchEstimation
//
//  Created by Sam Bender on 12/16/15.
//  Copyright © 2015 Sam Bender. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBCircular : NSObject

@property (nonatomic, readonly) NSUInteger size;

- (id) initWithSize:(NSUInteger)size;
- (NSUInteger) next;

@end
