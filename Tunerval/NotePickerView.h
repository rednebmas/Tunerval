//
//  NotePickerView.h
//  Tunerval
//
//  Created by Sam Bender on 3/1/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBNote, NotePickerView;

@protocol NotePickerViewProtocol <NSObject>

- (void) notePickerView:(NotePickerView*)pickerView pickedNote:(SBNote*)note;

@end

@interface NotePickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id<NotePickerViewProtocol> protocolReciever;

- (void) selectNote:(SBNote*)note animated:(BOOL)animated;

@end
