//
//  SSViewWidardVC.m
//
//  Created by Anping Wang on 7/14/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSViewDefWidardVC.h"
#import "SSColumnEditor.h"
#import "SSTableViewVC.h"
#import "SSReferenceTextField.h"
#import "SSLovTextField.h"
#import "SSApp.h"
#import "SSValueField.h"
#import "SSRoundTextView.h"

@interface SSViewDefWidardVC ()<SSEntityEditorDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tvColumns;
    NSMutableArray *columns;
    id fieldDefs;
}

- (IBAction) editColumns;

@end

@implementation SSViewDefWidardVC

+ (SSViewDefWidardVC *) viewWizard:(id) viewDef for:(id) application
{
    SSViewDefWidardVC *appEditor = [[SSViewDefWidardVC alloc]init];
    [appEditor updateEntity:application OfType:APP_VIEW_SUBSCRIPTION];
    appEditor.application = application;
    appEditor.item2Edit = viewDef;
    return appEditor;
}

- (IBAction) editColumns
{
    SSColumnEditor * entityEditor = [[SSColumnEditor alloc]init];
    entityEditor.viewDef = self.item2Edit;
    if ([columns count] > 0)
    {
        entityEditor.item2Edit = [columns objectAtIndex:0];
    }
    entityEditor.entityEditorDelegate = self;
    [self.navigationController pushViewController:entityEditor animated:YES];
}

//column saved
- (void) entityEditor:(SSEntityEditorVC *)editor didSave:(id)entity
{
    self.valueChanged = YES;
}

- (void) entityDidSave:(id)object
{
    [super entityDidSave:object];
}

- (void) uiWillUpdate:(id) entity
{
    [super uiWillUpdate:entity];
    self.title = [entity count] > 0 ? @"Edit View" : @"Add View";
    columns = [entity objectForKey:COLUMN_DEFS];
    if (!columns)
    {
        columns = [NSMutableArray array];
        [entity setObject:columns forKey:COLUMN_DEFS];
    }
    else
    {
        columns = [NSMutableArray arrayWithArray:columns];
        [entity setObject:columns forKey:COLUMN_DEFS];
    }
    [tvColumns reloadData];
    [self linkEditFields];
}

- (void) handleGesture:(UISwipeGestureRecognizer*) gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    if(!self.isIPad)
    {
        UISwipeGestureRecognizer *panGestureRec = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
        panGestureRec.direction = UISwipeGestureRecognizerDirectionDown;
        [self.view addGestureRecognizer:panGestureRec];
    }
}

#define CELL @"cell"

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
       
    }
    cell.textLabel.text = [[columns objectAtIndex:indexPath.row]objectForKey:NAME];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [columns count];
}

@end
