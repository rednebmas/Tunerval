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

#define MAX_DIFFERENCE 200.0

@interface ViewController ()
{
    int answer;
    double differenceInCents;
}

@property (nonatomic) int answerDifferential; // positive values means you got x more correct than incorrect
@property (nonatomic, retain) Question *currentQuestion;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) RandomNoteGenerator *randomNoteGenerator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [SBNote setDefaultInstrumenType:InstrumentTypeSineWave];
    [self delayAskQuestion];
    differenceInCents = MAX_DIFFERENCE;
    self.backgroundColor = self.view.backgroundColor;
    self.randomNoteGenerator = [[RandomNoteGenerator alloc] init];
    [self.randomNoteGenerator setRangeFrom:[SBNote noteWithName:@"E4"] to:[SBNote noteWithName:@"C5"]];
    [[AudioPlayer sharedInstance] setGain:1.0];
    [self.centsDifference setText:[NSString stringWithFormat:@"±%.1fc", differenceInCents]];
    [self hideHearAnswersLabel:YES];
    [self.label setText:@""];
    self.nextButton.hidden = YES;
    self.answerDifferential = 0;
    float highScoreFloat = [[NSUserDefaults standardUserDefaults] floatForKey:@"highscore"];
    NSString *highScore = [NSString stringWithFormat:@"±%.1f\ncents", highScoreFloat];
    [self.highScoreLabel setText:highScore];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) flashBackgroundColor:(UIColor*)color {
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration: 0.25
                     animations: ^{
                         weakSelf.view.backgroundColor = color;
                     }
                     completion: ^(BOOL finished) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [weakSelf unflashBackgroundColor];
                         });
                     }
     ];
}

- (void) unflashBackgroundColor {
    __weak typeof (self) weakSelf = self;
    [UIView animateWithDuration: 0.25
                     animations: ^{
                         weakSelf.view.backgroundColor = weakSelf.backgroundColor;
                     }
                     completion: ^(BOOL finished) {
                     }
     ];
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
    
    [self playNote:self.currentQuestion.referenceNote thenPlay:self.currentQuestion.questionNote];
    NSLog(@"%@\n%@", self.currentQuestion.referenceNote, self.currentQuestion.questionNote);
}

- (void) playNote:(SBNote*)firstNote thenPlay:(SBNote*)secondNote
{
    [[AudioPlayer sharedInstance] play:firstNote];
    
    double delayTimeInSeconds = 1.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[AudioPlayer sharedInstance] play:secondNote];
    });
}

- (Question*) generateQuestion
{
    SBNote *referenceNote = [self.randomNoteGenerator nextNote];
    referenceNote.duration = 1.0;
    
    SBNote *smallDiff;
    IntervalType interval = IntervalTypeMajorSecondAscending;
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
    
    Question *question = [[Question alloc] init];
    question.referenceNote = referenceNote;
    question.questionNote = smallDiff;
    question.interval = interval;
    
    return question;
}

- (void) answer:(int)value {
    if (value == answer) {
        [self correct];
        [self delayAskQuestion];
    } else {
        [self incorrect:value];
    }
}

- (void) incorrect:(int)value {
    NSString *correctAnswer;
    self.answerDifferential--;
    switch (answer) {
        case 0:
            correctAnswer = @"higher";
            break;
            
        case 1:
            correctAnswer = @"on it";
            break;
            
        case 2:
            correctAnswer = @"lower";
            break;
            
        default:
            correctAnswer = @"???";
            break;
    }
    
    [self.label setText:[NSString stringWithFormat:@"Incorrect (answer was %@)", correctAnswer]];
    [self flashBackgroundColor:[UIColor redColor]];
    [self hideHearAnswersLabel:NO];
    [self.nextButton setHidden:NO animated:YES];
    NSLog(@"%d", self.answerDifferential);
}

- (void) correct {
    self.answerDifferential++;
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
    }
    else
    {
        self.hearAgainIntervalLabel.hidden = NO;
        [self.hearAgainIntervalLabel setText:@"To hear the correct interval, press the target button"];
        self.replayButton.hidden = YES;
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
    if (differenceInCents < [[NSUserDefaults standardUserDefaults] floatForKey:@"highscore"])
    {
        // difference in cents high score
        [[NSUserDefaults standardUserDefaults] setFloat:differenceInCents
                                                 forKey:@"highscore"];
        // answer differential so we can calculate size of growing text
        [[NSUserDefaults standardUserDefaults] setInteger:self.answerDifferential
                                                   forKey:@"highscore-answerdifferential"];
        [self.highScoreLabel setText:[NSString stringWithFormat:@"±%.1f\ncents", differenceInCents]];
    }
    
    NSLog(@"calculated diff: %.2f", differenceInCents);
    
    [self.centsDifference setText:[NSString stringWithFormat:@"±%.1fc", differenceInCents]];
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
        [self playNote:self.currentQuestion.referenceNote thenPlay:up];
    }
}

- (IBAction)nextButtonPressed:(UIButton*)sender
{
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
