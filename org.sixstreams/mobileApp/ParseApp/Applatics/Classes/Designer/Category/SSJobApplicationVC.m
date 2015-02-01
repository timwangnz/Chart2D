//
//  SSApplicationVC.m
//  SixStreams
//
//  Created by Anping Wang on 3/9/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSJobApplicationVC.h"
#import "SSViewDefWidardVC.h"

@interface SSJobApplicationVC ()<SSEntityEditorDelegate>
{

}

@end

@implementation SSJobApplicationVC

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = APP_VIEW;
  
    self.title = @"Applications";
    self.addable = YES;
    self.titleKey = NAME;
    self.editable = YES;
    self.cancellable = YES;
}

- (SSEntityEditorVC *) createEditorFor:(id) item
{
    SSViewDefWidardVC * entityEditor = [SSViewDefWidardVC viewWizard:self for:item];
    entityEditor.entityEditorDelegate = self;
    entityEditor.itemType = APP_VIEW;
    entityEditor.item2Edit = item;
    return entityEditor;
}

- (void) entityEditor:(id) editor didSave : (id) entity
{
    [self refreshUI];
}



@end
