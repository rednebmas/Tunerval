//
//  SecondsPickerView.m
//  Tunerval
//
//  Created by Sam Bender on 3/3/16.
//  Copyright © 2016 Sam Bender. All rights reserved.
//

#import "SecondsPickerView.h"

@interface SecondsPickerView()
{
    NSUserDefaults *defaults;
}

@property (nonatomic, retain) NSMutableArray *secondsList;

@end

@implementation SecondsPickerView

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.dataSource = self;
        self.delegate = self;
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void) generateSecondsList
{
    NSInteger toSelectRow = 0;
    double selected = [defaults doubleForKey:self.settingsKey];
    if (selected == 0)
    {
        [defaults setDouble:self.defaultValue forKey:self.settingsKey];
        selected = self.defaultValue;
    }
    
    self.secondsList = [[NSMutableArray alloc] init];
    double current = self.min;
    int i = 0;
    while (current <= self.max + .0001)
    {
        if (selected < current + .001 && selected > current - .001)
        {
            toSelectRow = i;
        }
        
        NSString *str = [NSString stringWithFormat:@"%.2fs", current];
        current = current + self.step;
        [self.secondsList addObject:str];
        i++;
    }
    
    [self reloadAllComponents];
    [self selectRow:toSelectRow inComponent:0 animated:NO];
}

#pragma mark - Pickerview data source

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.secondsList.count;
}

#pragma mark - Pickerview delegate

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.secondsList[row];
}

#pragma mark - Public

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *number = self.secondsList[row];
    NSRange range = NSMakeRange(0, number.length-1);
    double value = [[self.secondsList[row] substringWithRange:range] doubleValue];
    [defaults setObject:[NSNumber numberWithDouble:value] forKey:self.settingsKey];
}

@end
