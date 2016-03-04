//
//  ViewController.m
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <PitchEstimator/SBNote.h>
#import "ViewController.h"
#import "AudioPlayer.h"
#import "RandomNoteGenerator.h"
#import "UIView+Helpers.h"
#import "Question.h"
#import "MBRoundProgressView.h"
#import "Animation.h"

#define MAX_DIFF_ONE_INTERVAL 100.0
#define MAX_DIFF_TWO_OR_MORE_INTERVALS 100.0
static float MAX_DIFFERENCE = MAX_DIFF_ONE_INTERVAL;

@interface ViewController ()
{
    int answer;
    float differenceInCents;
    NSInteger dailyProgressGoal;
    NSUserDefaults *defaults;
}

@property (nonatomic) BOOL speakInterval;
@property (nonatomic) int answerDifferential; // positive values means you got x more correct than incorrect
@property (nonatomic) int correctStreak; // positive values means you got x more correct than incorrect
@property (nonatomic, retain) NSString *highScoreKey;
@property (nonatomic, retain) NSArray *intervals;
@property (nonatomic, retain) Question *currentQuestion;
@property (nonatomic, retain) RandomNoteGenerator *randomNoteGenerator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    defaults = [NSUserDefaults standardUserDefaults];
    [SBNote setDefaultInstrumenType:InstrumentTypeSineWave];
    [self reloadIntervals];
    self.randomNoteGenerator = [[RandomNoteGenerator alloc] init];
    [self reloadNoteRange];
    [[AudioPlayer sharedInstance] setGain:1.0];
    [self hideHearAnswersLabel:YES];
    [self.label setText:@""];
    self.nextButton.hidden = YES;
    [self.intervalDirectionLabel setText:@""];
    [self.intervalNameLabel setText:@""];
}

- (void) viewWillAppear:(BOOL)animated
{
    // Called when dismissing settings
    [self reloadIntervals];
    [self reloadNoteRange];
    [self reloadDailyProgressGoal];
    [self reloadDailyProgress];
    [self reloadSpeakInterval];
}

- (void) reloadSpeakInterval
{
    self.speakInterval = [[defaults objectForKey:@"speak-interval-on"] boolValue];
}

- (void) reloadDailyProgressGoal
{
    dailyProgressGoal = [[[NSUserDefaults standardUserDefaults] objectForKey:@"daily-goal"] integerValue];
}

- (void) reloadDailyProgress
{
    NSInteger questionsAnswered = [[[NSUserDefaults standardUserDefaults]
                                    objectForKey:[self dailyProgressKey]] integerValue];
    self.dailyProgressView.progress = (float)questionsAnswered / (float)dailyProgressGoal;
}

- (NSString*) dailyProgressKey
{
    NSDate *beginningOfDay = [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
    return [NSString stringWithFormat:@"questions-answered-%f", beginningOfDay.timeIntervalSince1970];
}


- (void) incrementDailyProgress
{
    NSString *dailyProgressKey = [self dailyProgressKey];
    NSInteger questionsAnswered = [[[NSUserDefaults standardUserDefaults]
                                    objectForKey:dailyProgressKey] integerValue];
    NSNumber *incremented = [NSNumber numberWithInteger:questionsAnswered+1];
    [[NSUserDefaults standardUserDefaults] setObject:incremented forKey:dailyProgressKey];
    [self reloadDailyProgress];
}

- (void) reloadNoteRange
{
    NSString *fromNote = [[NSUserDefaults standardUserDefaults] objectForKey:@"from-note"];
    NSString *toNote = [[NSUserDefaults standardUserDefaults] objectForKey:@"to-note"];
    [self.randomNoteGenerator setRangeFrom:[SBNote noteWithName:fromNote]
                                        to:[SBNote noteWithName:toNote]];
}

- (void) reloadIntervals
{
    // if different, reset game info
    NSArray *intervals = [[NSUserDefaults standardUserDefaults] objectForKey:@"selected_intervals"];
    
    // high scores are unique to interval sets
    NSUInteger hash = [self intervalSetHash:intervals];
    self.highScoreKey = [NSString stringWithFormat:@"highscore-%lu", hash];
    float highScoreFloat = [[NSUserDefaults standardUserDefaults]
                            floatForKey:self.highScoreKey];
    
    // if new game type
    if (highScoreFloat == 0)
    {
        [[NSUserDefaults standardUserDefaults] setFloat:MAX_DIFFERENCE forKey:self.highScoreKey];
        highScoreFloat = MAX_DIFFERENCE;
    }
    
    if (![self.intervals isEqual:intervals])
    {
        // kinda like game reset
        float highScoreAnswerDifferetial = [[NSUserDefaults standardUserDefaults]
                                       floatForKey:[NSString stringWithFormat:@"%@-answerdifferential",
                                                    self.highScoreKey]];
        // start them close to high score
        if (highScoreAnswerDifferetial > 8)
        {
            self.answerDifferential = highScoreAnswerDifferetial - 8;
        }
        else
        {
            self.answerDifferential = 0;
        }
        [self calculateDifferenceInCents];
        
        [self.intervalDirectionLabel setText:@""];
        [self.intervalNameLabel setText:@""];
        [self hideHearAnswersLabel:YES];
        [self delayAskQuestion];
    }
    self.intervals = intervals;
    
    // change label text
    NSString *highScore = [NSString stringWithFormat:@"±%.1fc", highScoreFloat];
    [self.highScoreLabel setText:highScore];
}

- (NSUInteger) intervalSetHash:(NSArray*)intervalSet
{
    NSArray *sorted = [intervalSet sortedArrayUsingSelector:@selector(compare:)];
    NSUInteger hash = 17;
    for (NSNumber *interval in sorted)
    {
        hash = hash * 31 + [interval integerValue];
    }
    return hash;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) delayAskQuestion {
    double delayTimeInSeconds = 1.0;
    __weak id weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf askQuestion];
    });
}

- (void) askQuestion {
    [self.label setText:@""];
    if (self.hearAgainIntervalLabel.hidden == NO) {
        [self hideHearAnswersLabel:NO];
    }
    
    self.currentQuestion = [self generateQuestion];
    
    [self setDirectionLabelTextForInterval:self.currentQuestion.interval];
    [self setIntervalNameLabelTextForInterval:self.currentQuestion.interval];
    
    if (self.speakInterval)
    {
        IntervalType interval = self.currentQuestion.interval;
        NSString *intervalDirection = [self directionLabelTextForInterval:interval];
        NSString *fullIntervalName = [NSString stringWithFormat:@"%@ %@",
                                      intervalDirection,
                                      [SBNote intervalTypeToIntervalName:interval]];
        [self speak:fullIntervalName];
    }
    
    // gives player time to read interval name
    double delayTimeInSeconds = self.speakInterval ? 1.8 : .5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self playNote:self.currentQuestion.referenceNote thenPlay:self.currentQuestion.questionNote];
    });
    
    NSLog(@"%@\n%@", self.currentQuestion.referenceNote, self.currentQuestion.questionNote);
}

- (void) playNote:(SBNote*)firstNote thenPlay:(SBNote*)secondNote
{
    [[AudioPlayer sharedInstance] play:firstNote];
    
    double delayTimeInSeconds = firstNote.duration + .1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[AudioPlayer sharedInstance] play:secondNote];
    });
}

- (Question*) generateQuestion
{
    SBNote *referenceNote = [self.randomNoteGenerator nextNote];
    referenceNote.duration = 1.0;
    
    SBNote *smallDiff;
    NSNumber *randomIntervalObject = self.intervals[arc4random_uniform((uint)self.intervals.count)];
    IntervalType interval = [randomIntervalObject integerValue];
    int random = arc4random_uniform(3);
    answer = random;
    if (random == 0)
    {
        smallDiff = [referenceNote noteWithDifferenceInCents:(double)interval * 100.0 + differenceInCents];
        NSLog(@"higher");
    }
    else if (random == 1)
    {
        smallDiff = [referenceNote noteWithDifferenceInCents:(double)interval * 100.0];
        NSLog(@"on it");
    }
    else
    {
        smallDiff = [referenceNote noteWithDifferenceInCents:(double)interval * 100.0 - differenceInCents];
        NSLog(@"lower");
    }
    
    // randomly change loudness to be between .7 and 1.0 and always have one note at 1.0
    float upOrDown = drand48();
    if (upOrDown > .5)
    {
        referenceNote.loudness = 1.0 - .3 * drand48();
    }
    else
    {
        smallDiff.loudness = 1.0 - .3 * drand48();
    }
    double duration = [defaults doubleForKey:@"note-duration"];
    double durationVariation = [defaults doubleForKey:@"note-duration-variation"];
    smallDiff.duration = duration + (drand48() * durationVariation - durationVariation/2);
    referenceNote.duration = duration + (drand48() * durationVariation - durationVariation/2);
    
    // create question object
    Question *question = [[Question alloc] init];
    question.referenceNote = referenceNote;
    question.questionNote = smallDiff;
    question.interval = interval;
    
    return question;
}

- (void) setDirectionLabelTextForInterval:(IntervalType)interval
{
    NSString *newDirection = [self directionLabelTextForInterval:interval];
    if ([newDirection isEqualToString:self.intervalDirectionLabel.text] == NO)
    {
        [Animation scalePop:self.intervalDirectionLabel toScale:1.2];
    }
    
    [self.intervalDirectionLabel setText:newDirection];
}

- (void) setIntervalNameLabelTextForInterval:(IntervalType)interval
{
    NSString *newIntervalName = [SBNote intervalTypeToIntervalName:interval];
    if ([newIntervalName isEqualToString:self.intervalNameLabel.text] == NO)
    {
        [Animation rotateWiggle:self.intervalNameLabel];
    }
    
    [self.intervalNameLabel setText:newIntervalName];
}

- (NSString*) directionLabelTextForInterval:(IntervalType)interval
{
    if (interval > 0)
    {
        return @"ascending";
    }
    else if (interval == 0)
    {
        return @"";
    }
    else
    {
        return @"descending";
    }
}

- (void) answer:(int)value {
    if (value == answer) {
        [self correct];
        [self delayAskQuestion];
    } else {
        [self incorrect:value];
    }
    
    NSInteger questionsAnsweredTotal = [[NSUserDefaults standardUserDefaults] integerForKey:@"questions-answered-total"];
    [[NSUserDefaults standardUserDefaults] setInteger:++questionsAnsweredTotal forKey:@"questions-answered-total"];
    [self incrementDailyProgress];
}

- (void) incorrect:(int)value {
    NSString *correctAnswer;
    switch (answer)
    {
        case 0:
            correctAnswer = @"sharp";
            [Animation scalePop:self.sharpButton toScale:1.2];
            break;
            
        case 1:
            correctAnswer = @"in tune";
            [Animation scalePop:self.spotOnButton toScale:1.2];
            break;
            
        case 2:
            correctAnswer = @"flat";
            [Animation scalePop:self.flatButton toScale:1.2];
            break;
            
        default:
            correctAnswer = @"???";
            break;
    }
    
    if (self.speakInterval)
    {
        [self speak:@"Incorrect"];
    }
    
    // if the user chooses sharp when flat or flat when sharp this will subtract two
    self.answerDifferential -= abs(value - answer);
    self.correctStreak = 0;
    
    [self.label setAttributedText:[self correctAnswerBolded:correctAnswer]];
    [Animation flashBackgroundColor:[UIColor redColor] ofView:self.view];
    [self hideHearAnswersLabel:NO];
    NSLog(@"%d", self.answerDifferential);
}

- (NSAttributedString*) correctAnswerBolded:(NSString*)correctAnswer
{
    NSString *concat = [NSString stringWithFormat:@"Incorrect\nAnswer: %@", correctAnswer];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc]
                                             initWithString:concat];
    
    CGFloat fontSize = self.label.font.pointSize;
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:fontSize]
                       range:NSMakeRange(18, correctAnswer.length)];
    
    return attrString;
}

- (void) correct
{
    [Animation rotateOverXAxis:self.centsDifference forwards:YES];
    
    // move faster if we have got several correct in a row
    self.correctStreak++;
    if (self.correctStreak > 7)
    {
        int speed = 2;
        if (self.correctStreak > 10)
        {
            speed = 3;
        }
        else if (self.correctStreak > 15)
        {
            speed = 4;
        }
        
        self.answerDifferential += speed;
    }
    else
    {
        self.answerDifferential++;
    }
    [self.label setText:@"Correct"];
    [self calculateDifferenceInCents];
    NSLog(@"%d", self.answerDifferential);
    
}

- (void) hideHearAnswersLabel:(BOOL)makeHidden
{
    if (makeHidden)
    {
        self.hearAgainIntervalLabel.hidden = YES;
        [self.hearAgainIntervalLabel setText:@""];
        self.replayButton.hidden = NO;
        self.nextButton.hidden = YES;
    }
    else
    {
        self.hearAgainIntervalLabel.hidden = NO;
        [self.hearAgainIntervalLabel setText:@"To hear the correct interval, press the target button"];
        self.replayButton.hidden = YES;
        self.nextButton.hidden = NO;
    }
}

- (void) calculateDifferenceInCents
{
    if (self.answerDifferential > 0)
    {
        differenceInCents = MAX_DIFFERENCE * pow(.965, (double)self.answerDifferential);
    }
    else
    {
        differenceInCents = MAX_DIFFERENCE;
    }
    
    // check for high score
    if (differenceInCents < [[NSUserDefaults standardUserDefaults] floatForKey:self.highScoreKey])
    {
        // difference in cents high score
        [[NSUserDefaults standardUserDefaults] setFloat:differenceInCents
                                                 forKey:self.highScoreKey];
        // answer differential so we can calculate size of growing text
        [[NSUserDefaults standardUserDefaults] setInteger:self.answerDifferential
                                                   forKey:[NSString stringWithFormat:@"%@-answerdifferential", self.highScoreKey]];
        [self.highScoreLabel setText:[NSString stringWithFormat:@"±%.1fc", differenceInCents]];
        [Animation scalePop:self.highScoreLabel toScale:2.5];
    }
    
    NSLog(@"calculated diff: %.2f", differenceInCents);
    
    [self.centsDifference setText:[NSString stringWithFormat:@"±%.1fc", differenceInCents]];
}

- (void) speak:(NSString*)text
{
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance
                                    speechUtteranceWithString:text];
    [utterance setRate:0.5f];
    utterance.volume = .9f;
    [synthesizer speakUtterance:utterance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)up:(id)sender {
    if (self.nextButton.hidden)
    {
        [self answer:0];
    }
    else
    {
        double difference = self.currentQuestion.interval * 100.0 + differenceInCents;
        SBNote *up = [self.currentQuestion.referenceNote noteWithDifferenceInCents:difference];
        up.loudness = self.currentQuestion.questionNote.loudness;
        up.duration = self.currentQuestion.questionNote.duration;
        [self playNote:self.currentQuestion.referenceNote thenPlay:up];
    }
}

- (IBAction)center:(id)sender {
    if (self.nextButton.hidden)
    {
        [self answer:1];
    }
    else
    {
        double difference = self.currentQuestion.interval * 100.0;
        SBNote *up = [self.currentQuestion.referenceNote noteWithDifferenceInCents:difference];
        up.loudness = self.currentQuestion.questionNote.loudness;
        up.duration = self.currentQuestion.questionNote.duration;
        [self playNote:self.currentQuestion.referenceNote thenPlay:up];
    }
}

- (IBAction)down:(id)sender {
    if (self.nextButton.hidden)
    {
        [self answer:2];
    }
    else
    {
        double difference = self.currentQuestion.interval * 100.0 - differenceInCents;
        SBNote *up = [self.currentQuestion.referenceNote noteWithDifferenceInCents:difference];
        up.loudness = self.currentQuestion.questionNote.loudness;
        up.duration = self.currentQuestion.questionNote.duration;
        [self playNote:self.currentQuestion.referenceNote thenPlay:up];
    }
}

- (IBAction)nextButtonPressed:(UIButton*)sender
{
    [Animation rotateOverXAxis:self.centsDifference forwards:NO];
    [self askQuestion];
    [self calculateDifferenceInCents];
    sender.hidden = YES;
    [self hideHearAnswersLabel:YES];
}

- (IBAction)replayButtonPressed:(id)sender
{
    [self playNote:self.currentQuestion.referenceNote thenPlay:self.currentQuestion.questionNote];
}


@end
