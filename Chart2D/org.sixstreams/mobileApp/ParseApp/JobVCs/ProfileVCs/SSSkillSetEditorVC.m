//
//  SSSkillSetEditorVC.m
//  SixStreams
//
//  Created by Anping Wang on 4/2/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSSkillSetEditorVC.h"
@interface SSSkillSetEditorVC ()
{
    //IBOutlet UILabel *lJobTitle;
}

@end

@implementation SSSkillSetEditorVC

- (void)uiWillUpdate:(id)entity
{
    self.title = @"Skills";
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
