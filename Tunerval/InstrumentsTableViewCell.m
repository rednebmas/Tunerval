//
//  InstrumentsTableViewCell.m
//  Tunerval
//
//  Created by Sam Bender on 9/4/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "InstrumentsTableViewCell.h"

@interface InstrumentsTableViewCell()

@property (nonatomic, retain) UIColor *instrumentsNewLabelOriginalBG;

@end

@implementation InstrumentsTableViewCell

- (void)setInstrumentsNewLabel:(UILabel *)instrumentsNewLabel
{
    _instrumentsNewLabel = instrumentsNewLabel;
    _instrumentsNewLabelOriginalBG = instrumentsNewLabel.backgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.instrumentsNewLabel.backgroundColor = self.instrumentsNewLabelOriginalBG;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.instrumentsNewLabel.backgroundColor = self.instrumentsNewLabelOriginalBG;
}

@end
