//
//  SSAttrDef.m
//  Mappuccino
//
//  Created by Anping Wang on 5/5/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSAttrDef.h"
#import "SSTimeUtil.h"
#import "SSJSONUtil.h"
#import "ObjectTypeUtil.h"

@implementation SSAttrDef

- (id) initWithName:(NSString *) name ofType:(SSDataType) dataType andMetaType:(SSAttrMetaType)metaType withValue:(id) defaultValue
{
    self = [super init];
    if (self)
    {
        self.name = name;
        self.dataType = dataType;
        self.defaultValue = defaultValue;
        self.metaType = metaType;
    }
    return self;
}

- (NSString *) displayName
{
    return [ObjectTypeUtil displayName:self.name ofType:self.objectType];
}

- (NSString *) displayValue :(id) value
{
    if (self.lov)
    {
        value = [self.lov objectForKey:value];
    }

    if (value && self.dataType == SSDateType)
    {
        value = [SSTimeUtil stringWithDate: [value toDate]];
    }
    else if (value && self.dataType == SSIntegerType)
    {
        value = [NSString stringWithFormat:@"%.0f", [value floatValue]];
    }
    else if (value && self.dataType == SSNumberType)
    {
        value = [NSString stringWithFormat:@"%.2f", [value floatValue]];
    }
    else if (value && self.dataType == SSBooleanType)
    {
        value =  [value boolValue] ? @"YES" : @"NO";
    }
    
    if ([self.name isEqualToString:@"phone"])
    {
        value = [value toPhoneNumber];
    }
    return value;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    int length = [self getLength:textField.text];
    if(length == 10)
    {
        if(range.length == 0)
        {
            return NO;
        }
    }
    
    if(length == 3)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) ",num];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
    }
    else if(length == 6)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    int length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}

-(int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    int length = [mobileNumber length];
    return length;
}
@end
