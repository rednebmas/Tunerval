//
//  MigrationManager.m
//  Tunerval
//
//  Created by Sam Bender on 3/9/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "MigrationManager.h"
#import <FMDB/FMDB.h>
#import "Constants.h"

@interface MigrationManager()
{
    
}

@end

@implementation MigrationManager

+ (void) checkForAndPerformPendingMigrations
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger migrationsCompleted = [defaults integerForKey:@"migrationsCompleted"];
    switch (migrationsCompleted)
    {
        /**
         * Note: when adding new migrations, add them below the current migration so
         * that the follow migrations are also completed as well.
         */
            
        case 0:
            [MigrationManager firstMigration];
            
        default:
            break;
    }
}
             
+ (void) firstMigration
{
    // created tables
    NSString *createTable =
    @"CREATE TABLE answer_history"
    "("
        "interval                   INTEGER,"
        "reference_note             INTEGER,"
        "question_note              INTEGER,"
        "user_answer                INTEGER,"
        "correct_answer             INTEGER,"
        "difficulty                 DOUBLE,"    // measured in cents
        "time_to_answer             DOUBLE,"
        "question_note_duration     DOUBLE,"     // note duration
        "reference_note_duration    DOUBLE,"
        "question_note_loudness     DOUBLE,"     // note loudness
        "reference_note_loudness    DOUBLE,"
        "created_at     DOUBLE,"                // unix epoch
        /// game settings ///
        "note_range_from            INTEGER,"
        "note_range_to              INTEGER,"
        "note_range_span            INTEGER,"
        "note_default_duration      DOUBLE,"
        "note_duration_variation    DOUBLE"
    ");";
    
    FMDatabase *db = [Constants dbConnection];
    [db executeUpdate:createTable];
    [db close];
    
    [MigrationManager updateMigrationsCompletedTo:1];
}

+ (void) updateMigrationsCompletedTo:(NSInteger)migrationsCompleted
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:migrationsCompleted forKey:@"migrationsCompleted"];
}

@end
