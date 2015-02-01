//
//  CRMAttrCell.m
//  CoreCrm
//
//  Created by Anping Wang on 11/11/12.
//  Copyright (c) 2012 Anping Wang. All rights reserved.
//

#import "SSAttrCell.h"
#import "SSLovVC.h"
#import "SSDateLovVC.h"
#import "SSAttrDef.h"
#import "SSTimeUtil.h"
#import "ObjectTypeUtil.h"
#import "SSGeoCodeUtil.h"
#import "SSJSONUtil.h"
#import "SSTextVC.h"
#import "SSLookupVC.h"
#import "SSAttrDefGroup.h"
#import "SSObjectEditorVC.h"

@interface SSAttrCell ()
{
    IBOutlet UITextField *tfAttrValue;
    IBOutlet UISwitch *sAttrValue;
    IBOutlet UILabel *lAttrName;
    IBOutlet UIButton *btnAction;
    SSAttrDef *attrDef;
}

- (IBAction) booleanValueChanged:(id)sender;
- (IBAction) actionBtnPressed:(id)sender;

@end

@implementation SSAttrCell

- (UITextField *) textField
{
    return tfAttrValue;
}

- (IBAction) booleanValueChanged:(id)sender
{
    attrDef.value = [NSNumber numberWithInt: sAttrValue.on];
}

- (IBAction) actionBtnPressed:(id)sender;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionPerformed:)])
    {
        [self.delegate actionPerformed:attrDef];
    }
}

- (id) getValue
{
    return attrDef.value ? attrDef.value : attrDef.defaultValue;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) setDateFromLov:(NSDate *)date forEntity:(NSString *)entityName
{
    if ([attrDef.name isEqualToString:entityName])
    {
        attrDef.value = [date toString];
    }
}

- (void) setValue:(id) value
{
    attrDef.value = value;
}

- (void) setValueFromLov:(id) selectedLov
{
    attrDef.value = [selectedLov valueForKey:@"value"];
}

- (void) updateCellUI:(SSAttrDef *)attr object : (id) object;
{
    attrDef = attr;
    
    lAttrName.text = [attrDef displayName];
    
    tfAttrValue.placeholder = @"";
    tfAttrValue.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    sAttrValue.hidden = attrDef.dataType != SSBooleanType;
    tfAttrValue.hidden = attrDef.dataType == SSBooleanType || attrDef.dataType == SSActionType;
    lAttrName.hidden = attrDef.dataType == SSActionType;
    btnAction.hidden = attrDef.dataType != SSActionType;
    
    [btnAction setTitle:attrDef.name forState:UIControlStateNormal];
    
    if (attrDef.metaType == SSEmail)
    {
        tfAttrValue.keyboardType = UIKeyboardTypeEmailAddress;
        tfAttrValue.placeholder = @"e.g. abc@gmail.com";
    }
    else if (attrDef.metaType == SSPhone)
    {
        tfAttrValue.keyboardType = UIKeyboardTypeNamePhonePad;
        tfAttrValue.placeholder = @"e.g. # (###) ###-####";
    }
    
    if(attrDef.hideLabel)
    {
        lAttrName.hidden = YES;
        tfAttrValue.frame = CGRectMake(4, 2, self.frame.size.width - 28, self.frame.size.height - 4);
    }
    else
    {
        lAttrName.hidden = NO;
        tfAttrValue.frame = CGRectMake(lAttrName.frame.size.width + 4, 2, self.frame.size.width - lAttrName.frame.size.width - 28, self.frame.size.height - 4);
    }
    
    id value = attrDef.value ? attrDef.value : attr.defaultValue;
    
    if (value && attrDef.dataType != SSObjectType)
    {
        tfAttrValue.text = [attrDef displayValue:value];
        sAttrValue.selected = [value boolValue];
    }
    else if( attrDef.dataType == SSObjectType)
    {
        tfAttrValue.text = [value objectForKey:@"displayValue"];
    }
    else
    {
        tfAttrValue.text = nil;
    }
    
    if (attrDef.backgroundColor)
    {
        btnAction.backgroundColor = attrDef.backgroundColor;
    }
}

#pragma Text Editor

- (void) becomeFirstResponder
{
    [tfAttrValue becomeFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (attrDef.lov)
    {
        SSLovVC *coreLov = [[SSLovVC alloc]init];
        [coreLov cellEdtior:self selectValueFor:attrDef.name];
        coreLov.listOfValues = attrDef.lov;
        coreLov.title = lAttrName.text;
        if ([self.delegate respondsToSelector:@selector(showLov:)])
        {
            [self.delegate showLov:coreLov];
        }
        return NO;
    }
    
    if (attrDef.dataType == SSDateType)
    {
        SSDateLovVC *coreLov = [[SSDateLovVC alloc]init];
        coreLov.datePickerMode = UIDatePickerModeDate;
        [coreLov cellEdtior:self selectValueFor:attrDef.name];
        coreLov.title = lAttrName.text;
        if ([self.delegate respondsToSelector:@selector(showLov:)])
        {
            [self.delegate showLov:coreLov];
        }
        return NO;
    }
    if (attrDef.dataType == SSLovType)
    {
        SSLookupVC *coreLov = [[SSLookupVC alloc]init];
      
        coreLov.cellEditor = self;
        coreLov.attrDef = attrDef;
        coreLov.title = lAttrName.text;
        if ([self.delegate respondsToSelector:@selector(showLov:)])
        {
            [self.delegate showLov:coreLov];
        }
        return NO;
    }
    if (attrDef.dataType == SSObjectType)
    {
        Class clazz = NSClassFromString(attrDef.group.itemEditor);
        assert(clazz);
        SSObjectEditorVC *itemEditor = [[clazz alloc]init];
        if (!attrDef.value)
        {
            attrDef.value = [NSMutableDictionary dictionaryWithDictionary:attrDef.defaultValue];
        }
        [itemEditor edit : attrDef.value];
        
        if ([self.delegate respondsToSelector:@selector(showLov:)])
        {
            [self.delegate showLov:itemEditor];
        }
        return NO;
    }
    if (attrDef.dataType == SSTextType)
    {
        SSTextVC *coreLov = [[SSTextVC alloc]init];
        [coreLov cellEdtior:self selectValueFor:attrDef.name];
        coreLov.title = lAttrName.text;
        if ([self.delegate respondsToSelector:@selector(showLov:)])
        {
            [self.delegate showLov:coreLov];
        }
        return NO;
    }
    
    if (self.delegate)
    {
        [self.delegate editor:textField beginToEdit: attrDef];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (attrDef.dataType == SSDateType)
    {
        [textField resignFirstResponder];
    }
    if (self.delegate)
    {
        [self.delegate editor:textField readyToEdit: attrDef];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (![textField.text isEqualToString:attrDef.value])
    {
        attrDef.value = textField.text;
        if (self.delegate)
        {
            [self.delegate editor:textField finishedToEdit: attrDef];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate)
    {
        return [self.delegate editor:textField shouldFinishEdit: attrDef];
    }
    return YES;
}

@end
