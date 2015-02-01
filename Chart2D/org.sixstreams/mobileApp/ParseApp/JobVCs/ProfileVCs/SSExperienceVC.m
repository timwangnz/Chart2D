//
//  SSExperienceVC.m
//  JobsExchange
//
//  Created by Anping Wang on 3/5/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSExperienceVC.h"

@implementation SSExperienceVC

- (void)uiWillUpdate:(id)item
{
    self.title = @"Experience";
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
