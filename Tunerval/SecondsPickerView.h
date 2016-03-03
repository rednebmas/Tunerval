//
//  SecondsPickerView.h
//  Tunerval
//
//  Created by Sam Bender on 3/3/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SecondsPickerView;

@interface SecondsPickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

// set using key value encoding in storyboard
@property (nonatomic) double min;
@property (nonatomic) double max;
@property (nonatomic) double step;
@property (nonatomic) double defaultValue;
@property (nonatomic, retain) NSString *settingsKey;

- (void) generateSecondsList;

@end
