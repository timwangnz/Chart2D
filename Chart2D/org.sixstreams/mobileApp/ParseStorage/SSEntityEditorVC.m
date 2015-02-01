//
//  SSEntityEditorVC.m
// Appliatics
//
//  Created by Anping Wang on 10/6/13.
//  Copyright (c) 2013 Oracle. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>

#import "SSEntityEditorVC.h"
#import "SSConnection.h"
#import "SSTableViewVC.h"
#import "SSValueField.h"
#import "SSSecurityVC.h"
#import "SSCommentVC.h"
#import "SSCommentsVC.h"
#import "SSProfileEditorVC.h"
#import "SSProfileVC.h"
#import "SSRoundTextView.h"
#import "SSApp.h"
#import "SSAddress.h"
#import "SSFollowVC.h"
#import "SSLovTextField.h"
#import "SSValueLabel.h"
#import "SSBooleanEditor.h"
#import "SSListValueField.h"
#import "SSJSONUtil.h"
#import "SSCheckBox.h"
#import "SSSlider.h"
#import "SSOptionsEditor.h"
#import "SSAddressField.h"

#import "SSFilter.h"

typedef void (^CallbackBlock)(id entity);

@interface SSEntityEditorVC ()<UIActionSheetDelegate, SSTableViewVCDelegate, ProcessImageDelegate, SSImageViewDelegate,
                            SSValueFieldDelegate, SSListOfValueFieldDelegate, UITextFieldDelegate, UITextViewDelegate>
{
    BOOL itemInitialized;
    BOOL isIcon;
    id originalItem;
    UIImage *image2Save;
}

@end

@implementation SSEntityEditorVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!itemInitialized)
    {
        if (!self.item2Edit)
        {
            self.item2Edit = [[NSMutableDictionary alloc]init];
            self.isCreating = YES;
        }
        
        [self initItem];
    }
    [self uiWillUpdate:self.item2Edit];
}

//profile wrapper

- (NSString *) profileId
{
    return [SSProfileVC profileId];
}

- (id) profile
{
    return [SSProfileVC profile];
}

- (IBAction)showAuthorProfile:(id)sender {
    id userInfo = [self.item2Edit objectForKey:USER_INFO];
    NSString *profileId = [userInfo objectForKey:REF_ID_NAME];
    SSProfileEditorVC *profileEditor = [[SSProfileEditorVC alloc]init];
    [profileEditor viewProfile:profileId onSuccess:^(id data) {
        [self.navigationController pushViewController:profileEditor animated:YES];
    } onFailure:^(NSError *error) {
        [self showAlert:
         [NSString stringWithFormat: @"%@ is no longer with us!", [userInfo objectForKey:@"name"]] withTitle:@"Sorry"];
    }];
}

//utilities
- (id) value:(id) item attrName:(NSString *) attrName
{
    id value = [[SSApp instance] value:item forKey:attrName];//[item objectForKey:attrName];
    if (value == nil)
    {
        return @"";
    }
    return value;
}

- (void) walkViewTree:(UIView *) view block:(CallbackBlock) block
{
    for(UIView *childView in view.subviews)
    {
        block(childView);
        [self walkViewTree:childView block:block];
    }
}
//crud
- (void) saveOnSuccess:(OnCallback)callback
{
    [SSSecurityVC checkLogin:self withHint:@"Save" onLoggedIn:^(id user) {
        [self saveInternal:callback];
    }];
}

- (IBAction)deleteAction :(id)sender
{
    [self deleteItem:^(id data) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (IBAction) save
{
    if(self.valueChanged)
    {
        [SSSecurityVC checkLogin:self withHint:@"Save" onLoggedIn:^(id user) {
            [self saveInternal:^(id data) {
                if(self.isCreating)
                {
                    [self showAlert:@"Created succesfully" withTitle:@"Great"];
                    self.isCreating = NO;
                }
                else{
                    [self showAlert:@"Saved succesfully" withTitle:@"Good"];
                }
                [self uiWillUpdate:self.item2Edit];
            }];
        }];
    }
}

- (void) saveInternal:(OnCallback)callback
{
    [self hideKeyboard:self.view];
    if (![self checkSaveable])
    {
        return;
    }
    if (!self.itemType)
    {
        DebugLog(@"Failed to save due to unspecified item type");
        return;
    }
    [self.item2Edit removeObjectForKey:SEARCHABLE_WORDS];
    [self rewriteBeforeSave];
    [self entityWillSave:self.item2Edit];
    
    if (![self entityShouldSave:self.item2Edit])
    {
        return;
    }
    
    if (self.entityEditorDelegate) {
        if([self.entityEditorDelegate respondsToSelector:@selector(entityEditor:shouldSave:)])
        {
            if (![self.entityEditorDelegate entityEditor:self shouldSave:self.item2Edit]) {
                return;
            }
        }
    }
    
    for(NSString *key in [self.item2Edit allKeys])
    {
        if ([self isAttributeTranient:key])
        {
            [self.item2Edit removeObjectForKey:key];
        }
    }
    [self doSave:callback];
}

- (void) doSave:(OnCallback)callback
{
    [[SSConnection connector] createObject: self.item2Edit
                                    ofType: self.itemType
                                 onSuccess: ^(NSDictionary *newObject){
                                     self.item2Edit = newObject;
                                     
                                     [self saveImageOnSuccess:^(id data) {
                                         self.valueChanged = NO;
                                         if(self.entityEditorDelegate && [self.entityEditorDelegate respondsToSelector:@selector(entityEditor:didSave:)])
                                         {
                                             [self.entityEditorDelegate entityEditor:self didSave:newObject];
                                         }
                                         [self entityDidSave:newObject];
                                         if (callback) {
                                             callback(newObject);
                                         }
                                         
                                     }];
                                 }
                                 onFailure: ^(NSError *error){
                                     if(self.entityEditorDelegate && [self.entityEditorDelegate respondsToSelector:@selector(entityEditor:didFail:)])
                                     {
                                         [self.entityEditorDelegate entityEditor:self didFail:error];
                                     }
                                     [self entitySaveFailed:error];
                                     if (callback) {
                                         callback(error);
                                     }
                                 }];
}

- (void) deleteItem :(OnCallback) onSuccess;
{
    if (self.item2Edit == nil) {
        DebugLog(@"Item not assigned for delete");
        return;
    }

    [[SSConnection connector] deleteObject:self.item2Edit
                                    ofType:self.itemType
                                 onSuccess:^(NSDictionary *data) {
                                     if (self.entityEditorDelegate && [self.entityEditorDelegate respondsToSelector:@selector(entityEditor:didDelete:)])
                                     {
                                         [self.entityEditorDelegate entityEditor:self didDelete:self.item2Edit];
                                     }
                                     if (onSuccess)
                                     {
                                         onSuccess(data);
                                     }
                                 } onFailure:^(NSError *error) {
                                     //show errors
                                 }];
}

- (BOOL) entityShouldSave:(id) object
{
    return YES;
}

- (void) entityWillSave:(id) entity
{
    //override
}

- (void) entityDidSave:(id) object
{
    [self hideKeyboard:self.view];
}


- (IBAction) edit :(id)sender
{
    SSEntityEditorVC *entityVC = (SSEntityEditorVC*) [[SSApp instance] entityVCFor: self.itemType];
    if (!entityVC)
    {
        [self showAlert:@"Failed to create editor" withTitle:@"Error"];
        return;
    }
    entityVC.readonly = NO;
    entityVC.entityEditorDelegate = self.entityEditorDelegate;
    [entityVC updateEntity:self.item2Edit OfType: self.itemType];
    entityVC.title = @"Edit";
    
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]
                                               initWithTitle: @""
                                               style: UIBarButtonItemStylePlain
                                               target: self action: @selector(confirmDone)]];
    
    [self.navigationController pushViewController:entityVC animated:YES];
}
//end crud

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [imageEditor pickFromLib:self];
    }
    if (buttonIndex == 1)
    {
        [imageEditor takePhoto:self];
    }
}

- (void) actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}

//search
- (SSSearchVC *) createSearchVC
{
    SSSearchVC *search = [[SSSearchVC alloc]init];
    search.objectType = self.itemType;
    search.tableViewDelegate = [SSApp instance];
    search.entityEditorClass = [[SSApp instance] editorClassFor:search.objectType];
    return search;
}

- (IBAction) findSimilarObjects:(id)sender
{
    SSTableViewVC *search = [self createSearchVC];
    search.predicates = [self filtersForSimilarObjects];
    if (search.entityEditorClass)
    {
        [self.navigationController pushViewController:search animated:YES];
    }
    else
    {
        [self showAlert:@"No editor found" withTitle:@"Error"];
    }
}

- (NSMutableArray *) filtersForSimilarObjects
{
    NSMutableArray *filters = [NSMutableArray array];
    [self walkViewTree:self.view block:^(UIView *childView) {
        if ([childView isKindOfClass:SSValueField.class])
        {
            SSValueField *valueField = (SSValueField *) childView;
            if (valueField.filterable)
            {
                [filters addObject:[SSFilter on:valueField.attrName op:EQ value:valueField.value]];
            }
        }
    }];
    return filters;
}

- (void) searchWithFilter:(UIButton *) field
{
    SSValueField *valueField = (SSValueField *) field.superview;
    if (valueField.value)
    {
        if (self.entityEditorDelegate && [self.entityEditorDelegate respondsToSelector:@selector(entityEditor:selectedFilter:)])
        {
            [self.entityEditorDelegate entityEditor:self selectedFilter:[SSFilter on:valueField.attrName op:EQ value:valueField.value]];
        }
        else
        {
            SSTableViewVC *search = [self createSearchVC];
            search.titleKey = self.titleKey;
            search.iconKey = REF_ID_NAME;
            search.defaultHeight = 56;
            //search.subtitleKey =
            
            [search.predicates addObject:[SSFilter on:valueField.attrName op:EQ value:valueField.value]];
            
            search.title = valueField.text;
            
            if (search.entityEditorClass)
            {
                [search refreshOnSuccess:^(id data) {
                    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                                   initWithTitle: @""
                                                   style: UIBarButtonItemStylePlain
                                                   target: nil action: nil];
                    
                    [self.navigationItem setBackBarButtonItem: backButton];
                    [self.navigationController pushViewController:search animated:YES];
                } onFailure:^(NSError *error) {
                    [self showAlert:@"Please try again later" withTitle:@"Error"];
                }];
                
            }
            else{
                [self showAlert:@"No editor found" withTitle:@"Error"];
            }
        }
    }
}
//flow actions

- (IBAction) nextStep:(id)sender
{
    if (layoutTable.flow) {
        [layoutTable nextStep];
    }
}

- (IBAction) saveAndNext:(id)sender
{
    [self saveOnSuccess:^(id data) {
        if (layoutTable.flow) {
            [layoutTable nextStep];
        }
        
    }];
}

//layout management
- (UIView *) addLayoutSectionHeader:(NSString *) title
{
    UILabel *label = [[UILabel alloc]init];
    label.text = title;
    
    label.layer.cornerRadius = 0;
    label.frame = CGRectMake(10, 0.0, self.view.frame.size.width, 40.0);
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

- (UIButton *) addLayoutButton:(NSString *) title onTap:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.layer.cornerRadius = 5;
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = CGRectMake(10, 0.0, self.view.frame.size.width, 40.0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    return button;
}

- (IBAction)applyFilters
{
    if (self.entityEditorDelegate && [self.entityEditorDelegate respondsToSelector:@selector(entityEditor:applyFilters:)])
    {
        [self.entityEditorDelegate entityEditor:self applyFilters:[self getFilters]];
    }
}

- (IBAction)clearFilters
{
    [self.item2Edit removeAllObjects];
    [self uiWillUpdate:self.item2Edit];
    if (self.entityEditorDelegate && [self.entityEditorDelegate respondsToSelector:@selector(clearFilters)])
    {
        [self.entityEditorDelegate clearFilters];
    }
}

- (NSArray *) getFilters
{
    if (!self.filterMode)
    {
        return nil;
    }
    if (!self.filtersView)
    {
        return nil;
    }
    
    NSArray *values = [self getSubviews:SSValueField.class forView:self.filtersView];
    NSArray *checkBox = [self getSubviews:SSCheckBox.class forView:self.filtersView];
    return  [values arrayByAddingObjectsFromArray:checkBox];
}

- (NSArray *) getSubviews:(Class) clazz forView:(UIView *) parentView
{
    NSMutableArray * childViews = [NSMutableArray array];
    for (UIView * childView in parentView.subviews) {
        if ([childView isKindOfClass:clazz])
        {
            [childViews addObject:childView];
        }
        [childViews addObjectsFromArray:[self getSubviews:clazz forView:childView]];
    }
    return childViews;
}

- (void) linkEditFields
{
    if (self.filterMode)
    {
        if (self.filtersView)
        {
            [self linkEditorFields:self.filtersView];
        }
    }
    else{
        if(layoutTable)
        {
            for (UIView *view in layoutTable.childViews) {
                [self linkEditorFields:view];
                [self view:view readonly:self.readonly];
            }
            if (layoutTable.tableHeaderView)
            {
                [self linkEditorFields:layoutTable.tableHeaderView];
                [self view:layoutTable.tableHeaderView readonly:self.readonly];
            }
        }
        else
        {
            [self linkEditorFields:self.view];
            [self view:self.view readonly:self.readonly];
        }
    }
}

//editor events
- (BOOL) updateEditorView:(UIView *) childView
{
    return [self updateEditorView:childView readonly:self.readonly];
}

- (BOOL) updateEditorView:(UIView *) childView readonly:(BOOL) ro
{
    BOOL hasEditors = false;
    if ([childView isKindOfClass:[UITextField class]]) {
        UITextField *editor = (UITextField *) childView;
        editor.borderStyle = ro ? UITextBorderStyleNone : UITextBorderStyleRoundedRect;
        hasEditors = YES;
        if ([editor isKindOfClass:[SSValueField class]]) {
            SSValueField *valueField = (SSValueField *) childView;
            valueField.readonly = ro;
            if (ro){
                //overlay a button to act while the text edit is disabled.
                UIButton *overlay = [[UIButton alloc] init];
                [overlay setFrame:CGRectMake(0, 0, valueField.frame.size.width, valueField.frame.size.height)];
                if (valueField.filterable)
                {
                    [overlay addTarget:self action:@selector(searchWithFilter:) forControlEvents:UIControlEventTouchUpInside];
                    editor.textColor = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1];
                }
                [valueField addSubview:overlay];
            }
        }
    }else if ([childView isKindOfClass:[SSRoundTextView class]]) {
        SSRoundTextView *editor = (SSRoundTextView *) childView;
        if (ro)
        {
            [editor.layer setBorderWidth:0.0];
        }
        editor.editable = !ro;
        
        hasEditors = YES;
    }else if ([childView isKindOfClass:[SSBooleanEditor class]]) {
        SSBooleanEditor *editor = (SSBooleanEditor *) childView;
        if (ro)
        {
            [editor.layer setBorderWidth:0.0];
        }
        editor.enabled = !ro;
        
        hasEditors = YES;
    }else if ([childView isKindOfClass:[SSOptionsEditor class]]) {
        SSOptionsEditor *editor = (SSOptionsEditor *) childView;
        editor.enabled = !ro;
        hasEditors = YES;
    }
    
    else if ([childView isKindOfClass:[SSCheckBox class]]) {
        SSCheckBox *editor = (SSCheckBox *) childView;
        [editor setUserInteractionEnabled:!ro];
        hasEditors = YES;
    }
    else if ([childView isKindOfClass:[SSSlider class]]) {
        SSSlider *editor = (SSSlider *) childView;
        editor.enabled = !ro;
        hasEditors = YES;
    }
    return hasEditors;
}

- (void) view:(UIView *) view readonly:(BOOL) ro
{
    for(UIView *childView in [view subviews])
    {
        if (![self updateEditorView:childView readonly:ro]) {
            [self view:childView readonly:ro];
        }
    }
    [view setUserInteractionEnabled:YES];
}

- (void) valueChanged:(id) sender
{
    if(![sender valueForKey:@"attrName"])
    {
        DebugLog(@"Attribue name is not specified");
        return;
    }
    if ([sender isKindOfClass:SSBooleanEditor.class])
    {
        SSBooleanEditor *bEditor = (SSBooleanEditor*) sender;
        self.valueChanged = ![self.item2Edit[bEditor.attrName] isEqual:[NSNumber numberWithBool:bEditor.on]];
        [self.item2Edit setObject:[NSNumber numberWithBool:bEditor.on] forKey:bEditor.attrName];
    }
    if ([sender isKindOfClass:SSOptionsEditor.class])
    {
        SSOptionsEditor *bEditor = (SSOptionsEditor*) sender;
        self.valueChanged = ![self.item2Edit[bEditor.attrName] isEqual:[NSNumber numberWithInt:(int)bEditor.selectedSegmentIndex]];
        [self.item2Edit setObject:[NSNumber numberWithInt:(int)bEditor.selectedSegmentIndex] forKey:bEditor.attrName];
    }
    
    if ([sender isKindOfClass:SSCheckBox.class])
    {
        SSCheckBox *bEditor = (SSCheckBox*) sender;
        bEditor.value = [NSNumber numberWithBool:bEditor.isSelected];
        [self.item2Edit setObject:bEditor.value forKey:bEditor.attrName];
    }
    if ([sender isKindOfClass:SSSlider.class])
    {
        SSSlider *bEditor = (SSSlider*) sender;
        NSDecimalNumberHandler *rounder = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:bEditor.precision raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
        NSNumber *number = [NSDecimalNumber numberWithFloat:bEditor.value];
        NSDecimalNumber *rounded = [(NSDecimalNumber*)number decimalNumberByRoundingAccordingToBehavior:rounder];
        self.valueChanged = ![self.item2Edit[bEditor.attrName] isEqual:rounded];
        [self.item2Edit setObject:rounded forKey:bEditor.attrName];
    }
}

- (id) childAtPath:(NSString *) path of:(id) parent
{
    NSMutableArray *attrs = [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"."]];
    if ([attrs count] == 1)
    {
        return [parent objectForKey:path];//[[SSApp instance] value:parent forKey:path];
    }
    else{
        id child = [parent objectForKey:[attrs objectAtIndex:0]];
        if(child == nil)
        {
            return nil;
        }
        [attrs removeObject:[attrs objectAtIndex:0]];
        NSString * childPath = [attrs componentsJoinedByString:@"."];
        return [self childAtPath:childPath of:child];
    }
}


- (NSString *) displayValue:(NSString *) value of:(id) parent
{
    return [[SSApp instance] value:parent forKey:value];
}

- (BOOL) linkEditField:(UIView *) editField
{
    id entity = self.item2Edit;
    if([editField isKindOfClass:SSListValueField.class])
    {
        SSListValueField *field = (SSListValueField*) editField;
        field.item = self.item2Edit;
        field.editable = !self.readonly;
        field.parentVC = self;
        field.fieldDelegate=self;
    }else if([editField isKindOfClass: SSAddressField.class])
    {
        SSAddressField *address = (SSAddressField*) editField;
        if(address.attrName && [address.attrName length] > 0)
        {
            address.value = [entity valueForKey:address.attrName];
        }
        address.delegate = self;
    }else if([editField isKindOfClass: SSValueLabel.class])
    {
        SSValueLabel *label = (SSValueLabel*) editField;
        if(label.attrName && [label.attrName length] > 0)
        {
            label.text = [[SSApp instance] evaluate:label.attrName on:entity];
        }
    }else if([editField isKindOfClass:SSImageView.class])
    {
        SSImageView *imageView = (SSImageView*) editField;
        if(imageView.attrName && [imageView.attrName length] > 0)
        {
            NSArray *attrs = [imageView.attrName componentsSeparatedByString:@" "];
            NSMutableString *str = [[NSMutableString alloc] init];
            for (NSString *attrName in attrs){
                [str appendFormat:@"%@",[self childAtPath:attrName of:entity]];
            }
            imageView.url = str;
        }
        imageView.delegate = self;
    }
    else if([editField isKindOfClass:SSValueField.class])
    {
        SSValueField *field = (SSValueField*) editField;
        field.entity = self.item2Edit;
        if ([field isKindOfClass:SSLovTextField.class])
        {
            SSLovTextField *lov = (SSLovTextField*) field;
            lov.listOfValues =[[SSApp instance] getLov:field.attrName ofType:self.itemType];
            
            lov.displayValue = [[entity valueForKey:DISPLAY_VALUES] objectForKey:field.attrName];
            
            if (lov.allowMultiValues) {
                if ([lov.displayValue isKindOfClass:NSArray.class])
                {
                    field.value = [NSMutableArray arrayWithArray:lov.displayValue];
                }
                else
                {
                    field.value = nil;
                }
            }
            else
            {
                field.value = [entity valueForKey:field.attrName];
            }
        }
        else
        {
            field.value = [entity valueForKey:field.attrName];
        }
        
        field.delegate = self;
    } else if([editField isKindOfClass:SSBooleanEditor.class])
    {
        SSBooleanEditor *field = (SSBooleanEditor*) editField;
        field.on = [[entity valueForKey:field.attrName] boolValue];
        field.value = [NSNumber numberWithBool:field.on];
        [field addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventAllEvents];
        
    } else if([editField isKindOfClass:SSOptionsEditor.class])
    {
        SSOptionsEditor *field = (SSOptionsEditor*) editField;
        field.selectedSegmentIndex = [[entity valueForKey:field.attrName] intValue];
        [field addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventAllEvents];
    }
    else if([editField isKindOfClass:SSCheckBox.class])
    {
        SSCheckBox *field = (SSCheckBox*) editField;
        field.selected = [[entity valueForKey:field.attrName] boolValue];
        field.value = [NSNumber numberWithBool:field.selected];
        [field addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventAllEvents];
        
    } else if([editField isKindOfClass:SSRoundTextView.class])
    {
        SSRoundTextView *field = (SSRoundTextView*) editField;
        field.text = [entity valueForKey:field.attrName];
        field.delegate = self;
    } else if([editField isKindOfClass:SSSlider.class])
    {
        SSSlider *field = (SSSlider*) editField;
        field.value = [[entity valueForKey:field.attrName] floatValue];
        [field addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventAllEvents];
    } else if([editField isKindOfClass:SSListValueField.class])
    {
        SSListValueField *field = (SSListValueField*) editField;
        field.items = [self childAtPath:field.attrName of:entity];
        [field reloadData];
    }
    else
    {
        return NO;
    }
    return YES;
}

- (void) linkEditorFields:(UIView *) childView
{
    if(![self linkEditField:childView])
    {
        [self linkChildEditorFields:childView];
    }
}

- (void) linkChildEditorFields:(UIView *) view
{
    for (UIView *childView in [view subviews]) {
        [self linkEditorFields:childView];
    }
}

- (void) tableViewVC:(id)tableViewVC didLoad:(id)objects
{
    [layoutTable reloadData];
}

- (void) doLayout
{
    if(!layoutTable.flow)
    {
        if(self.isCommentable && !self.isAuthor && self.item2Edit[REF_ID_NAME])
        {
            SSCommentsVC *commentsVC = [self getCommentVC];
            commentsVC.titleKey = self.titleKey;
            //should show loading
            commentsVC.tableViewDelegate = self;
            [layoutTable addChildView:commentsVC.view];
            [commentsVC refreshOnSuccess:^(id data) {
                
            } onFailure:^(NSError *error) {
                //
            }];
        }
        
        if(self.isFollowable)
        {
            if (!self.isAuthor) {
                UIView * view = [self addLayoutButton:@"Follow" onTap:@selector(follow:)];
                [layoutTable addChildView: view];
                [self doIFollowThisOnCallback:^(id data) {
                    if ([data count] != 0)
                    {
                        [layoutTable replaceChildView:view with: [self addLayoutButton:@"Unfollow" onTap:@selector(unfollow:)]];
                    }
                }];
            }
            
            int followers = [[self.item2Edit objectForKey:FOLLOWERS] intValue];
            if (followers > 0)
            {
                [layoutTable addChildView: [self addLayoutButton : [NSString stringWithFormat:@"Followers (%d)", followers ] onTap:@selector(showFollowers:)]];
            }
        }
    }
}

- (void) uiWillUpdate:(id) entity
{
    if (entity)
    {
        if(!originalItem)
        {
            originalItem = [NSDictionary dictionaryWithDictionary:entity];
        }
        
        self.isAuthor = [[entity objectForKey:AUTHOR] isEqualToString:[SSProfileVC profileId]] || [[SSProfileVC profileId] isEqualToString:[entity objectForKey:REF_ID_NAME]];
        BOOL isEditable = self.isAuthor || [SSProfileVC isAdmin];
        if(isEditable)
        {
            if(self.readonly)
            {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
                
            }
            else
            {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                         initWithImage:[UIImage imageNamed:@"back-arrow"] landscapeImagePhone:[UIImage imageNamed:@"back-arrow"]
                                                         style: UIBarButtonItemStylePlain
                                                         target: self action: @selector(confirmDone)];
            }
        }
        if(iconView)
        {
            if(self.item2Edit)
            {
                iconView.owner = self.item2Edit[USERNAME];
                
                if (self.item2Edit[PICTURE_URL])
                {
                    iconView.isUrl = YES;
                    iconView.url = self.item2Edit[PICTURE_URL];
                    
                }
                else{
                    iconView.isUrl = NO;
                    iconView.url = self.item2Edit[REF_ID_NAME];
                    
                }
            }
        }
        if (self.titleKey && entity)
        {
            self.title = [self displayValue:self.titleKey of:entity];
        }
    }
}

- (void)confirmDone
{
    if(self.valueChanged)
    {
        [self showAlert : @"Save changes"
              withTitle : @"Entity Changed"
            cancelTitle : @"No"
                okTitle : @"YES"
               onSelect : ^(NSString *selectedTitle) {
            if([selectedTitle isEqualToString:@"YES"])
            {
                [self saveOnSuccess:^(id data) {
                    self.valueChanged = NO;
                }];
            }
            else
            {
                [self.item2Edit copy:originalItem];
                [self didCancel:self.item2Edit];
            }
            [self dismissEditor];
        }];
    }
    else
    {
        [self cancel];
    }
}

- (void) dismissEditor
{
    if(self.navigationController && [self.navigationController.viewControllers count]>1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if (self.navigationController) {
            
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                //
            }];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    }
}


- (void) cancel
{
    [self dismissEditor];
    [self didCancel:self.item2Edit];
}


+ (void) getObjectById:(NSString *) objectId
                ofType:(NSString *) objectType
           onScuccess :(OnCallback) onSuccess
{
    [[SSConnection connector] objectForKey:objectId ofType:objectType
                                 onSuccess:^(id data) {
                                     onSuccess(data);
                                 } onFailure:^(NSError *error) {
                                     onSuccess(nil);
                                 }];
}

- (void) updateData:(OnCallback) onSuccess
{
    onSuccess(self);
}

- (BOOL) isAttributeTranient:(NSString *) attrName
{
    __block BOOL isTransient = NO;
    [self walkViewTree:self.view block:^(id entity) {
        if ([entity conformsToProtocol:@protocol(SSFieldEditor)])
        {
            id<SSFieldEditor> field = entity;
            if ([field.attrName isEqualToString:attrName])
            {
                isTransient = field.transient;
            }
        }
    }];
    //
    if(layoutTable)
    {
        for(UIView *child in layoutTable.childViews)
        {
            [self walkViewTree:child block:^(id entity) {
                if ([entity conformsToProtocol:@protocol(SSFieldEditor)])
                {
                    id<SSFieldEditor> field = entity;
                    if ([field.attrName isEqualToString:attrName])
                    {
                        isTransient = field.transient;
                    }
                }
            }];
        }
    }
    return isTransient;
}

- (BOOL) checkSaveable
{
    __block NSMutableArray *missingFields = [NSMutableArray array];
    [self walkViewTree:self.view block:^(id entity) {
        if ([entity isKindOfClass:SSValueField.class])
        {
            id<SSFieldEditor> field = entity;
            if (field.required)
            {
                if(field.value == nil)
                {
                    [missingFields addObject:field];
                }
            }
        }
    }];

    if ([missingFields count]> 0)
    {
        [self showAlert:@"Missing required values" withTitle:@"Error"];
    }
    return [missingFields count] == 0;
}

//iterate through all value editor to execute some logic
- (id) isEditField:(UIView *) editField
{
    if([editField isKindOfClass:SSListValueField.class])
    {
        return editField;
    }else if([editField isKindOfClass: SSValueLabel.class])
    {
        return editField;
    }else if([editField isKindOfClass:SSImageView.class])
    {
        return editField;
    }
    else if([editField isKindOfClass:SSValueField.class])
    {
        return editField;
    } else if([editField isKindOfClass:SSBooleanEditor.class])
    {
        return editField;
    }else if([editField isKindOfClass:SSCheckBox.class])
    {
        return editField;
    } else if([editField isKindOfClass:SSRoundTextView.class])
    {
        return editField;
    } else if([editField isKindOfClass:SSSlider.class])
    {
        return editField;
    }
    else if([editField isKindOfClass:SSListValueField.class])
    {
        return editField;
    }
    else{
        return nil;
    }
}

- (void) onEachFieldEditor:(UIView *) view callblock: (CallbackBlock) callback
{
    if(![self isEditField: view])
    {
        for (UIView *childView in [view subviews]) {
            [self onEachFieldEditor:childView callblock:callback];
        }
    }
    else{
        callback(view);
    }
}


//
//item stored as following
//if it is an lov, will store its display value into a field called displayValues as hashmap and its value as attribute value
//if it is searchable, its display value will be added to searchable field
//
- (void) saveFields:(UIView *) view
{
    [self saveField:view];
    for (UIView *childView in [view subviews]) {
            [self saveFields:childView];
    }
}

- (void) saveField:(UIView *) childView
{
    if([childView isKindOfClass:SSListValueField.class])
    {
        SSListValueField *field = (SSListValueField*) childView;
        NSMutableArray *searchableWords = [self.item2Edit objectForKey:SEARCHABLE_WORDS];
        if (searchableWords == nil)
        {
            searchableWords = [NSMutableArray array];
            [self.item2Edit setValue:searchableWords forKey:SEARCHABLE_WORDS];
        }
        for (id item in field.items)
        {
            NSString *displayValue = [field displayValueFor:item];
            if (displayValue)
            {
                [searchableWords addObjectsFromArray:[displayValue toKeywordList]];
            }
        }
    }
    else if([childView isKindOfClass:SSValueField.class])
    {
        SSValueField *field = (SSValueField*) childView;
        if (field.searchable)
        {
            NSMutableArray *searchableWords = [self.item2Edit objectForKey:SEARCHABLE_WORDS];
            if (searchableWords == nil)
            {
                searchableWords = [NSMutableArray array];
                [self.item2Edit setValue:searchableWords forKey:SEARCHABLE_WORDS];
            }
           
            if([childView isKindOfClass:SSLovTextField.class])
            {
                [searchableWords addObjectsFromArray:[field.displayValue toKeywordList]];
            }
            else
            {
                [searchableWords addObjectsFromArray:[field.displayValue ? field.displayValue : field.value toKeywordList]];
            }
        }
        if([childView isKindOfClass:SSLovTextField.class])
        {
            SSLovTextField *field = (SSLovTextField*) childView;
            NSMutableDictionary *displayValues = [self.item2Edit objectForKey:DISPLAY_VALUES];
            if (!displayValues)
            {
                displayValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:field.displayValue, field.attrName, nil];
                [self.item2Edit setValue:displayValues forKey:DISPLAY_VALUES];
            }
            
            if(field.allowMultiValues)
            {
                if([field.value isKindOfClass:NSArray.class])
                {
                    NSMutableArray *items = [[NSMutableArray alloc]init];
                    
                    for (id item in field.value) {
                        [items addObject:item[REF_ID_NAME]];
                        [displayValues setValue:item[NAME] forKey:item[REF_ID_NAME]];
                    }
                    [self.item2Edit setValue:items forKeyPath:field.attrName];
                }
                else
                {
                    [displayValues setValue:field.displayValue forKey:field.attrName];
                }
            }
            else{
                if (field.value && field.text)
                {
                    [displayValues setValue:field.text forKey:field.value];
                }
            }
        }
    }
}

- (void) lookFields4Saving
{
    if(layoutTable)
    {
        for (UIView *view in layoutTable.childViews) {
            [self saveFields:view];
        }
        if (layoutTable.tableHeaderView)
        {
            [self saveFields:layoutTable.tableHeaderView];
        }
    }
    else
    {
        [self saveFields:self.view];
    }
}

- (void) rewriteBeforeSave
{
    SSAddress *address = [[SSAddress alloc] initWithDictionary:[self.item2Edit objectForKey:ADDRESS]];
    if(address)
    {
        [self.item2Edit setValue:address.city forKeyPath:CITY];
        if (address.latitude != 0)
        {
            self.item2Edit[GET_POINT] = [PFGeoPoint geoPointWithLatitude:address.latitude longitude:address.longitude];
        }
    }
    [self lookFields4Saving];
}

- (void) hideKeyboard:(UIView *) view
{
    for(UIView *child in [view subviews])
    {
        [child resignFirstResponder];
        [self hideKeyboard:child];
    }
}

- (void) didCancel:(id) object
{
    [self hideKeyboard:self.view];
}

- (void) entitySaveFailed:(NSError *) error
{
    
}

- (UIDatePicker *) pickADateWithTitle:(NSString *)title andMode:(UIDatePickerMode) mode
{
    UIDatePicker *datePickerView = [[UIDatePicker alloc] init];
    datePickerView.datePickerMode = mode;
    
    UIActionSheet *dateActionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                       delegate:self cancelButtonTitle:nil
                                         destructiveButtonTitle:nil otherButtonTitles:@"<", nil];
    
    [dateActionSheet showInView:self.view];
    [dateActionSheet addSubview:datePickerView];
   
    [dateActionSheet setBounds:CGRectMake(0,0,320, 400)];

    CGRect menuRect = dateActionSheet.frame;
    CGFloat orgHeight = menuRect.size.height;
    menuRect.origin.y -= 214; //height of picker
    menuRect.size.height = orgHeight+214;
    dateActionSheet.frame = menuRect;
    
    CGRect pickerRect = datePickerView.frame;
    pickerRect.origin.y = orgHeight;
    datePickerView.frame = pickerRect;

    return datePickerView;
}

- (void) updateEntityById:(NSString *) objectId OfType:(NSString *) entityType
{
    self.itemType = entityType;
    
    [[SSConnection connector] objectForKey:objectId
                                    ofType:entityType
                                 onSuccess:^(NSDictionary *newObject) {
                                     [self uiWillUpdate:newObject];
                                 }
                                 onFailure: ^(NSError *error) {
                                     //handle this
                                 }
     ];
}

- (void) listField:(id) listfield didAdd:(id) item
{
    self.valueChanged = YES;
}

- (void) listField:(id) listfield didDelete:(id) item
{
    self.valueChanged = YES;
}

- (void) listField:(id) listfield didUpdate:(id) item
{
   self.valueChanged = YES;
}

- (void) valueField:(SSValueField *)valueField valueChanged:(id)item
{
    self.valueChanged = YES;
    if([valueField isKindOfClass:SSLovTextField.class])
    {
        SSLovTextField *field = (SSLovTextField*) valueField;
        NSMutableDictionary *displayValues = [self.item2Edit objectForKey:DISPLAY_VALUES];
        if (!displayValues)
        {
            displayValues = [NSMutableDictionary dictionaryWithObjectsAndKeys:field.displayValue, field.attrName, nil];
            [self.item2Edit setValue:displayValues forKey:DISPLAY_VALUES];
        }
        else
        {
            [displayValues setValue:field.displayValue forKey:field.attrName];
        }
    }
    [self.item2Edit setValue:item forKey:valueField.attrName];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isKindOfClass:[SSValueField class]])
    {
        SSValueField *valueEditor = (SSValueField *) textField;
        if(valueEditor.attrName)
        {
            valueEditor.valueDelegate = self;
            SSValueEditorVC *candidateVC = [valueEditor getCandidateVC];
            if (candidateVC != nil)
            {
                candidateVC.parentVC = self;
                if([candidateVC isKindOfClass:SSTableLovVC.class])
                   {
                       SSTableLovVC *tableList = (SSTableLovVC *) candidateVC;
                       [tableList loadDataOnSuccess:^(id data) {
                           [candidateVC popupVC:candidateVC];
                       }];
                   }
                   else
                   {
                       [candidateVC popupVC:candidateVC];
                   }
                
                return NO;
            }
            else
            {
                CGRect rect = [self.view convertRect:CGRectMake(0, 0, valueEditor.frame.size.height, valueEditor.frame.size.width) fromView:valueEditor];
                [layoutTable scrollRectToVisible:rect animated:NO];
            }
        }
        else
        {
            DebugLog(@"Field does not have name defined");
        }
    }
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isKindOfClass:[SSValueField class]])
    {
        SSValueField *valueField = (SSValueField *) textField;
        if (valueField.attrName)
        {
            UIViewController *candidateVC = [valueField getCandidateVC];
            if (!candidateVC)
            {
                if ([textField.text length] > 0)
                {
                    valueField.value = valueField.text;
                    [self.item2Edit setValue:valueField.value forKey:valueField.attrName];
                }
                else
                {
                    [self.item2Edit removeObjectForKey:valueField.attrName];
                    valueField.value = nil;
                }
            }
        }
        [self linkEditFields];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)value
{
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView*) textView
{
    //we will show that field
    CGRect rect1 = textView.frame;
    rect1.origin.x = 0;
    rect1.origin.y = 0;
    CGRect rect = [self.view convertRect:rect1 fromView:textView];
    [layoutTable scrollRectToVisible:rect animated:YES];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView isKindOfClass:[SSRoundTextView class]])
    {
        SSRoundTextView *valueEditor = (SSRoundTextView *) textView;
        if (valueEditor.attrName && ![self.item2Edit[valueEditor.attrName] isEqualToString:textView.text]) {
            [self.item2Edit setValue:valueEditor.text forKey:valueEditor.attrName];
            self.valueChanged = YES;
        }
    }
    [self hideKeyboard:self.view];
}

- (void) updateEntity:(id) entity OfType:(NSString *) entityType
{
    self.item2Edit = entity ? entity : [NSMutableDictionary dictionary];
    self.itemType = entityType;
    [self uiWillUpdate:entity];
}

- (void) createEntity:(id) entity OfType:(NSString *) entityType onSuccess:(OnCallback) onSuccess
{
    [[SSConnection connector] createObject:entity ofType:entityType onSuccess:^(id data) {
        onSuccess(data);
    } onFailure:^(NSError *error) {
        //
    }];
}

- (void) deleteEntity:(NSString*) objectId OfType:(NSString *) entityType onSuccess:(OnCallback) onSuccess
{
    [[SSConnection connector] deleteObjectById:objectId ofType:entityType  onSuccess:^(id data) {
        onSuccess(data);
    } onFailure:^(NSError *error) {
        //
    }];
}

- (void) initItem
{

    if (!self.readonly)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                   target:self
                                   action:@selector(save)];
    }
    
    itemInitialized = YES;
}

//Image and video related code
#pragma Image delegate
- (void) imageView:(id) imageView didLoadImage:(id) image
{
    
}

- (void) imageView:(SSImageView *) imageView didSelect:(id) image;
{
    if (!self.readonly)
    {
        if (imageView.isList)
        {
            [self pickImg:imageView];
        }
        else
        {
            [self pickIcon:imageView];
        }
    }
}


- (void) processVideo:(id) url
{
    NSString *itemId =[self.item2Edit objectForKey:REF_ID_NAME];
    if (!itemId || !self.itemType)
    {
        //you can not upload a video without id or type
        return;
    }
    
    SSConnection *conn = [SSConnection connector];
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    if(videoData && [videoData length] > 0)
    {
        [conn uploadFile: videoData
                fileName: [NSString stringWithFormat:@"%@_%@", self.itemType, itemId]
             relatedType: self.itemType
               relatedId: itemId
                fileType: FILE_TYPE_VIDEO
                    desc: @""
               onSuccess:^(id data) {
                   [self showAlert:@"Your video has been uploaded" withTitle:@"Cool"];
               } onFailure:^(NSError *error) {
                   [self showAlert:@"Failed to upload, please try again" withTitle:@"Error"];
               }
         ];
    }
}

- (void) saveImageOnSuccess :(SuccessCallback) callback
{
    NSString *itemId =[self.item2Edit objectForKey:REF_ID_NAME];
    if (!self.isCreating)
    {
        callback(nil);
        return;
    }
    
    SSConnection *conn = [SSConnection connector];
    NSData *imageData = UIImageJPEGRepresentation(iconView.image, 0.5f);
    if(!isIcon)//files, mutiple
    {
        NSString *fileName = [NSString stringWithFormat:@"%@_%@", self.itemType, itemId];
        [conn uploadFile: imageData
                fileName: fileName
             relatedType: self.itemType
               relatedId: itemId
                fileType: FILE_TYPE_IMG
                    desc: @""
               onSuccess:^(id data) {
                   callback(data);
               } onFailure:^(NSError *error) {
                   [self showAlert:@"Failed to upload, please try again" withTitle:@"Error"];
               }
         ];
    }
    else//icon
    {
        [conn replaceFile: imageData
                 fileName: itemId
              relatedType: self.itemType
                relatedId: itemId
                 fileType: FILE_TYPE_IMG
                     desc: @""
                onSuccess:^(id data) {
                    [iconView replaceUrl:itemId];
                    callback(data);
                } onFailure:^(NSError *error) {
                    [self showAlert:@"Failed to upload, please try again" withTitle:@"Error"];
                }
         ];
    }
}

- (void) processImage: (UIImage *)image
{
    
    NSString *itemId =[self.item2Edit objectForKey:REF_ID_NAME];
    if (!itemId)
    {
        iconView.image = image;
        iconView.imageChanged = YES;
        return;
    }
    SSConnection *conn = [SSConnection connector];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
    if(!isIcon)//files, mutiple
    {
        NSString *fileName = [NSString stringWithFormat:@"%@_%@", self.itemType, itemId];
        [conn uploadFile: imageData
                fileName: fileName
             relatedType: self.itemType
               relatedId: itemId
                fileType: FILE_TYPE_IMG
                    desc: @""
               onSuccess:^(id data) {
                   iconView.image = image;
               } onFailure:^(NSError *error) {
                   [self showAlert:@"Failed to upload, please try again" withTitle:@"Error"];
               }
         ];
    }
    else//icon
    {
        [conn replaceFile: imageData
                 fileName: itemId
              relatedType: self.itemType
                relatedId: itemId
                 fileType: FILE_TYPE_IMG
                     desc: @""
                onSuccess:^(id data) {
                    [iconView replaceUrl:itemId];
                } onFailure:^(NSError *error) {
                    [self showAlert:@"Failed to upload, please try again" withTitle:@"Error"];
                }
         ];
    }
}

//each entity has one icon
- (IBAction)pickIcon:(id)sender
{
    isIcon = YES;
    [self pickImageInternal:sender];
}

//an entity can have many pictures
- (IBAction)pickImg:(id)sender
{
    isIcon = NO;
    [self pickImageInternal:sender];
}

- (IBAction)captureVideo:(id)sender {
    imageEditor = [[SSImageEditorVC alloc] initWithNibName:@"SSImageEditorVC_iPhone" bundle:nil];
    imageEditor.processImageDelegate = self;
    imageEditor.fromVC = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = imageEditor;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void) pickImageInternal:(id)sender
{
    if (self.readonly)
    {
        return;
    }
    
    imageEditor = [[SSImageEditorVC alloc] initWithNibName:@"SSImageEditorVC_iPhone" bundle:nil];
    imageEditor.processImageDelegate = self;
    imageEditor.fromVC = self;
    
    if(![self isIPad])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Get Photos"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"Load From Library", @"Take Photo", nil];
        
        UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
        if ([window.subviews containsObject:self.view]) {
            [actionSheet showInView:self.view];
        } else {
            [actionSheet showInView:window];
        }
        
    }
    else
    {
        UIImagePickerController *imgPickerVC = [[UIImagePickerController alloc]init];
        imgPickerVC.delegate = imageEditor;
        [self showPopup:imgPickerVC sender:sender];
    }
}

//social
- (IBAction)unfollow : (UIButton *)sender
{
    SSConnection *conn = [SSConnection connector];
    sender.enabled = NO;
    NSArray *filters = @[
                         [SSFilter on:AUTHOR op:EQ value:[self profileId]],
                         [SSFilter on:FOLLOW op:EQ value:[self.item2Edit objectForKey:REF_ID_NAME]]
                         ];
    [conn deleteByFilters:filters
                   ofType:SOCIAL_FOLLOW
                onSuccess:^(id data) {
                    sender.enabled = YES;
                    [self uiWillUpdate:self.item2Edit];
                } onFailure:^(NSError *error) {
                    //
                }];
}
/**
 To follow an object, you will be notified when the object is updated.
 You can follow at most 100 objects
 
 when an object is updated, a background process will be kicked off. The background process
 will iterate all the followers of the object, and update user private area with the information.
 This could be done in parallel.
 
 This can be short cutted by an activity algorithm. When loading activities, we will first load
 ids of objects that we follow, then load activities off that list.
 list of activities on objects we follow
 list of activities by person we follow
 
 An activity that is global whill be available to all the users.
 
 When user follows a person, his activities will be loaded, regardless if he follows an object or
 not.
 
 For example, if I follow robert, when he creates, updates, or deletes a job, i will get notified, however
 i will not get updated if someone, whom I dont follow, comments on the job.
 
 If I follow a job, then I get notified if the job is updated, deleted, or commented, regardless the author.
 
 **/
- (IBAction)follow : (UIButton *)sender
{
    SSConnection *conn = [SSConnection connector];
    sender.enabled = NO;
    id context = [[SSApp instance] contextualObject :self.item2Edit ofType:self.itemType];
    
    if (!context || [context isEqual:[NSNull null]])
    {
        [self showAlert:@"No context specified to folow" withTitle:@"Error"];
        return;
    }
    
    NSDictionary *follow = @{
                             FOLLOW: [self.item2Edit objectForKey:REF_ID_NAME],
                             CONTEXT_TYPE: [SSConnection objectType:self.itemType],
                             CONTEXT : context
                             };
    
    [conn createObject:[NSMutableDictionary dictionaryWithDictionary:follow]
                ofType:SOCIAL_FOLLOW
             onSuccess:^(id data) {
                 [self showAlert:
                  [NSString stringWithFormat: @"You are following %@ now", [context objectForKey:NAME]]
                       withTitle:@"Great"];
                 sender.enabled = YES;
                 [self uiWillUpdate:self.item2Edit];
             } onFailure:^(NSError *error) {
                 [self showAlert:@"Please try later" withTitle:@"Sorry"];
                 sender.enabled = YES;
             }];
}

//touch to show who follow this entity
- (void) showFollowers:(id) sender
{
    SSFollowVC *followVC = [[SSFollowVC alloc]init];
    followVC.item = self.item2Edit;
    followVC.showFollowers = YES;
    [self showPopup:followVC sender:sender];
}

//touch to show who this user follow, only applicable to user for now
- (void) showFollowing:(id) sender
{
    SSFollowVC *followVC = [[SSFollowVC alloc]init];
    followVC.item = self.item2Edit;
    followVC.showFollowers = NO;
    [self showPopup:followVC sender:sender];
}

//if current user follow this item or not
- (void) doIFollowThisOnCallback:(OnCallback) callback;
{
    if (![self.item2Edit objectForKey:REF_ID_NAME])
    {
        return;
    }
    NSArray *filters = @[
                         [SSFilter on:AUTHOR op:EQ value:[self profileId]],
                         [SSFilter on:FOLLOW op:EQ value:[self.item2Edit objectForKey:REF_ID_NAME]]
                         ];
    [self getData:filters ofType:SOCIAL_FOLLOW callback:callback];
}

- (void) getData:(NSArray *) filters
          ofType:(NSString *) objectType
        callback:(OnCallback) callback
{
    SSConnection *conn = [SSConnection connector];
    [conn objectsWithFilters:filters
                      ofType: objectType
                     orderBy:nil
                   ascending:NO
                      offset:0
                       limit:10
                   onSuccess:^(id data) {
                       callback([data objectForKey:PAYLOAD]);
                   } onFailure:^(NSError *error) {
                       callback(nil);
                   }];
}

- (IBAction)comment : (id)sender
{
    [SSSecurityVC checkLogin:self withHint:@"Signin"
                  onLoggedIn:^(id user) {
                      if (user){
                          SSCommentVC *commentEditorVC = [[SSCommentVC alloc]init];
                          commentEditorVC.item2Comment = self.item2Edit;
                          commentEditorVC.objectType = self.itemType;
                          if ([self.navigationController topViewController] != self) {
                              [self.navigationController popViewControllerAnimated:NO];
                          }
                          [self.navigationController pushViewController:commentEditorVC animated:YES];
                      }
                  }];
}

- (SSCommentsVC *) getCommentVC
{
    SSCommentsVC *commentsVC = [[SSCommentsVC alloc]init];
    commentsVC.objects = nil;
    commentsVC.itemCommented = self.item2Edit;
    commentsVC.itemType = self.itemType;
    commentsVC.oneAtATime = YES;
    [self addChildViewController:commentsVC];
    commentsVC.view.frame = CGRectMake(0,0,self.view.frame.size.width, commentsVC.view.frame.size.height);
    commentsVC.layoutManager = layoutTable;
    [commentsVC.predicates removeAllObjects];
    [commentsVC.predicates addObject:[SSFilter on:COMMENTED_ON op:EQ value:[commentsVC.itemCommented objectForKey:REF_ID_NAME]]];

    return commentsVC;
}

@end
