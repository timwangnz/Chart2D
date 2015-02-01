//
//  SSDatePickerVC.m
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSDatePickerVC.h"
#import "SSValueField.h"
#import "SSLovTextField.h"

@interface SSDatePickerVC ()

@end

@implementation SSDatePickerVC

- (IBAction)save:(id)sender
{
    [super save:sender];
    self.field.value = self.dpDate.date;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.field.value)
    {
        self.dpDate.date = self.field.value;
    }
    self.dpDate.datePickerMode = self.mode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Pick Date";
    self.dpDate.date = self.field.value ? self.field.value : [NSDate date];
}


@end
