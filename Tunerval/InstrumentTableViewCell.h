//
//  InstrumentTableViewCell.h
//  Tunerval
//
//  Created by Sam Bender on 9/4/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstrumentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *instrumentNameLabel;

- (void)toggleCheckMark;
- (void)setCheckMarkHidden:(BOOL)hidden;
- (void)hideBuyButton;

@end
