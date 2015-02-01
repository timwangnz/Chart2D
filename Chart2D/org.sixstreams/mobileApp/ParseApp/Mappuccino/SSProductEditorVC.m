//
//  SSProductEditorVC.m
//  SixStreams
//
//  Created by Anping Wang on 4/8/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSProductEditorVC.h"
#import "SSRoundTextView.h"
#import "SSValueField.h"

@interface SSProductEditorVC ()
{
    IBOutlet SSRoundTextView *tvDescription;
    IBOutlet SSValueField *tfCategory;
    IBOutlet SSValueField *tfPrice;
    IBOutlet SSValueField *tfName;
}
@end

@implementation SSProductEditorVC
- (void)uiWillUpdate:(id)entity
{
    tvDescription.attrName = DESC;
    tfCategory.attrName = CATEGORY;
    tfPrice.attrName = PRICE;
    tfName.attrName = NAME;
    
    tvDescription.text = [entity objectForKey:tvDescription.attrName];
    tfName.value = [entity objectForKey:tfName.attrName];
    tfPrice.value = [entity objectForKey:tfPrice.attrName];
    tfCategory.value = [entity objectForKey:tfCategory.attrName];
    self.title = @"Products";
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
