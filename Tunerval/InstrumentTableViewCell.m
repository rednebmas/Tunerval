//
//  InstrumentTableViewCell.m
//  Tunerval
//
//  Created by Sam Bender on 9/4/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "InstrumentTableViewCell.h"

@interface InstrumentTableViewCell()

@property (nonatomic, strong) UIColor *buyButtonOriginalBG;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkImageView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buyButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkMarkTraillingToBuyButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *downloadingLabel;

@end

@implementation InstrumentTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.checkMarkImageView.hidden = YES;
    self.buyButtonOriginalBG = self.buyButton.backgroundColor;
    [self.buyButton addTarget:self action:@selector(buyButtonTouchUp) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.buyButton.backgroundColor = self.buyButtonOriginalBG;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.buyButton.backgroundColor = self.buyButtonOriginalBG;
}

- (void)toggleCheckMark
{
    [self setCheckMarkHidden:!self.checkMarkImageView.hidden];
}

- (void)setCheckMarkHidden:(BOOL)hidden
{
    self.checkMarkImageView.hidden = hidden;
}

- (void)hideBuyButton
{
    self.buyButtonWidthConstraint.constant = 0;
    self.checkMarkTraillingToBuyButton.constant = 0;
}

- (void)hideBuyButtonAnimated
{
    [self layoutIfNeeded];
    
    self.buyButtonWidthConstraint.constant = 0;
    self.checkMarkTraillingToBuyButton.constant = 0;
    [UIView animateWithDuration:.25 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)startDownloadingIndicator
{
    [self.activityIndicator startAnimating];
    self.downloadingLabel.hidden = NO;
}

- (void)stopDownloadingIndicator
{
    [self.activityIndicator stopAnimating];
    self.downloadingLabel.hidden = YES;
}

- (BOOL)isSelected
{
    return !self.checkMarkImageView.hidden;
}

#pragma mark - Actions

- (void)buyButtonTouchUp
{
    [self.delegate buyButtonPressedForCellAtIndex:self.tag];
}

@end
