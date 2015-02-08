//
//  DateTextField.m
//  MyPacCoach
//
//  Created by Anping Wang on 11/7/11.
//  Copyright (c) 2011 s. All rights reserved.
//

#import "SSDateTextField.h"
#import "SSTimeUtil.h"
#import "SSDatePickerVC.h"
#import "SSJSONUtil.h"

#define TIME @"time"
#define MONTH @"month"
#define DAY @"day"

@implementation SSDateTextField

- (UIViewController *) getCandidateVC
{
    SSDatePickerVC *datePicker = [[SSDatePickerVC alloc]initWithValueField:self];
	NSDate *defaultDate = nil;
    if ([self.dateInit isEqualToString:MONTH])
    {
        defaultDate = [[NSDate date] firstDateOfMonth];
        self.mode = UIDatePickerModeDate;
    }
    else if ([self.dateInit isEqualToString:DAY])
    {
        defaultDate = [NSDate date];
        self.mode = UIDatePickerModeDate;
    }
    else if ([self.dateInit isEqualToString:TIME])
    {
        defaultDate = [NSDate date];
        self.mode = UIDatePickerModeDateAndTime;
    }
    self.value = self.value == nil ? defaultDate : self.value;
    datePicker.mode = self.mode;
	return datePicker;
}

- (UIDatePickerMode) getMode
{
    if ([self.dateInit isEqualToString:MONTH])
    {
        self.mode = UIDatePickerModeDate;
    }
    else if ([self.dateInit isEqualToString:DAY])
    {
                self.mode = UIDatePickerModeDate;
    }
    else if ([self.dateInit isEqualToString:TIME])
    {
        
        self.mode = UIDatePickerModeDateAndTime;
    }
    return self.mode;
}

- (void) processValue:  (id)value
{
    if ([value isKindOfClass:[NSString class]])
    {
        self.text = value;
        return;
    }
    [self getMode];
    self.text = self.mode == UIDatePickerModeDate ? [value toDateString] :
    (self.mode == UIDatePickerModeDateAndTime ? [value toDateTimeString] : [value toDateString]);
}

@end
