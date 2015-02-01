//
//  SSEducationVC.m
//  JobsExchange
//
//  Created by Anping Wang on 3/5/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSEducationVC.h"
#import "SSJobApp.h"
#import "SSDateTextField.h"
#import "SSLovTextField.h"
#import "SSRoundTextView.h"

@interface SSEducationVC ()
{
    
}

@end

@implementation SSEducationVC

- (void)uiWillUpdate:(id)entity
{
    [super uiWillUpdate:entity];
    self.title = @"Education";
    [self linkEditFields];
}

- (IBAction) save
{
    
    if(self.entityEditorDelegate && [self.entityEditorDelegate respondsToSelector:@selector(entityEditor:didSave:)])
    {
        [self.entityEditorDelegate entityEditor:self didSave:self.item2Edit];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
