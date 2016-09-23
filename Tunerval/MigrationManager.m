//
//  MigrationManager.m
//  Tunerval
//
//  Created by Sam Bender on 3/9/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <FMDB/FMDB.h>
#import <SBMusicUtilities/SBNote.h>
#import "MigrationManager.h"
#import "Constants.h"
#import "KeychainUserPass.h"

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
        
        case 1:
            [MigrationManager secondMigration];
            
        default:
            break;
    }
}
             
+ (void) firstMigration
{
    // create history table
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
        "note_range_span            INTEGER"
    ");";
    
    FMDatabase *db = [Constants dbConnection];
    [db executeUpdate:createTable];
    [db close];
    
    [MigrationManager updateMigrationsCompletedTo:1];
}

+ (void)secondMigration
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@[@(InstrumentTypeSineWave)] forKey:@"instruments"];
    [defaults setObject:@(NO) forKey:@"com.sambender.InstrumentTypePianoPurchased"];
    
    [MigrationManager updateMigrationsCompletedTo:2];
}

+ (void) updateMigrationsCompletedTo:(NSInteger)migrationsCompleted
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:migrationsCompleted forKey:@"migrationsCompleted"];
}

@end
