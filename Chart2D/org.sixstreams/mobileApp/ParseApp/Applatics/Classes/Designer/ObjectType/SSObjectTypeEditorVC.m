//
// AppliaticsObjectTypeEditorVC.m
// Appliatics
//
//  Created by Anping Wang on 9/30/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSObjectTypeEditorVC.h"
#import "SSObjectFieldEditorVC.h"
#import "SSTableViewVC.h"
#import "SSFilter.h"

@interface SSObjectTypeEditorVC ()
{
    IBOutlet UITextField *tfName;
    IBOutlet UITextField *tfDesc;
}

@end

@implementation SSObjectTypeEditorVC

#define FIELDS @"fields"

- (SSEntityEditorVC *) tableView:(id)tableView createEditor:(id)entity
{
    SSObjectFieldEditorVC * entityEditor = [[SSObjectFieldEditorVC alloc]init];
    entityEditor.parentId = [self.item2Edit objectForKey:REF_ID_NAME];
    entityEditor.item2Edit = entity;
    entityEditor.itemType = OBJECT_FIELD;
    return entityEditor;
}

- (NSString *) cellText:(id) rowItem atCol:(int) col
{
    return [rowItem objectForKey:NAME];
}

- (void) entityWillSave:(id) entity
{
    [entity setValue:tfName.text forKey:NAME];
    [entity setValue:tfDesc.text forKey:DESC];
}

- (void) uiWillUpdate:(id) entity
{
    if (entity)
    {
        tfName.text = [entity objectForKey:NAME];
        tfDesc.text = [entity  objectForKey:DESC];
        
        tvDetails.objects = [entity objectForKey:FIELDS];
        
        [tvDetails.predicates addObject:[SSFilter on:OBJECT_TYPE_ID op:EQ value:[entity objectForKey:REF_ID_NAME]]];
        tvDetails.objectType= OBJECT_FIELD;
        
        self.title = @"Update Class Definition";
        [tvDetails forceRefresh];
    }
}

@end
