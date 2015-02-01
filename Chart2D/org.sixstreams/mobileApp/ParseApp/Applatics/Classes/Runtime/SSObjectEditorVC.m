//
// AppliaticsObjectEditorVC.m
// Appliatics
//
//  Created by Anping Wang on 10/2/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//
#import <MapKit/MapKit.h>

#import "SSObjectEditorVC.h"
#import "SSConnection.h"
#import "SSAddressField.h"
#import "SSDateTextField.h"
#import "SSValueField.h"
#import "SSReferenceTextField.h"
#import "SSRoundView.h"
#import "SSOptionsEditor.h"
#import "SSCheckBox.h"
#import "SSRoundTextView.h"
#import "SSBooleanEditor.h"
#import "SSLovTextField.h"

@interface SSObjectEditorVC ()<SSEntityEditorDelegate, UITableViewDelegate, UITextFieldDelegate>
{
    IBOutlet SSRoundView *footerView;
    IBOutlet UIView *headerView;
    NSMutableDictionary *fieldEditors;
    IBOutlet UITableView *dataView;
    BOOL creation;
    float centerStart;
}

@property (nonatomic, strong) NSMutableArray *fields;
@property (nonatomic, strong) id viewDef;

- (IBAction)handlePanning: (UIPanGestureRecognizer *)recognizer;
- (IBAction)cancel;

@end

@implementation SSObjectEditorVC

+ (SSObjectEditorVC *) objectType:(id) viewDef
{
    SSObjectEditorVC *appEditor = [[SSObjectEditorVC alloc]init];
    appEditor.viewDef = viewDef;
    [appEditor initUI];
    return appEditor;
}

- (void) cancel
{
    if (self.isIPad)
    {
        [self hideKeyboard];
        [self hide];
    }
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) updateEntity:(id) entity OfType:(NSString *) entityType
{
    [super updateEntity:entity OfType:entityType];
    [self uiWillUpdate:self.item2Edit];
}

- (IBAction)handlePanning: (UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        centerStart = self.view.center.x;
    }
    
    if(!self.isIPad)
    {
        if(recognizer.state == UIGestureRecognizerStateEnded)
        {
            CGPoint translation = [recognizer translationInView:self.view];
            float newCenter = self.view.center.x + translation.x;
            if (newCenter > centerStart)
            {
                [self cancel];
                centerStart = self.view.center.x;
            }
        }
        return;
    }
    if(self.objectDelegate && [self.objectDelegate respondsToSelector:@selector(objectEditor:shouldHide:)])
    {
        if(![self.objectDelegate objectEditor:self shouldHide:self.item2Edit])
        {
            return;
        }
    }
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint translation = [recognizer translationInView:self.view];
        float newCenter = self.view.center.x + translation.x;
        if (newCenter > centerStart)
        {
            [self hideKeyboard];
            [self hide];
            centerStart = self.view.center.x;
        }
    }
    else
    {
        CGPoint translation = [recognizer translationInView:self.view];
        float newCenter = self.view.center.x + translation.x;
        if (newCenter > centerStart)
        {
            self.view.center = CGPointMake(self.view.center.x + translation.x, self.view.center.y);
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        }
        if(self.objectDelegate && [self.objectDelegate respondsToSelector:@selector(objectEditor:panning:)])
        {
            [self.objectDelegate objectEditor:self panning:self.item2Edit];
        }
    }
}

- (IBAction) hide
{
    if (!(self.isIPad && creation))//ipad and new will not slid
    {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.view.frame = CGRectMake(
                                                          self.view.frame.origin.x + self.view.frame.size.width,
                                                          self.view.frame.origin.y,
                                                          self.view.frame.size.width,
                                                          self.view.frame.size.height
                                                          );
                         }
                         completion:^(BOOL finished) {
                             if(finished)
                             {
                                 self.view.hidden = YES;
                                 if(self.objectDelegate && [self.objectDelegate respondsToSelector:@selector(objectEditor:didHide:)])
                                 {
                                     [self.objectDelegate objectEditor:self didHide:self.item2Edit];
                                 }
                             }
                         }
         
         ];
    }
}

//Override
- (void) entityDidSave:(id)object
{
    [self cancel];
}


- (UIView *) createFieldEditor: (int) row
{
    return [self getAttrEditor:[self.fields objectAtIndex:row]];
}

#define EDITOR_WIDTH 260

- (UIView*) getAttrEditor:(id) item
{
    int dataType = [[item objectForKey:DATA_TYPE] intValue];
    NSString *attrName = [item objectForKey:BINDING];
    NSString *uiType = [item objectForKey:@"uiType"];
    NSString *metaType = [item objectForKey:META_TYPE];
    attrName = attrName ? attrName : @"undefined";
    UIView *attrEditorView;
    int yOffset = 0;
    int height = 30;
    
    if ([uiType isEqualToString:@"TextView"])
    {
        SSRoundTextView *textView = [[SSRoundTextView alloc]initWithFrame:CGRectMake(0, yOffset, EDITOR_WIDTH, 120)];
        textView.attrName = attrName;
    }
    else if ([metaType isEqualToString:CATEGORY])
    {
        NSString *options = [item objectForKey:META_DATA];
        if (options)
        {
            NSArray *optionArray = [options componentsSeparatedByString:@","];
            SSOptionsEditor *sgCtrl = [[SSOptionsEditor alloc] initWithItems : optionArray];
            sgCtrl.tintColor = [UIColor blueColor];
            sgCtrl.attrName = attrName;
            sgCtrl.valueType = @"string";
            attrEditorView = sgCtrl;
        }
        else
        {
            SSLovTextField *text = [[SSLovTextField alloc]initWithFrame:CGRectMake(0, yOffset, EDITOR_WIDTH, height)];
            text.valueType = @"lov";
            text.attrName = attrName;
            text.delegate = self;
            attrEditorView = text;
        }
    }
    else if ([metaType isEqualToString:@"reference"])
    {
        SSLovTextField *text = [[SSLovTextField alloc]initWithFrame:CGRectMake(0, yOffset, EDITOR_WIDTH, height)];
        text.attrName = attrName;
        text.valueType = @"string";
        text.delegate = self;
        text.entityType = [item objectForKey:META_DATA];
        text.titleKey = @"name";
        attrEditorView = text;
    }
    else if ([metaType isEqualToString:ADDRESS])
    {
        SSAddressField *text = [[SSAddressField alloc]initWithFrame:CGRectMake(0, yOffset, EDITOR_WIDTH, height)];
        text.delegate = self;
        text.valueType = @"dictionary";
        text.attrName = attrName;
        attrEditorView = text;
    }else if (dataType == 3)
    {
        attrEditorView = [[SSCheckBox alloc]initWithFrame:CGRectMake(0, yOffset, height, height)];
    }
    else if (dataType == 0)//Text
    {
        SSValueField *text = [[SSValueField alloc]initWithFrame:CGRectMake(0, yOffset, EDITOR_WIDTH, height)];
        text.metaType = metaType;
        text.valueType = @"string";
        
        text.delegate = self;
        text.attrName = attrName;
        attrEditorView = text;
    }
    else if (dataType == 1)//Number
    {
        SSValueField *text = [[SSValueField alloc]initWithFrame:CGRectMake(0, 10, EDITOR_WIDTH, height)];
        text.valueType = @"number";
        text.attrName = attrName;
        attrEditorView = text;
    }
    else if (dataType == 2)//Date
    {
        SSDateTextField *text = [[SSDateTextField alloc]initWithFrame:CGRectMake(0, yOffset, EDITOR_WIDTH, height)];
        text.mode = UIDatePickerModeDate;
        text.valueType = @"date";
        text.attrName = attrName;
        attrEditorView = text;
    }
    else if (dataType == 4)//DateTime
    {
        SSDateTextField *text = [[SSDateTextField alloc]initWithFrame:CGRectMake(0, yOffset, EDITOR_WIDTH, height)];
        text.mode = UIDatePickerModeDateAndTime;
        text.valueType = @"datetime";
        text.attrName = attrName;
        attrEditorView = text;
    }
    else if (dataType == 5)//Time
    {
        SSDateTextField *text = [[SSDateTextField alloc]initWithFrame:CGRectMake(0, yOffset, EDITOR_WIDTH, height)];
        text.mode = UIDatePickerModeTime;
        text.valueType = @"time";
        text.attrName = attrName;
        attrEditorView = text;
    }
    
    if (!fieldEditors)
    {
        fieldEditors = [NSMutableDictionary dictionary];
    }
    
    [fieldEditors setObject:attrEditorView forKey:attrName];

    return attrEditorView;
}

#define DEFAULT_LABEL_WIDTH 100
#define DEFAULT_MARGIN 10

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    for (UIView *child in [cell.contentView subviews])
    {
        [child removeFromSuperview];
    }
    
    cell.textLabel.text = @"";

    float x = 0;
    for(NSInteger i = 0; i < 2; i++)
    {
        UIView *cellFrame = [self tableViewCell:cell itemAtRow:indexPath.row col: i];
        [cell.contentView addSubview: cellFrame];
        
        int cellHeight = cellFrame.frame.size.height;
        int y = (cell.contentView.frame.size.height - cellFrame.frame.size.height)/ 2;
        
        float width = [self tableView:tableView widthForColumn:i];
        
        if ([cellFrame isKindOfClass:[SSCheckBox class]]) {
            width = 30;
        }
        
        cellFrame.frame = CGRectMake(x, y, width, cellHeight);
        x += (width + DEFAULT_MARGIN);
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView widthForColumn:(NSInteger) col
{
    return col == 0 ? DEFAULT_LABEL_WIDTH : tableView.frame.size.width - DEFAULT_LABEL_WIDTH - 2*DEFAULT_MARGIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fields count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item  = [self.fields objectAtIndex:indexPath.row];
    NSString *name = [item objectForKey:BINDING];
    UIView *uiView = [fieldEditors objectForKey:name];
    CGFloat height = uiView.frame.size.height + 4;
    return height;
}

- (UIView *) tableViewCell:(UITableViewCell *) cell itemAtRow:(NSInteger) row col:(NSInteger) col
{
    if (col == 1)
    {
        NSString *attrName = [[self.fields objectAtIndex:row] objectForKey:BINDING];
        return [fieldEditors objectForKey:attrName];
    }
    
    UILabel *cellView = [[UILabel alloc]init];
    id item  = [self.fields objectAtIndex:row];
    cellView.text = [item objectForKey: BINDING];
    cellView.text = [cellView.text fromCamelCase];
    cellView.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    cellView.font = [UIFont systemFontOfSize:12];
    cellView.textAlignment = NSTextAlignmentRight;

    cellView.frame = CGRectMake(0, 3, DEFAULT_LABEL_WIDTH, cell.frame.size.height - 6);
    return cellView;
}

- (void) initUI
{
    self.itemType = [self.viewDef objectForKey:SS_OBJECT_TYPE];
    if (!self.itemType)
    {
        DebugLog(@"%@", self.viewDef);
        return;
    }
    self.title = [self.viewDef objectForKey:NAME];
    self.fields = [NSMutableArray arrayWithArray:[self.viewDef objectForKey:COLUMN_DEFS]];
    NSMutableArray *readonlyItems = [NSMutableArray array];
    
    for (id field in self.fields)
    {
        BOOL isReadonly = [[field objectForKey:READ_ONLY] boolValue];
        if (isReadonly)
        {
            [readonlyItems addObject:field];
        }
    }
    
    for (id field in readonlyItems) {
        [self.fields removeObject:field];
    }
    
    for(int i = 0; i < [self.fields count]; i++)
    {
        [self createFieldEditor:i];
    }
}

- (void) save
{
    [super saveOnSuccess:^(id data) {
        if ([data isKindOfClass:NSError.class])
        {
            [self showAlert:@"Failed to save data, try later please" withTitle:@"Server Error"];
        }
        else
        if(self.objectDelegate && [self.objectDelegate respondsToSelector:@selector(objectEditor:didSave:)])
        {
            [self.objectDelegate objectEditor:self didSave:data];
        }
    }];
}

- (void) linkEditFields
{
    for (UIView *editor in [fieldEditors allValues]) {
        [self linkEditField:editor];
        [self updateEditorView:editor];
    }
}

- (void) entityWillSave:(id) entity
{
    [entity setValue:[self.viewDef objectForKey:REF_ID_NAME] forKey:CONTEXT];
}

- (void) uiWillUpdate:(id) entity
{
    creation = YES;
    [self.navigationController setNavigationBarHidden:NO];
    if (entity && [entity count] > 0)
    {
        creation = NO;
    }
    else{
        creation = YES;
    }
    self.readonly = NO;
    [layoutTable removeChildViews];
    [layoutTable addChildView:dataView];
    [layoutTable addChildView:footerView];
    [self linkEditFields];
    [layoutTable reloadData];
    [dataView reloadData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

}
//only do it once
- (void) viewDidLoad
{
    [super viewDidLoad];
    if (!self.isIPad && [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        CGRect frame = headerView.frame;
        CGFloat topBarOffset = 20;
        
        // snaps the view under the status bar (iOS 6 style)
        frame.origin.y = topBarOffset;
        headerView.frame = frame;
        
        frame = layoutTable.frame;
        
        // shrink the bounds of your view to compensate for the offset
        frame.size.height = frame.size.height - (topBarOffset);
        frame.origin.y = frame.origin.y + (topBarOffset);
        layoutTable.frame = frame;
    }
}
/*
- (void) viewDidLayoutSubviews{
    
    // only works for iOS 7+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        
        // snaps the view under the status bar (iOS 6 style)
        viewBounds.origin.y = topBarOffset * -1;
        
        // shrink the bounds of your view to compensate for the offset
        viewBounds.size.height = viewBounds.size.height + (topBarOffset * -1);
        self.view.bounds = viewBounds;
    }
}
*/
@end
