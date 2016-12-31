//
//  Question.m
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <FMDB/FMDB.h>
#import <AWSMobileAnalytics/AWSMobileAnalytics.h>
#import "Question.h"
#import "Constants.h"

@interface Question()
{
    NSDate *start;
    BOOL logged;
}

@property (nonatomic, assign) NSInteger onIncorrectAnswerListens;

@end

@implementation Question

static const NSInteger ERROR_INTEGER_VALUE = -112358;
- (NSInteger)cleanInteger:(NSInteger)integer
{
    if (isnan(integer)) {
        return ERROR_INTEGER_VALUE;
    } else if (integer == INFINITY) {
        return ERROR_INTEGER_VALUE;
    }
    
    return integer;
}

static const double ERROR_DOUBLE_VALUE = -112358.13;
- (double)cleanDouble:(double)value
{
    if (isnan(value)) {
        return ERROR_DOUBLE_VALUE;
    } else if (value == INFINITY) {
        return ERROR_DOUBLE_VALUE;
    }
    
    return value;
}

static const int ERROR_INT_VALUE = -112358;
- (int)cleanInt:(int)value
{
    if (isnan(value)) {
        return ERROR_INT_VALUE;
    } else if (value == INFINITY) {
        return ERROR_INT_VALUE;
    }
    
    return value;
}

- (NSString*)cleanString:(NSString*)string
{
    if (string == nil || [string isEqualToString:@""]) {
        return @"ERROR";
    }
    
    return string;
}

- (void) logToDBWithUserAnswer:(int)userAnswer
                 correctAnswer:(int)correctAnswer
                    difficulty:(double)difficulty
                 noteRangeFrom:(int)noteRangeFrom
                   noteRangeTo:(int)noteRangeTo
{
    if (logged)
        return;
    else
        logged = YES;
    
    NSTimeInterval timeToAnswer = [[NSDate date] timeIntervalSinceDate:start];
    NSString *instrument = [SBNote instrumentNameForInstrumentType:self.questionNote.instrumentType];
    
    // record to AWS analytics
    if (DEBUGMODE == NO)
    {
        id<AWSMobileAnalyticsEventClient> eventClient = [MOBILE_ANALYTICS eventClient];
        id<AWSMobileAnalyticsEvent> questionEvent = [eventClient
                                                      createEventWithEventType:@"QuestionAnswered"];
        
        [questionEvent addMetric:@([self cleanInteger:self.interval]) forKey:@"Interval"];
        [questionEvent addMetric:@([self cleanDouble:difficulty]) forKey:@"Difficulty"];
        [questionEvent addMetric:@([self cleanInt:self.referenceNote.halfStepsFromA4]) forKey:@"HalfStepsFromA4"];
        [questionEvent addMetric:@([self cleanDouble:timeToAnswer]) forKey:@"TimeToAnswer"];
        [questionEvent addMetric:@([self cleanInteger:self.onIncorrectAnswerListens]) forKey:@"OnIncorrectAnswerListens"];
        [questionEvent addMetric:@([self cleanInt:correctAnswer]) forKey:@"CorrectAnswer"];
        [questionEvent addMetric:@([self cleanInt:userAnswer]) forKey:@"UserAnswer"];
        [questionEvent addAttribute:[self cleanString:instrument] forKey:@"Instrument"];
        
        [eventClient recordEvent:questionEvent];
    }

    NSString *query = [NSString stringWithFormat:
    @"INSERT INTO answer_history"
    "("
        "interval,"
        "reference_note,"
        "question_note,"
        "user_answer,"
        "correct_answer,"
        "difficulty,"    // measured in cents
        "time_to_answer,"
        "question_note_duration,"     // note duration
        "reference_note_duration,"
        "question_note_loudness,"     // note loudness
        "reference_note_loudness,"
        "created_at,"                // unix epoch
        "on_incorrect_answer_listens,"
        /// game settings ///
        "note_range_span,"
        "instrument"
    ")"
    "VALUES"
    "("
        "%d,"  // interval
        "%d,"   // reference note
        "%d,"   // question note
        "%d,"   // user answer
        "%d,"   // correct answer
        "%f,"  // difficulty
        "%f,"  // time to answer
        "%f,"  // question note duration
        "%f,"  // reference note duration
        "%f,"  // question note loudness
        "%f,"  // reference note loudness
        "%f," // created at
        "%d," // created at
        /// game settings ///
        "%d,"   // note range span
        "'%@'"   // instrument
    ");"
    ,
        (int)self.interval,
        self.referenceNote.halfStepsFromA4,
        self.questionNote.halfStepsFromA4,
        userAnswer,
        correctAnswer,
        difficulty,
        timeToAnswer,
        self.questionNote.duration,
        self.referenceNote.duration,
        self.questionNote.loudness,
        self.referenceNote.loudness,
        [[NSDate date] timeIntervalSince1970],
        (int)self.onIncorrectAnswerListens,
        noteRangeTo - noteRangeFrom,
        instrument
    ];
    
    // NSLog(@"%@", query);
    
    FMDatabase *db = [Constants dbConnection];
    if (![db executeUpdate:query])
    {
        NSLog(@"DBERROR = %@", [db lastErrorMessage]);
    }
    [db close];
}

- (void) markStartTime
{
    if (start == nil)
    {
        start = [NSDate date];
    }
}

- (void)incrementOnIncorrectAnswerListens
{
    self.onIncorrectAnswerListens++;
}

@end
