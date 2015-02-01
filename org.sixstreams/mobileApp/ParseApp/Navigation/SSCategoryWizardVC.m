//
// AppliaticsCategoryWizardVC.m
// Appliatics
//
//  Created by Anping Wang on 7/14/13.
//

#import "SSCategoryWizardVC.h"
#import "SSConnection.h"
#import "SSCategoryEditorVC.h"
#import "SSNavMenuVC.h"
#import "SSFilter.h"
#import "SSProfileVC.h"

@interface SSCategoryWizardVC ()<SSEntityEditorDelegate>
{
}

@end

@implementation SSCategoryWizardVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = APP_CATEGORY;
   
    self.title = @"Categories";
    self.addable = YES; 
    self.editable = YES;
    self.titleKey = NAME;
    self.cancellable = YES;
    self.ascending = YES;
    self.orderBy = SEQUENCE;
    //[self.predicates addObject:[SSFilter on:AUTHOR op:EQ value: [SSProfileVC profileId]]];
}

- (void) entityEditor:(id)editor didSave:(id)entity
{
    [self forceRefresh];
    if(self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:didAdd:)])
    {
        [self.tableViewDelegate tableViewVC:self didAdd:entity];
    }
}

- (SSEntityEditorVC *) createEditorFor:(id) item
{
    SSCategoryEditorVC *editor = [[SSCategoryEditorVC alloc]init];
    editor.entityEditorDelegate = self;
    editor.itemType = self.objectType;
    editor.item2Edit = item;
    editor.readonly =   NO;
    return editor;
}

- (void) forceRefresh
{
    [super forceRefresh];
    [self.menuVC forceRefresh];
}

- (void) cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
