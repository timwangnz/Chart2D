//
//  LovTextField.m
//  MyPacCoach
//
//  Created by Anping Wang on 11/10/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSLovTextField.h"
#import "SSApp.h"
#import "SSFilter.h"

@interface SSLovTextField()<SSTableLovDelegate>
{
    
}

@end

@implementation SSLovTextField

- (void) processValue:(id)value
{
    [super processValue:value];
    if (!self.allowMultiValues) {
        if(self.displayValue)
        {
            self.text = self.displayValue;
            return;
        }
        NSString *displayValue = value;
        if (!displayValue) {
            self.text = nil;
            return;
        }
            if ([self.listOfValues count] > 0) {
                displayValue = [self.listOfValues objectForKey:value];
            }
            else
            {
                if(self.titleKey && [value isKindOfClass:NSMutableDictionary.class])
                {
                    displayValue = value[self.titleKey];
                }
                else
                {
                    displayValue = [[SSApp instance] displayValue:self.value forAttr:self.attrName ofType:self.entityType];
                }
            }
            self.text = self.displayValue;
    }
    else
    {
        NSMutableString *str = [[NSMutableString alloc]init];
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (id v in self.value) {
            if ([str length] > 0) {
                [str appendString:@","];
            }
            if (self.listOfValues && [self.listOfValues objectForKey:v]) {
                [str appendFormat:@"%@", [self.listOfValues objectForKey:v]];
                [items addObject:v];
            }
            else
            {
                [str appendFormat:@"%@", v[NAME]];
                [items addObject:@{REF_ID_NAME:v[REF_ID_NAME], NAME: v[NAME]}];
            }
        }
        self.displayValue = items;
        self.text = str;
    }
}

- (void) listOfValues:(id) tableView didSelect : (id) entity
{
    if(self.titleKey)
    {
        self.displayValue = [entity objectForKey:self.titleKey];
        self.value = entity;
    }
    else
    {
        self.displayValue = [self.listOfValues objectForKey:self.value];
        self.value = [entity objectForKey:REF_ID_NAME];
    }
    [tableView popDownVC:tableView];
}

- (BOOL) listOfValues:(id) tableView isSelected:(id) entity
{
    return NO;
}

- (BOOL) multiValueAllowedFor:(id) tableView
{
    return NO;
}

- (void) tableLov : (SSTableLovVC *) tableLov didSelect: (id) item
{
    [self processValue:self.value];
    if (self.valueDelegate)
    {
        [self.valueDelegate valueField:self valueChanged:self.value];
    }
}

- (UIViewController *) getCandidateVC
{
    if (self.entityType) {
        SSSearchVC *lov = [[SSSearchVC alloc]init];
        lov.objectType = self.entityType;
        lov.titleKey = self.titleKey;
        lov.queryPrefixKey = SEARCHABLE_WORDS;
        lov.entityEditorClass = [[SSApp instance] editorClassFor:self.entityType];
        lov.listOfValueDelegate = self;
        lov.addable = YES;
        lov.title = @"List of Values";
        
        if (self.predicate)
        {
            [lov.predicates addObject:[SSFilter on:self.predicate op:EQ value:self.entity[self.predicate]]];
        }
        
        SSTableLovVC *lovVC = [[SSTableLovVC alloc]initWithValueField:self];
        lovVC.attrId = self.attrId;
        lovVC.addable = self.canAddToLov;
        lovVC.tableLovDelegate = self;
        lovVC.field = self;
        lovVC.items = nil;
        lovVC.searchVC = lov;
        return lovVC;
    }
    else
    {
        if (self.lovDelegate)
        {
            self.listOfValues = [self.lovDelegate listOfValuesFor:self];
        }
        if(self.listOfValues && [self.listOfValues count]>0)
        {
            SSTableLovVC *lovVC = [[SSTableLovVC alloc]initWithValueField:self];
            lovVC.items = self.listOfValues;
            lovVC.tableLovDelegate = self;
            lovVC.field = self;
            lovVC.addable = self.canAddToLov;
            return lovVC;
        }
    }
    return nil;
}

@end
