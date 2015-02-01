//
//  CommonSetupEditorVC.m
//  FileSync
//
//  Created by Anping Wang on 10/8/12.
//  Copyright (c) 2012 s. All rights reserved.
//
#import "SSProfileVC.h"

#import "SSSettingAttributeEditorVC.h"

@interface SSSettingAttributeEditorVC ()
{
    IBOutlet UITextView *tvDetails;
}

@end

@implementation SSSettingAttributeEditorVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Edit Property";
    }
    return self;
}

- (void) save
{
    if (self.propertyEditorDelegate)
    {
        [self.propertyEditorDelegate valueDidChange:tvDetails.text];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    if (self.propertyEditorDelegate)
    {
        id value2Edit = [_propertyEditorDelegate valueToEdit];
        
        self.title = [value2Edit objectForKey:@"name"];
        
        NSString *type = [value2Edit objectForKey:@"type"];
       
        
        tvDetails.editable = [SSProfileVC isAdmin];
        tvDetails.backgroundColor = tvDetails.editable ? [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] : [UIColor clearColor];
        tvDetails.secureTextEntry = [@"Y" isEqualToString:[value2Edit objectForKey:@"isSecret"]];
        
        if ([type isEqualToString:@"email"])
        {
            tvDetails.keyboardType = UIKeyboardTypeEmailAddress;
        }
        else if ([type isEqualToString:@"phone"])
        {
            tvDetails.keyboardType = UIKeyboardTypePhonePad;
        }
        
        id value = [value2Edit objectForKey:@"value"];
        if ([value isKindOfClass:[NSString class]]) {
            tvDetails.text = value;
        }
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            
        }
        if([SSProfileVC isAdmin])
        {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil;
        }

    }
}

@end
