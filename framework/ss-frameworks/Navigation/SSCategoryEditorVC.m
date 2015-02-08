//
// AppliaticsCategoryEditorVC.m
// Appliatics
//
//  Created by Anping Wang on 9/26/13.
//

#import "SSCategoryEditorVC.h"
#import "SSConnection.h"
#import "SSPackageEditor.h"
#import "SSTableViewVC.h"
#import "SSFilter.h"

@interface SSCategoryEditorVC ()<SSTableViewVCDelegate, SSEntityEditorDelegate>
{
    IBOutlet UITextField *tfName;
    IBOutlet UITextView *tfDesc;
}

@end

@implementation SSCategoryEditorVC

- (SSEntityEditorVC *) tableViewVC:(id) tableViewVC createEditor : (id) entity;
{
    SSPackageEditor * entityEditor = [[SSPackageEditor alloc]init];
    entityEditor.categoryId = [self.item2Edit objectForKey:REF_ID_NAME];
    entityEditor.entityEditorDelegate = self;
    entityEditor.item2Edit = entity;
    entityEditor.itemType = APPLICATION;
    return entityEditor;
}

- (void) entityEditor:(id) editor didSave : (id) entity
{
    [tvDetails forceRefresh];
    if(self.entityEditorDelegate && [self.entityEditorDelegate respondsToSelector:@selector(entityEditor:didSave:)])
    {
        [self.entityEditorDelegate entityEditor:self didSave:entity];
    }
}

- (void) entityWillSave:(id) entity
{
    [entity setValue:tfName.text forKey:NAME];
    [entity setValue:tfDesc.text forKey:DESC];
}

- (void) uiWillUpdate:(id) entity
{
    [super uiWillUpdate:entity];
    tfName.text = [entity objectForKey:NAME];
    tfDesc.text = [entity  objectForKey:DESC];
    NSString *categoryId = [entity objectForKey:REF_ID_NAME];
    tvDetails.titleKey = NAME;
    tvDetails.orderBy = SEQUENCE;
    tvDetails.ascending = YES;
    tvDetails.tableViewDelegate = self;
    
    if (categoryId != nil)
    {
        [tvDetails.predicates addObject:[SSFilter on:CATEGORY op:EQ value:categoryId]];
        tvDetails.objectType= APPLICATION;
        tvDetails.editable = YES;
        [tvDetails forceRefresh];
    }
    self.title = categoryId ? @"Update Category" : @"Add Category";
}


@end
