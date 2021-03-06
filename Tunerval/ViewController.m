//
//  ViewController.m
//  Tunerval
//
//  Created by Sam Bender on 2/26/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <Crashlytics/Crashlytics.h>
#import <SBMusicUtilities/SBNote.h>
#import <SBMusicUtilities/SBPlayableNote.h>
#import <SBMusicUtilities/SBAudioPlayer.h>
#import <SBMusicUtilities/SBRandomNoteGenerator.h>
#import "ViewController.h"
#import "UIView+Helpers.h"
#import "Question.h"
#import "MBRoundProgressView.h"
#import "Animation.h"
#import "Colors.h"
#import "AppDelegate.h"
#import "SettingsTableViewController.h"
#import "Constants.h"
#import "WrongAnswerTeachingOverlayView.h"
#import "SBEventTracker.h"
#import "PushNotificationHandler.h"

#define ASK_QUESTION_DELAY 1.0
#define MAX_DIFF_ONE_INTERVAL 100.0
#define MAX_DIFF_TWO_OR_MORE_INTERVALS 100.0
static float MAX_DIFFERENCE = MAX_DIFF_ONE_INTERVAL;

@interface ViewController () 
{
    int answer;
    int userAnswer;
    NSInteger dailyProgressGoal;
    NSUserDefaults *defaults;
    BOOL previousAnswerWasCorrect;
    BOOL loopAnimateTarget;
}

@property (nonatomic) BOOL paused;
@property (nonatomic) BOOL speakInterval;
@property (nonatomic) NSInteger answerDifferential; // positive values means you got x more correct than incorrect
@property (nonatomic) int correctStreak; // positive values means you got x more correct than incorrect
@property (nonatomic) float differenceInCents;
@property (nonatomic) float differenceInCentsToLog;
@property (nonatomic, retain) NSString *highScoreKey;
@property (nonatomic, retain) NSString *answerDifferentialKey;
@property (nonatomic, retain) NSArray *intervals;
@property (nonatomic, retain) NSArray *instruments;
@property (nonatomic, retain) Question *currentQuestion;
@property (nonatomic, retain) SBRandomNoteGenerator *randomNoteGenerator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    defaults = [NSUserDefaults standardUserDefaults];
    [SBNote setDefaultInstrumenType:InstrumentTypeSineWave];
    self.randomNoteGenerator = [[SBRandomNoteGenerator alloc] init];
    [self reloadNoteRange];
    [[SBAudioPlayer sharedInstance] setGain:1.0];
    [self hideHearAnswersLabel:YES];
    [self.label setText:@""];
    self.nextButton.hidden = YES;
    [self.intervalDirectionLabel setText:@""];
    [self.intervalNameLabel setText:@""];
    [self theme:[Colors colorSetForDay:[defaults integerForKey:@"total-days-goal-met"]]];
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:app];
}

- (void)applicationWillTerminate {
    if (self.nextButton.hidden == NO) {
        [self logAnswer];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    // Called when dismissing settings
    [self reloadNoteRange];
    [self reloadIntervals];
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
    float progress = (float)questionsAnswered / (float)dailyProgressGoal;
    self.dailyProgressView.progress = progress;
    
    NSDate *beginningOfDay = [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
    NSString *goalMetKey = [NSString stringWithFormat:@"daily-goal-met-%f",
                            beginningOfDay.timeIntervalSince1970];
    if (progress >= 1.0 && [defaults boolForKey:goalMetKey] == NO)
    {
        [defaults setBool:YES forKey:goalMetKey];
        NSInteger daysGoalMet = [defaults integerForKey:@"total-days-goal-met"];
        daysGoalMet++;
        [defaults setInteger:daysGoalMet forKey:@"total-days-goal-met"];
        
        if (daysGoalMet == 1) {
            self.paused = YES;
            [PushNotificationHandler askForReminderFrom:self completion:^(BOOL accepted)
            {
                self.paused = accepted;
                [self themeAfterDelay:.25];
                
                if (accepted == NO) {
                    [self askQuestion:0.25]; // Animation duration
                } else {
                    [self performSegueWithIdentifier:@"SettingsSegue" sender:@"enable notifications"];
                }
            }];
        } else if (daysGoalMet == 5) {
            [self themeAfterDelay:0.15];
            if ([SKStoreReviewController class]) {
                [SKStoreReviewController requestReview];
            }
        } else {
            [self themeAfterDelay:.75];
        }
        
        // record amazon event
        [SBEventTracker trackDailyGoalComplete];
    }
    
    // cancel notifications if we just completed our daily progress goal
    if (questionsAnswered == dailyProgressGoal)
    {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate createNotification];
    }
}

- (void)themeAfterDelay:(double)delay {
    NSInteger daysGoalMet = [defaults integerForKey:@"total-days-goal-met"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0 animations:^(void){
            [self theme:[Colors colorSetForDay:daysGoalMet]];
        }];
    });
}

/**
 * Colors contains two UIColor objects. The first being the main color and the second being the 
 * background color for the replay button
 */
- (void) theme:(NSArray*)colors
{
    UIColor *mainColor = colors[0];
    self.view.backgroundColor = mainColor;
    [self.nextButton setTitleColor:mainColor forState:UIControlStateNormal];
    [self.replayButton setBackgroundColor:colors[1]];
}

- (NSString*) dailyProgressKey
{
    NSDate *beginningOfDay = [[NSCalendar currentCalendar] startOfDayForDate:[NSDate date]];
    return [NSString stringWithFormat:@"questions-answered-%f", beginningOfDay.timeIntervalSince1970];
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
    intervals = [intervals sortedArrayUsingSelector:@selector(compare:)];
    
    BOOL forceReload = [[NSUserDefaults standardUserDefaults] boolForKey:FORCE_RELOAD_ON_VIEW_WILL_APPEAR_KEY];
    
    if (![self.intervals isEqual:intervals]
        || ![self.instruments isEqual:[defaults objectForKey:@"instruments"]]
        || self.paused
        || forceReload)
    {
        self.paused = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:FORCE_RELOAD_ON_VIEW_WILL_APPEAR_KEY];
        [self animateAlpha:1.0 ofButtons:@[self.flatButton, self.spotOnButton, self.sharpButton]];
        self.intervals = intervals;
        self.instruments = [defaults objectForKey:@"instruments"];
        [self.centsDifference setText:@""];
        [self.highScoreLabel setText:@""];
        [self.intervalDirectionLabel setText:@""];
        [self.intervalNameLabel setText:@""];
        [self hideHearAnswersLabel:YES];
        [self askQuestion:ASK_QUESTION_DELAY];
    }
}

+ (NSString *) defaultsKeyForInterval:(IntervalType)interval {
    return [NSString stringWithFormat:@"answer-differential-%ld", (long)[self intervalSetHash:@[@(interval)]]];
}

+ (NSInteger) intervalSetHash:(NSArray*)intervalSet
{
    NSArray *sorted = [intervalSet sortedArrayUsingSelector:@selector(compare:)];
    NSInteger hash = 17;
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

- (void) askQuestion:(double)delayTimeInSeconds
{
    if (self.paused) return;
    loopAnimateTarget = NO;
    IntervalType oldInterval = self.currentQuestion.interval;
    self.currentQuestion = [self generateQuestion];
    [self setDirectionLabelTextForInterval:self.currentQuestion.interval];
    [self setIntervalNameLabelTextForInterval:self.currentQuestion.interval];
    if (oldInterval != self.currentQuestion.interval)
    {
        [Animation slideInAndOut:self.centsDifference amount:2.0];
        [Animation slideInAndOut:self.highScoreLabel amount:-1.3];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.centsDifference setText:[NSString stringWithFormat:@"±%.1fc", self.differenceInCents]];
        });
    }
    else
    {
        // same interval as last time
        if (!previousAnswerWasCorrect)
        {
            [Animation rotateOverXAxis:self.centsDifference forwards:NO];
            double delayTimeInSeconds = .75 / 4 * 3; // quarter of the way through flip
            __weak ViewController *weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [weakSelf.centsDifference setText:[NSString stringWithFormat:@"±%.1fc", weakSelf.differenceInCents]];
            });
        }
        else
        {
            [self.centsDifference setText:[NSString stringWithFormat:@"±%.1fc", self.differenceInCents]];
        }
    }
    
    __weak id weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf _askQuestion];
    });
}

- (void) _askQuestion {
    [self.sharpButton.layer removeAllAnimations];
    [self.flatButton.layer removeAllAnimations];
    [self.spotOnButton.layer removeAllAnimations];
    
    [self.label setText:@""];
    if (self.hearAgainIntervalLabel.hidden == NO) {
        [self hideHearAnswersLabel:NO];
    }
    
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
        [self.currentQuestion markStartTime];
        [self playNote:self.currentQuestion.referenceNote thenPlay:self.currentQuestion.questionNote];
    });
    
    NSLog(@"%@\n%@", self.currentQuestion.referenceNote, self.currentQuestion.questionNote);
}

- (void) loadScoreForInterval:(IntervalType)interval
{
    // high score is unique to interval
    NSInteger hash = [[self class] intervalSetHash:@[@(interval)]];
    self.highScoreKey = [NSString stringWithFormat:@"highscore-%ld", (long)hash];
    float highScoreFloat = [defaults floatForKey:self.highScoreKey];
    
    // if new game type
    if (highScoreFloat == 0)
    {
        [defaults setFloat:MAX_DIFFERENCE forKey:self.highScoreKey];
        highScoreFloat = MAX_DIFFERENCE;
    }
    
    self.answerDifferentialKey = [NSString
                                  stringWithFormat:@"answer-differential-%ld", (long)hash];
    self.answerDifferential = [defaults integerForKey:self.answerDifferentialKey];
    [self calculateDifferenceInCents];
    
    // change label text
    if (self.currentQuestion == nil)
    {
        __weak ViewController *weakSelf = self;
        [weakSelf.highScoreLabel setText:@" "];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            NSString *highScore = [NSString stringWithFormat:@"±%.1fc", highScoreFloat];
            [weakSelf.highScoreLabel setText:highScore];
        });
    }
    else
    {
        NSString *highScore = [NSString stringWithFormat:@"±%.1fc", highScoreFloat];
        [self.highScoreLabel setText:highScore];
    }
}

- (void) playNote:(SBNote*)firstNote thenPlay:(SBNote*)secondNote
{
    SBAudioPlayer *audioPlayer = [SBAudioPlayer sharedInstance];
    if (audioPlayer.notes.count != 0
        && self.currentQuestion.referenceNote.instrumentType == InstrumentTypeSineWave)
        return; // return if there are already notes playing

    [audioPlayer play:firstNote];
    
    double delayTimeInSeconds = firstNote.duration + .1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [audioPlayer play:secondNote];
    });
}

- (Question*) generateQuestion
{
    IntervalType interval = [self randomIntervalForWeightedDistribution];
    SBNote *referenceNote = [self.randomNoteGenerator nextNote];
    referenceNote.duration = 1.0;
    
    SBNote *questionNote;
    [self loadScoreForInterval:interval];
    int random = arc4random_uniform(3);
    answer = random;
    if (random == 0)
    {
        questionNote = [referenceNote
                        noteWithDifferenceInCents:(double)interval * 100.0 + self.differenceInCents
                        adjustName:YES];
        NSLog(@"higher by %f", self.differenceInCents);
    }
    else if (random == 1)
    {
        questionNote = [referenceNote
                        noteWithDifferenceInCents:(double)interval * 100.0
                        adjustName:YES];
        NSLog(@"on it");
    }
    else
    {
        questionNote = [referenceNote
                        noteWithDifferenceInCents:(double)interval * 100.0 - self.differenceInCents
                        adjustName:YES];
        NSLog(@"lower by %f", self.differenceInCents);
    }
    
    // randomly change loudness to be between .7 and 1.0 and always have one note at 1.0
    float upOrDown = drand48();
    if (upOrDown > .5)
    {
        referenceNote.loudness = 1.0 - .4 * drand48();
    }
    else
    {
        questionNote.loudness = 1.0 - .4 * drand48();
    }
    
    double duration = [defaults doubleForKey:@"note-duration"];
    double durationVariation = [defaults doubleForKey:@"note-duration-variation"];
    questionNote.duration = MAX(duration + (drand48() * durationVariation - durationVariation/2), .1);
    referenceNote.duration = MAX(duration + (drand48() * durationVariation - durationVariation/2), .1);
    
    // set instrument
    InstrumentType instrumentType = [self instrumentType];
    referenceNote.instrumentType = instrumentType;
    questionNote.instrumentType = instrumentType;
    
    // Make sure we have a sample for this instrumenttype
    if (instrumentType != InstrumentTypeSineWave && instrumentType != InstrumentTypeSineWaveDrone) {
        SBPlayableNote *playableReferenceNote = [[SBPlayableNote alloc] initWithName:referenceNote.nameWithOctave];
        SBPlayableNote *playableQuestionNote = [[SBPlayableNote alloc] initWithName:questionNote.nameWithOctave];
        
        // if there is no possible sample to play, reset range
        SBNote *lowestSample = [SBNote noteWithName:@"A#2"];
        SBNote *highestSample = [SBNote noteWithName:@"A5"];
        if (self.randomNoteGenerator.toNote.halfStepsFromA4 < lowestSample.halfStepsFromA4) {
            CLS_LOG(@"<1> fromNote: %@, toNote: %@", self.randomNoteGenerator.fromNote.nameWithOctave, self.randomNoteGenerator.toNote.nameWithOctave);
            [self.randomNoteGenerator setRangeFrom:lowestSample to:highestSample];
            [self setNoteRangeFrom:lowestSample to:highestSample];
            return [self generateQuestion];
        }
        else if (self.randomNoteGenerator.fromNote.halfStepsFromA4 > highestSample.halfStepsFromA4) {
            CLS_LOG(@"<2> fromNote: %@, toNote: %@", self.randomNoteGenerator.fromNote.nameWithOctave, self.randomNoteGenerator.toNote.nameWithOctave);
            [self.randomNoteGenerator setRangeFrom:lowestSample to:highestSample];
            [self setNoteRangeFrom:lowestSample to:highestSample];
            return [self generateQuestion];
        }
        // otherwise check if sample exists
        else if ([playableReferenceNote sampleExists] == NO || [playableQuestionNote sampleExists] == NO) {
            CLS_LOG(@"<3> referenceNote: %@, questionNote: %@", referenceNote.nameWithOctave, questionNote.nameWithOctave);
            return [self generateQuestion];
        }
    }
    
    // create question object
    Question *question = [[Question alloc] init];
    question.referenceNote = referenceNote;
    question.questionNote = questionNote;
    question.interval = interval;
    
    return question;
}

- (void)setNoteRangeFrom:(SBNote*)from to:(SBNote*)to {
    [[NSUserDefaults standardUserDefaults] setObject:from.nameWithOctave forKey:@"from-note"];
    [[NSUserDefaults standardUserDefaults] setObject:to.nameWithOctave forKey:@"to-note"];
}

- (InstrumentType)instrumentType
{
    NSArray *instruments = [defaults objectForKey:@"instruments"];
    NSUInteger randomIndex = arc4random() % [instruments count];
    return [instruments[randomIndex] integerValue];
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
        return NSLocalizedString(@"ascending", nil);
    }
    else if (interval == 0)
    {
        return @"";
    }
    else
    {
        return NSLocalizedString(@"descending", nil);
    }
}

- (void) answer:(int)value {
    previousAnswerWasCorrect = value == answer;
    userAnswer = value;
    self.differenceInCentsToLog = self.differenceInCents;
    
    NSInteger questionsAnsweredTotal = [[NSUserDefaults standardUserDefaults] integerForKey:@"questions-answered-total"];
    [[NSUserDefaults standardUserDefaults] setInteger:++questionsAnsweredTotal forKey:@"questions-answered-total"];
    [self incrementDailyProgress];
    
    if (previousAnswerWasCorrect)
    {
        [self correct];
        [self logAnswer];
    }
    else
    {
        [self incorrect:value];
        if ([defaults integerForKey:@"wrong-answer-overlay-shown"] == 0)
        {
            [self showWrongAnswerOverlay];
            [defaults setInteger:1 forKey:@"wrong-answer-overlay-shown"];
        }
    }
}

- (void) incorrect:(int)value {
    NSString *correctAnswer;
    
    // loop animate
    loopAnimateTarget = YES;
    
    switch (answer)
    {
        case 0:
            correctAnswer = @"sharp";
            [self loopScalePop:self.sharpButton toScale:1.15];
            [self animateAlpha:.7 ofButtons:@[self.flatButton, self.spotOnButton]];
            break;
            
        case 1:
            correctAnswer = @"in-tune";
            [self loopScalePop:self.spotOnButton toScale:1.15];
            [self animateAlpha:.7 ofButtons:@[self.flatButton, self.sharpButton]];
            break;
            
        case 2:
            correctAnswer = @"flat";
            [self loopScalePop:self.flatButton toScale:1.15];
            [self animateAlpha:.7 ofButtons:@[self.spotOnButton, self.sharpButton]];
            break;
            
        default:
            correctAnswer = @"???";
            break;
    }
    
    if (self.speakInterval)
    {
        [self speak:@"Incorrect"];
    }
    
    // if answer was on par and you chose something else, increase by two
    self.answerDifferential--;
    if (self.answerDifferential < 0) self.answerDifferential = 0;
    [defaults setInteger:self.answerDifferential forKey:self.answerDifferentialKey];
    self.correctStreak = 0;
    
    [self.label setAttributedText:[self correctAnswerBolded:correctAnswer]];
    [Animation flashBackgroundColor:[UIColor redColor] ofView:self.view];
    [self hideHearAnswersLabel:NO];
}

- (void) animateAlpha:(CGFloat)alpha ofButtons:(NSArray*)buttons
{
    [UIView animateWithDuration:.25 animations:^{
        for (UIButton *button in buttons) {
            button.alpha = alpha;
        }
    }];
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
    // [Animation rotateOverXAxis:self.centsDifference forwards:YES];
    self.correctStreak++;
    [defaults setInteger:++self.answerDifferential forKey:self.answerDifferentialKey];
    
    float newHS = [self differenceInCentsForAnswerDifferential:self.answerDifferential];
    if ([defaults floatForKey:self.highScoreKey] > newHS)
    {
        // save value
        [defaults setFloat:newHS forKey:self.highScoreKey];
        
        // change label text
        NSString *highScore = [NSString stringWithFormat:@"±%.1fc", newHS];
        [self.highScoreLabel setText:highScore];
        
        // animate
        [Animation scalePop:self.highScoreLabel toScale:2.75];
    }
    
    [Animation rotateOverXAxis:self.centsDifference forwards:YES];
    double delayTimeInSeconds = .75 / 4 * 3; // quarter of the way through flip
    __weak ViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [weakSelf.centsDifference setText:[NSString stringWithFormat:@"±%.1fc", newHS]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .75 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self askQuestion:ASK_QUESTION_DELAY/2];
    });
    
    [self.label setText:@"Correct"];
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
    self.differenceInCents = [self differenceInCentsForAnswerDifferential:self.answerDifferential];
}
        
- (float) differenceInCentsForAnswerDifferential:(NSInteger)answerDifferential
{
    float differenceInCents;
    if (answerDifferential > 0)
    {
        differenceInCents = MAX_DIFFERENCE * pow(.965, (double)answerDifferential);
    }
    else
    {
        differenceInCents = MAX_DIFFERENCE;
    }
    
    return differenceInCents;
}

- (void) speak:(NSString*)text
{
    if ([text isEqualToString:@"ascending Tritone"]) {
        text = @"ascending tri-tone";
    } else if ([text isEqualToString:@"descending Tritone"]) {
        text = @"descending tri-tone";
    }
    
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance
                                    speechUtteranceWithString:text];
    [utterance setRate:0.5f];
    utterance.volume = .9f;
    [synthesizer speakUtterance:utterance];
}

- (void) showWrongAnswerOverlay
{
    WrongAnswerTeachingOverlayView *view = [[NSBundle mainBundle]
                                         loadNibNamed:@"WrongAnswerTeachingOverlay"
                                         owner:self
                                         options:nil][0];
    
    // make the buttons play sounds
    [view.sharpButton addTarget:self
                      action:@selector(playSharpAnswer)
            forControlEvents:UIControlEventTouchUpInside];
    [view.flatButton addTarget:self
                     action:@selector(playFlatAnswer)
           forControlEvents:UIControlEventTouchUpInside];
    [view.inTuneButton addTarget:self
                       action:@selector(playInTuneAnswer)
             forControlEvents:UIControlEventTouchUpInside];
    
    view.hidden = YES;
    view.frame = self.view.frame;
    [self.view addSubview:view];
    [view setHidden:NO animatedWithDuration:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Model

- (void) incrementDailyProgress
{
    NSString *dailyProgressKey = [self dailyProgressKey];
    NSInteger questionsAnswered = [[[NSUserDefaults standardUserDefaults]
                                    objectForKey:dailyProgressKey] integerValue];
    NSNumber *incremented = [NSNumber numberWithInteger:questionsAnswered+1];
    [[NSUserDefaults standardUserDefaults] setObject:incremented forKey:dailyProgressKey];
    [self reloadDailyProgress];
}

- (IntervalType) randomIntervalForWeightedDistribution
{
    if (self.intervals.count == 1) return [self.intervals[0] integerValue];
    
    float learningSpeed = 3.5;
    float scoreSum = 0.0;
    NSMutableArray *scores = [[NSMutableArray alloc] init];
    for (NSNumber *interval in self.intervals)
    {
        NSInteger hash = [[self class] intervalSetHash:@[interval]];
        NSString *answerDifferentialKey = [NSString stringWithFormat:@"answer-differential-%ld", (long)hash];
        float intervalScore = [self differenceInCentsForAnswerDifferential:[defaults integerForKey:answerDifferentialKey]];
        scoreSum += powf(intervalScore, learningSpeed);
        [scores addObject:@(intervalScore)];
    }
    
    // pick a random number within the sum of the high scores
    float rand = drand48() * scoreSum;
    float cumulativeSum = 0.0;
    for (int i = 0; i < scores.count; i++)
    {
        cumulativeSum += powf([scores[i] floatValue], learningSpeed);
        if (rand <= cumulativeSum)
        {
            return [self.intervals[i] integerValue];
        }
    }
    
    return 0;
}

- (void)logAnswer
{
    [self.currentQuestion logToDBWithUserAnswer:userAnswer
                                  correctAnswer:answer
                                     difficulty:self.differenceInCentsToLog
                                  noteRangeFrom:self.randomNoteGenerator.fromNote.halfStepsFromA4
                                    noteRangeTo:self.randomNoteGenerator.toNote.halfStepsFromA4];
}

#pragma mark - Game logic

#pragma mark - Animations

- (void) loopScalePop:(UIView*)view toScale:(CGFloat)scale
{
    if (!loopAnimateTarget)
    {
        return;
    }
    
    [UIView animateWithDuration:.25
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:
     ^
     {
         view.transform = CGAffineTransformMakeScale(scale, scale);
     }
                     completion:
     ^(BOOL finished)
    {
         [UIView animateWithDuration:0.25
                               delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                          animations:^{
                              view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                          }
                          completion:^(BOOL finished) {
                              [self loopScalePop:view toScale:scale];
                          }];
     }];
}


#pragma mark - Actions

- (IBAction)up:(id)sender {
    if (self.nextButton.hidden)
    {
        [self answer:0];
    }
    else
    {
        [self playSharpAnswer];
    }
}

- (IBAction)center:(id)sender {
    if (self.nextButton.hidden)
    {
        [self answer:1];
    }
    else
    {
        [self playInTuneAnswer];
    }
}

- (IBAction)down:(id)sender {
    if (self.nextButton.hidden)
    {
        [self answer:2];
    }
    else
    {
        [self playFlatAnswer];
    }
}

- (void) playSharpAnswer
{
    double difference = self.currentQuestion.interval * 100.0 + self.differenceInCents;
    [self.currentQuestion incrementOnIncorrectAnswerListens];
    [self playAnswerWithCentsDifference:difference];
}

- (void) playInTuneAnswer
{
    double difference = self.currentQuestion.interval * 100.0;
    [self.currentQuestion incrementOnIncorrectAnswerListens];
    [self playAnswerWithCentsDifference:difference];
}

- (void) playFlatAnswer
{
    double difference = self.currentQuestion.interval * 100.0 - self.differenceInCents;
    [self.currentQuestion incrementOnIncorrectAnswerListens];
    [self playAnswerWithCentsDifference:difference];
}

- (void) playAnswerWithCentsDifference:(double)difference
{
    SBNote *second = [self.currentQuestion.referenceNote noteWithDifferenceInCents:difference
                                                                        adjustName:YES];
    second.loudness = self.currentQuestion.questionNote.loudness;
    second.duration = self.currentQuestion.questionNote.duration;
    second.instrumentType = self.currentQuestion.questionNote.instrumentType;
    [self playNote:self.currentQuestion.referenceNote thenPlay:second];
}

- (IBAction)nextButtonPressed:(UIButton*)sender
{
    [self logAnswer];
    
    [self animateAlpha:1.0 ofButtons:@[self.flatButton, self.spotOnButton, self.sharpButton]];
    // [Animation rotateOverXAxis:self.centsDifference forwards:NO];
    loopAnimateTarget = NO;
    
    // [self loopScalePop:self.spotOnButton toScale:1.1];
    [self askQuestion:0.0];
    sender.hidden = YES;
    [self hideHearAnswersLabel:YES];
}

- (IBAction)replayButtonPressed:(id)sender
{
    [self playNote:self.currentQuestion.referenceNote thenPlay:self.currentQuestion.questionNote];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SettingsSegue"])
    {
        if ([sender isKindOfClass:[NSString class]] && [sender isEqualToString:@"enable notifications"])
        {
            SettingsTableViewController *stvc = (SettingsTableViewController*)[segue.destinationViewController topViewController];
            stvc.selectPracticeRemindersOnLoad = YES;
        }
    }
}

@end
