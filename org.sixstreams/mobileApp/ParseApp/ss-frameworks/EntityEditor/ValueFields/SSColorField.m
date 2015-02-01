//
//  SSColorField.m
//  SixStreams
//
//  Created by Anping Wang on 2/28/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSColorField.h"
#import "SSColorPickerVC.h"

@implementation SSColorField

- (UIViewController *) getCandidateVC
{
    SSColorPickerVC *colorPicker = [[SSColorPickerVC alloc]initWithValueField:self];
	self.value = self.value == nil ? @"0.2,0.3,0.3,1.0" : self.value;
	return colorPicker;
}

- (void) processValue:  (id)value
{
    self.text = @"";
    NSArray *comps = [value componentsSeparatedByString:@","];
    if (comps.count > 1)
    {
        float red = [comps[0] floatValue];
        float green = [comps[1] floatValue];
        float blue = [comps[2] floatValue];
        float alpha = [comps[3] floatValue];
        self.backgroundColor = [[UIColor alloc]initWithRed:red green:green blue:blue alpha:alpha];
    }
}

@end
