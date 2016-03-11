//
//  Constants.m
//  Tunerval
//
//  Created by Sam Bender on 3/10/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "Constants.h"
#import <FMDB/FMDB.h>

@implementation Constants

+ (FMDatabase*) dbConnection
{
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    NSString *dbPath = [documentsDir stringByAppendingPathComponent:@"db.sql"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open])
    {
        NSLog(@"WARNING: Error opening database");
    }
    
    return db;
}

@end
