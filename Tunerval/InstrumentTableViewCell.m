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

@end

@implementation InstrumentTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.checkMarkImageView.hidden = YES;
    self.buyButtonOriginalBG = self.buyButton.backgroundColor;
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

- (BOOL)isSelected
{
    return !self.checkMarkImageView.hidden;
}

@end
