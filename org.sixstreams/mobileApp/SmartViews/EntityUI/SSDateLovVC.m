//
//  CoreDateLov.m
//  CoreCrm
//
//  Created by Anping Wang on 11/14/12.
//  Copyright (c) 2012 Anping Wang. All rights reserved.
//

#import "SSDateLovVC.h"
#import "SSAttrCell.h"

@interface SSDateLovVC ()
{
    NSString *entityName;
    SSAttrCell *editor;
    IBOutlet UIDatePicker *datePicker;
}

@end

@implementation SSDateLovVC
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    datePicker.datePickerMode = self.datePickerMode;
}

- (void) cellEdtior : (SSAttrCell*) cellEditor selectValueFor :(NSString *) attrName
{
    entityName = attrName;
    editor = cellEditor;
    self.title = attrName;
}

- (IBAction)onDatePicked:(id) sender
{    
    [editor setDateFromLov : datePicker.date forEntity:entityName];
}

@end
