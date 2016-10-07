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
}

@property (nonatomic, assign) int onIncorrectAnswerListens;

@end

@implementation Question

- (void) logToDBWithUserAnswer:(int)userAnswer
                 correctAnswer:(int)correctAnswer
                    difficulty:(double)difficulty
                 noteRangeFrom:(int)noteRangeFrom
                   noteRangeTo:(int)noteRangeTo
{
    NSTimeInterval timeToAnswer = [[NSDate date] timeIntervalSinceDate:start];
    NSString *instrument = [SBNote instrumentNameForInstrumentType:self.questionNote.instrumentType];
    
    // record to AWS analytics
    if (DEBUGMODE == NO)
    {
        id<AWSMobileAnalyticsEventClient> eventClient = [MOBILE_ANALYTICS eventClient];
        id<AWSMobileAnalyticsEvent> questionEvent = [eventClient
                                                      createEventWithEventType:@"QuestionAnswered"];
        
        [questionEvent addMetric:@((int)self.interval) forKey:@"Interval"];
        [questionEvent addMetric:@(difficulty) forKey:@"Difficulty"];
        [questionEvent addMetric:@(self.referenceNote.halfStepsFromA4) forKey:@"HalfStepsFromA4"];
        [questionEvent addMetric:@(timeToAnswer) forKey:@"TimeToAnswer"];
        [questionEvent addMetric:@(self.onIncorrectAnswerListens) forKey:@"OnIncorrectAnswerListens"];
        [questionEvent addMetric:@(correctAnswer) forKey:@"CorrectAnswer"];
        [questionEvent addMetric:@(userAnswer) forKey:@"UserAnswer"];
        [questionEvent addAttribute:instrument forKey:@"Instrument"];
        
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
        self.onIncorrectAnswerListens,
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
