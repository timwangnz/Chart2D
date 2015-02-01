//
//  SSValueField.m
//  Medistory
//
//  Created by Anping Wang on 11/9/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSValueField.h"
#import "SSJSONUtil.h"

@implementation SSValueField

- (SSValueEditorVC *) getCandidateVC
{
    return nil;
}

- (void) preProcessValue:  (id)value
{
    _value = value;
}

- (NSString *) getDisplayValue
{
    return _displayValue ? _displayValue : _value;
}

- (void) setValue:(id)value
{
    if ([self.value isEqual:value] || (!self.value && !value))
    {
        return;
    }
    
    [self preProcessValue:value];
    if (self.valueDelegate)
    {
        [self.valueDelegate valueField:self valueChanged:_value];
    }
    [self processValue:value];
}

- (void) processValue:  (id)value
{
    NSString *text = [NSString stringWithFormat:@"%@", value ? value : @""];
   
    if ([self.metaType isEqualToString:@"phone"]) {
        self.text = [text toPhoneNumber];
    }
    else if ([self.metaType isEqualToString:@"currency"]) {
        self.text = [text toCurrency];
    }
    else if ([self.metaType isEqualToString:@"number"]) {
        self.text = [text toNumber];
    }
    else
    {
        self.text = text;
    }
}

@end
