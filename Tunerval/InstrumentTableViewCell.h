//
//  InstrumentTableViewCell.h
//  Tunerval
//
//  Created by Sam Bender on 9/4/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstrumentTableViewCellDelegate <NSObject>

- (void)buyButtonPressedForCellAtIndex:(NSInteger)index;

@end

@interface InstrumentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *instrumentNameLabel;
@property (nonatomic, weak) id<InstrumentTableViewCellDelegate> delegate;

- (void)toggleCheckMark;
- (void)setCheckMarkHidden:(BOOL)hidden;
- (void)hideBuyButton;
- (void)hideBuyButtonAnimated;
- (void)setDownloadProgress:(float)progress;
- (void)showCheckMarkAnimated;

@end
