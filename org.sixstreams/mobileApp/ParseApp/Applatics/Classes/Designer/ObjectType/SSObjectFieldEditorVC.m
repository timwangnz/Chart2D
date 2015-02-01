//
// AppliaticsObjectFieldEditorVC.m
// Appliatics
//
//  Created by Anping Wang on 9/30/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSObjectFieldEditorVC.h"
#import "IconsLayoutView.h"
#import "SSLovTextField.h"
#import "SSCheckBox.h"
#import "SSTableViewVC.h"
#import "SSObjectTypeVC.h"

@interface SSObjectFieldEditorVC ()<SSLovTextFieldDelegate>
{
    IBOutlet SSCheckBox *bRequired;
    IBOutlet UITextView *tfMetaData;
    IBOutlet UISegmentedControl *scDataType;
    IBOutlet UITextField *tfDesc;
    IBOutlet UITextField *tfName;
    IBOutlet SSLovTextField *lovMetaTypes;
    BOOL isAdding;
}
- (IBAction)changeType:(id)sender;

@end

@implementation SSObjectFieldEditorVC

- (IBAction)changeType:(id)sender
{
    lovMetaTypes.text = nil;
}
- (void) entityDidSave:(id)object
{
    if (isAdding)
    {
        self.item2Edit = [NSMutableDictionary dictionary];
        [tfName becomeFirstResponder];
        [self uiWillUpdate:self.item2Edit];
    }
    else
    {
        [self cancel];
    }
}

- (NSDictionary *) listOfValuesFor : (SSLovTextField *) lovField
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (scDataType.selectedSegmentIndex == 5)
    {
        NSArray *items = [SSObjectTypeVC getObjectTypes];
        for (id item in items)
        {
            [dict setObject:[item objectForKey:NAME] forKey:[item objectForKey:NAME]];
        }
    }
    if (scDataType.selectedSegmentIndex == 0)
    {
        NSArray *items = [NSArray arrayWithObjects:NAME,@"category",@"currency",@"duration",@"email",@"phone",@"address",@"url", nil];
        for (id item in items)
        {
            [dict setObject:item forKey:item];
        }
    }
    
    return dict;
}

- (void) entityWillSave:(id) entity
{
    [entity setObject:tfName.text forKey:NAME];
    [entity setObject:tfDesc.text forKey:DESC];
    [entity setObject:self.parentId forKey:OBJECT_TYPE_ID];
    [entity setObject:tfMetaData.text forKey:META_DATA];
    [entity setObject:lovMetaTypes.text forKey:META_TYPE];
    [entity setObject:[NSNumber numberWithInteger:scDataType.selectedSegmentIndex] forKey:DATA_TYPE];
    [entity setObject:[NSNumber numberWithBool:bRequired.selected] forKey:REQUIRED];
}

- (void) uiWillUpdate:(id) entity
{
    tfName.text = [entity objectForKey:NAME];
    tfDesc.text = [entity  objectForKey:DESC];
    tfMetaData.text = [entity  objectForKey:META_DATA];
    lovMetaTypes.text = [entity  objectForKey:META_TYPE];
    lovMetaTypes.attrName = META_TYPE;
    lovMetaTypes.lovDelegate = self;
    
    scDataType.selectedSegmentIndex =[[entity  objectForKey:DATA_TYPE] intValue];
    
    isAdding = [entity count] == 0 ;
    
    self.title = isAdding ? @"Add Field Definition" : @"Update Field Definition";
    
    [bRequired setSelected:[[entity objectForKey:REQUIRED] boolValue]];
    
    
}

@end
