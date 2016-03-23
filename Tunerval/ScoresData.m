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

+ (NSArray*) data
{
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    FMResultSet *s = [[Constants dbConnection] executeQuery:@"SELECT * FROM answer_history"];
    while ([s next])
    {
        if ([s intForColumn:@"interval"] == -4)
        {
            [yVals addObject:@([s doubleForColumn:@"difficulty"])];
        }
    }
    return yVals;
}

@end
