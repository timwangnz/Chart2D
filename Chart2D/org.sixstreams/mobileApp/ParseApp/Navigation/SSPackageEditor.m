//
// AppliaticsApplicationEditor.m
// Appliatics
//
//  Created by Anping Wang on 9/26/13.
//

#import "SSPackageEditor.h"
#import "SSTableViewVC.h"
#import "SSFilter.h"

@interface SSPackageEditor ()<SSEntityEditorDelegate, SSListOfValueDelegate, SSTableViewVCDelegate>
{
    IBOutlet UITextField *tfName;
    IBOutlet UITextView *tvDesc;
}

@end

@implementation SSPackageEditor


- (void) listOfValues:(id) tableView didSelect : (id) entity
{
    //application selected
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:[entity objectForKey:REF_ID_NAME] forKey:APPLICATION_ID];
    [dic setObject:[entity objectForKey:NAME] forKey:NAME];
    [dic setObject:[self.item2Edit objectForKey:REF_ID_NAME] forKey:PACKAGE_ID];
    
    [self createEntity:dic OfType:APP_VIEW_SUBSCRIPTION onSuccess:^(id data) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void) entityWillSave:(id) entity
{
    [entity setObject:tfName.text forKey:NAME];
    [entity setObject:tvDesc.text forKey:DESC];
    [entity setObject:self.categoryId forKey:CATEGORY];
}

- (void) entityEditor:(id)editor didSave:(id)entity
{
    if(self.entityEditorDelegate && [self.entityEditorDelegate respondsToSelector:@selector(entityEditor:didSave:)])
    {
        [self.entityEditorDelegate entityEditor:self didSave:entity];
    }
}

- (void) uiWillUpdate:(id) entity
{
    [super uiWillUpdate:entity];
    tfName.text = [entity objectForKey:NAME];
    tvDesc.text = [entity  objectForKey:DESC];
    tvDetails.objectType= APP_VIEW_SUBSCRIPTION;
    tvDetails.titleKey = NAME;
    tvDetails.tableViewDelegate = self;
    NSString *packageId = [entity objectForKey:REF_ID_NAME];

    if(packageId != nil)
    {
        [tvDetails.predicates addObject:[SSFilter on:PACKAGE_ID op:EQ value:packageId]];
        [tvDetails forceRefresh];
    }
    self.title = @"My Application";
}

@end
