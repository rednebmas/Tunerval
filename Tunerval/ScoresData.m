//
//  ScoresData.m
//  Tunerval
//
//  Created by Sam Bender on 3/19/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "ScoresData.h"
#import "Constants.h"
#import <FMDB/FMDB.h>

@implementation ScoresData

+ (NSArray*) difficultyDataForInterval:(IntervalType)interval
{
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    FMResultSet *s = [[Constants dbConnection] executeQuery:@"SELECT * FROM answer_history"];
    while ([s next])
    {
        if ([s intForColumn:@"interval"] == interval)
        {
            [yVals addObject:@([s doubleForColumn:@"difficulty"])];
        }
    }
    return yVals;
}

@end
