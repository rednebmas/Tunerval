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

#define MAX_DIFF_ONE_INTERVAL 100.0
#define MAX_DIFF_TWO_OR_MORE_INTERVALS 100.0
static float MAX_DIFFERENCE = MAX_DIFF_ONE_INTERVAL;

@interface ViewController ()
{
    int answer;
    float differenceInCents;
}

@property (nonatomic) int answerDifferential; // positive values means you got x more correct than incorrect
@property (nonatomic, retain) NSString *highScoreKey;
@property (nonatomic, retain) NSArray *intervals;
@property (nonatomic, retain) Question *currentQuestion;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) RandomNoteGenerator *randomNoteGenerator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [SBNote setDefaultInstrumenType:InstrumentTypeSineWave];
    [self reloadIntervals];
    self.backgroundColor = self.view.backgroundColor;
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
    NSUInteger hash = 17;
    for (NSNumber *interval in intervalSet)
    {
        hash = hash * 31 + [interval integerValue];
    }
    return hash;
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
    
    [self setDirectionLabelTextForInterval:self.currentQuestion.interval];
    [self setIntervalNameLabelTextForInterval:self.currentQuestion.interval];
    
    // gives player time to read interval name
    double delayTimeInSeconds = 0.5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTimeInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self playNote:self.currentQuestion.referenceNote thenPlay:self.currentQuestion.questionNote];
    });
    
    NSLog(@"%@\n%@", self.currentQuestion.referenceNote, self.currentQuestion.questionNote);
}

- (void) playNote:(SBNote*)firstNote thenPlay:(SBNote*)secondNote
{
    [[AudioPlayer sharedInstance] play:firstNote];
    
    double delayTimeInSeconds = 1.1;
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
        [self scaleAnimateView:self.intervalDirectionLabel];
    }
    
    [self.intervalDirectionLabel setText:newDirection];
}

- (void) setIntervalNameLabelTextForInterval:(IntervalType)interval
{
    NSString *newIntervalName = [SBNote intervalTypeToIntervalName:interval];
    if ([newIntervalName isEqualToString:self.intervalNameLabel.text] == NO)
    {
        [self rotateWiggleView:self.intervalNameLabel];
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
}

- (void) incorrect:(int)value {
    NSString *correctAnswer;
    switch (answer) {
        case 0:
            correctAnswer = @"sharp";
            [self scaleAnimateView:self.sharpButton];
            break;
            
        case 1:
            correctAnswer = @"spot on";
            [self scaleAnimateView:self.spotOnButton];
            break;
            
        case 2:
            correctAnswer = @"flat";
            [self scaleAnimateView:self.flatButton];
            break;
            
        default:
            correctAnswer = @"???";
            break;
    }
    
    // if the user chooses sharp when flat or flat when sharp this will subtract two
    self.answerDifferential -= abs(value - answer);
    
    [self rotateDownOverXAxis:self.centsDifference];
    
    [self.label setText:[NSString stringWithFormat:@"Incorrect\nAnswer: %@", correctAnswer]];
    [self flashBackgroundColor:[UIColor redColor]];
    [self hideHearAnswersLabel:NO];
    NSLog(@"%d", self.answerDifferential);
}

- (void) correct
{
    [self rotateUpOverXAxis:self.centsDifference];
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
        [self animateHighScoreLabel];
    }
    
    NSLog(@"calculated diff: %.2f", differenceInCents);
    
    [self.centsDifference setText:[NSString stringWithFormat:@"±%.1fc", differenceInCents]];
}

- (void) animateHighScoreLabel
{
    [UIView animateWithDuration:0.25
                     animations:^{
        self.highScoreLabel.transform = CGAffineTransformMakeScale(2.0, 2.0);
    }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.25
                                          animations:^{
                             self.highScoreLabel.transform = CGAffineTransformMakeScale(1, 1);
                         } completion:^(BOOL finished){
                         }];
                     }];
}

- (void) scaleAnimateView:(UIView*)view
{
    [UIView animateWithDuration:0.25
                     animations:^{
        view.transform = CGAffineTransformMakeScale(1.20, 1.20);
    }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.25
                                          animations:^{
                             view.transform = CGAffineTransformMakeScale(1, 1);
                         }];
                     }];
}

- (void) rotateWiggleView:(UIView*)view
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         view.transform = CGAffineTransformMakeRotation(-M_PI/32);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              view.transform = CGAffineTransformMakeRotation(M_PI/32);
                                          }
                                          completion:^(BOOL finshed){
                                              [UIView animateWithDuration:.25
                                                               animations:^{
                                                                   view.transform = CGAffineTransformMakeRotation(0);
                                                               }];
                                          }];
                         
                     }];
}


- (void) rotateDownOverXAxis:(UIView*)view
{
    // http://stackoverflow.com/questions/11571420/catransform3drotate-rotate-for-360-degrees
    CALayer *layer = view.layer;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -50;
    layer.transform = transform;
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.values = [NSArray arrayWithObjects:
                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 0 * -M_PI / 2, 1, 0, 0)],
                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * -M_PI / 2, 1, 0, 0)],
                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 2 * -M_PI / 2, 1, 0, 0)],
                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 3 * -M_PI / 2, 1, 0, 0)],
                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 4 * -M_PI / 2, 1, 0, 0)],
                        nil];
    animation.duration = .75;
    [layer addAnimation:animation forKey:animation.keyPath];
}

- (void) rotateUpOverXAxis:(UIView*)view
{
    // http://stackoverflow.com/questions/11571420/catransform3drotate-rotate-for-360-degrees
    CALayer *layer = view.layer;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -50;
    layer.transform = transform;
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.values = [NSArray arrayWithObjects:
                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 0 * M_PI / 2, 1, 0, 0)],
                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 1 * M_PI / 2, 1, 0, 0)],
                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 2 * M_PI / 2, 1, 0, 0)],
                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 3 * M_PI / 2, 1, 0, 0)],
                        [NSValue valueWithCATransform3D:CATransform3DRotate(transform, 4 * M_PI / 2, 1, 0, 0)],
                        nil];
    animation.duration = .75;
    [layer addAnimation:animation forKey:animation.keyPath];
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
