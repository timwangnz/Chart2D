//
// AppliaticsWidgetWizardVC.m
// Appliatics
//
//  Created by Anping Wang on 6/30/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSWidgetWizardVC.h"
#import "SSColumnEditor.h"
#import "SSFilter.h"

#import "SSCheckBox.h"
#import "SSTableViewVC.h"

@interface SSWidgetWizardVC ()
{
    IBOutlet SSTableViewVC *tvColumns;
    __weak IBOutlet UITextField *tfName;
    __weak IBOutlet UITextField *tfDesc;
    
    __weak IBOutlet UITextField *tfType;
    __weak IBOutlet SSCheckBox *cbCollection;
    __weak IBOutlet UITextField *tfChildType;
    __weak IBOutlet UITextField *tfFilters;
    __weak IBOutlet UITextField *tfTitle;
}

@end

@implementation SSWidgetWizardVC
#define TYPE @"type"
#define FILTERS @"filters"
#define COLLECTION @"collection"
#define APP_ID @"applId"
#define CATEGORY_ID @"catId"
#define VIEW_ID @"viewId"
#define BINDING @"binding"
#define TITLE_BINDING @"titleBinding"


- (void) entityWillSave:(id) entity
{
    [entity setValue:tfName.text forKey:NAME];
    [entity setValue:tfDesc.text forKey:DESC];
    [entity setValue:tfType.text forKey:TYPE];
    [entity setValue:tfFilters.text forKey:FILTERS];
    [entity setValue:[NSNumber numberWithBool:cbCollection.selected] forKey:COLLECTION];
    [entity setValue:tfChildType.text forKey:SS_OBJECT_TYPE];
    
    [entity setValue:self.application forKey:APP_ID];
    [entity setValue:self.category forKey:CATEGORY_ID];
    [entity setValue:self.viewId forKey:VIEW_ID];
    [entity setValue:tfTitle.text forKey:BINDING];
}

- (void) uiWillUpdate:(id) entity
    {
    tfName.text = [entity valueForKey:NAME];
    tfType.text = [entity  valueForKey:TYPE];
    tfDesc.text = [entity  valueForKey:DESC];
    cbCollection.selected = [[entity  valueForKey:COLLECTION] boolValue];
    tfChildType.text = [entity  valueForKey:SS_OBJECT_TYPE];
    tfFilters.text = [entity  valueForKey:FILTERS];
    self.application = [entity  valueForKey:APP_ID];
    self.category = [entity  valueForKey:CATEGORY_ID];
    self.viewId = [entity  valueForKey:VIEW_ID];
    tfTitle.text = [entity valueForKey:TITLE_BINDING];
    tvColumns.objectType= COLUMN_DEF;
        
    [tvColumns.predicates addObject:[SSFilter on:VIEW_ID op:EQ value:[entity objectForKey:REF_ID_NAME]]];

}

@end
