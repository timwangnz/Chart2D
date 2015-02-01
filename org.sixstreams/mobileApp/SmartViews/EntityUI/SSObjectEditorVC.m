//
//  CoreEntityVC.m
//  CoreCrm
//
//  Created by Anping Wang on 11/6/12.
//  Copyright (c) 2012 Anping Wang. All rights reserved.
//

#import "SSObjectEditorVC.h"

#import "SSAttrCell.h"

#import "SSLovVC.h"
#import "SSGeoCodeUtil.h"
#import "ObjectTypeUtil.h"
#import "RoundButton.h"
#import "SSMapMarker.h"

@interface SSObjectEditorVC ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *attrDefGroups;
    
    
    //IBOutlet UITableViewCell *tvcAttrCell;
    //attribute being edited
    NSIndexPath *selectedAttributeIndex;
    //text fields
    UITextField *currentEditor;
    //if it is create or edit
    int action;
    //flag to control scroll behavior in terms of
    //keyboard
    BOOL skipResignFirstResponder;
    
    
    //for a list of string, done button will add a new attribute
    //automatically
    SSAttrDef *added;
    
    SSAttrCell *cellAdded;
    
    //flag to indicate if changes have been made to the entity
    BOOL hasChanged;
}

//seeded action that UI can bound
-(IBAction)deleteItem : (id)sender;

@end

@implementation SSObjectEditorVC

#define SECTION_HEIGHT 32

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self delete];
    }
}

-(IBAction)deleteItem : (id)sender
{
    if (self.entity)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete"
                                                       message:@"Are you sure?" delegate:self
                                             cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void) addAddressGroup: (id) item
{
    SSAttrDefGroup *addressGroup = [self addAttrGroup:@"address" ofType:self.objectType forObject:item];
    addressGroup.isAddress = YES;
    [addressGroup addAttrDef:@"street1" ofType:SSStringType];
    [addressGroup addAttrDef:@"city" ofType:SSStringType];
    SSAttrDef *stateAttr = [addressGroup addAttrDef:@"state" ofType:SSStringType];
    stateAttr.lov = [ObjectTypeUtil listOfValues:@"state" ofType:self.objectType];
    [addressGroup addAttrDef:@"postalCode" ofType:SSStringType];
}

- (void) assignAttrValues
{
    for (SSAttrDefGroup *group in  attrDefGroups)
    {
        if (!group.hideHeader)
        {
            if (group.isList)
            {
               NSMutableArray *values = [NSMutableArray array];
               [self.entity setValue:values forKey:group.name];
            }
            
            for (SSAttrDef *attr in group.attrDefs)
            {
                id value = attr.value ? attr.value : attr.defaultValue;
                if (group.isList && value)
                {
                    [[self.entity objectForKey:group.name] addObject:value];
                }
                else
                {
                    [self.entity setValue:value forKey:attr.name];
                }
                
            }
        }
    }
    [SSMapMarker updateLocation:self.entity];
}

- (void) edit : (id) item
{
    action = 1;
    self.entity = item;
    if(self.editable)
    {
        SSAttrDefGroup *securityGroup = [self addAttrGroup:@"control" ofType:self.objectType forObject:item];
        [securityGroup addAttrDef:@"visibility" ofType:SSBooleanType];
        
        SSAttrDefGroup *actionGroup = [self addAttrGroup:@"action" ofType:self.objectType forObject:item];
        actionGroup.hideHeader = YES;
        [actionGroup addAttrDef:@"Save" ofType:SSActionType].onAction = ^(id attrDef)
        {
            if (currentEditor)
            {
                [currentEditor resignFirstResponder];
            }
            
            [self save];
            [self.navigationController popViewControllerAnimated:YES];
        };
        if ([item count]> 0) {
            self.title = @"Edit";
        }
    }
    [attrTableView reloadData];
}

- (void) create
{
    [self edit: [NSMutableDictionary dictionary]];
    action = 0;
}

-(void)delete
{
    [self delete:self.entity];
}

- (void) save
{
    [self assignAttrValues];
    
    if (action == 1)
    {
        [self update:self.entity ofType:self.objectType];
    }
    else if (action == 0)
    {
        [self create:self.entity ofType:self.objectType];
    }
}

- (void) showLov:(id)lovVC
{
    [self.navigationController pushViewController:lovVC animated:YES];
}

- (void) clearAllGroups
{
    [attrDefGroups removeAllObjects];
}

- (SSAttrDefGroup *) addAttrGroup:(NSString *) name ofType:(NSString *) objectType  forObject:item
{
    if (!attrDefGroups)
    {
        attrDefGroups = [NSMutableArray array];
    }
    SSAttrDefGroup *group = [[SSAttrDefGroup alloc]init];
    group.name = name;
    group.object = item;
    group.objectType = objectType;
    [attrDefGroups addObject:group];
    return group;
}

//this should be set only once
- (BOOL) isGroupEditable:(NSString *) groupName
{
    return YES;
}

- (BOOL) isAttributeEditable:(NSString *) attrName inGroup :(NSString *) groupName
{
    return YES;
}

- (void) addListItem:(id) sender
{
    SSAttrDefGroup *group = (SSAttrDefGroup*) ((RoundButton *)sender).valueObject;
    [self addListItemToGroup:group];
}

- (void) addListItemToGroup:(SSAttrDefGroup *) group
{    
    if (group.isList)
    {
        added = [group addAttrDef:[NSString stringWithFormat:@"%@ %d",group.name, [group.attrDefs count] + 1]
                           ofType: group.itemDataType];
        added.hideLabel = YES;
        
        skipResignFirstResponder = NO;
        
        [UIView animateWithDuration:0.33 animations:^(){
            [attrTableView reloadData];
        }
         completion:^(BOOL finished) {
             [cellAdded becomeFirstResponder];
         }
         
         ];
        
    }
}

- (void) currentAddress:(id) sender
{
    NSDictionary *currentAddress = [[[SSGeoCodeUtil alloc]init] getCurrentAddress];
    if (currentAddress)
    {
        SSAttrDefGroup *group = ((RoundButton *)sender).valueObject;
        
        [group getAttrDef:@"city"].value = [currentAddress objectForKey:@"city"];
        [group getAttrDef:@"postalCode"].value = [currentAddress objectForKey:@"postalCode"];
        [group getAttrDef:@"street1"].value = [currentAddress objectForKey:@"address"];
        [group getAttrDef:@"state"].value = [currentAddress objectForKey:@"state"];
        [group getAttrDef:@"country"].value = [currentAddress objectForKey:@"country"];
        [group getAttrDef:@"latitude"].value = [currentAddress objectForKey:@"latitude"];
        [group getAttrDef:@"longitude"].value = [currentAddress objectForKey:@"longitude"];
         hasChanged = YES;
        [attrTableView reloadData];
    }
}

#pragma SSAttrCell
- (BOOL) editor:(UITextField *)editor shouldFinishEdit:(id)object
{
    SSAttrDefGroup *group = [attrDefGroups objectAtIndex:selectedAttributeIndex.section];
    if(group.isList)
    {
        if ([object isEqual: [group.attrDefs lastObject]])
        {
            [self addListItemToGroup:group];
        }
        return YES;
    }
    return YES;
}

- (void) editor:(UITextField *) editor beginToEdit: (id) object;
{
    
    int sect = 0;
    int row = 0;
    currentEditor = editor;
    for (SSAttrDefGroup *group in attrDefGroups)
    {
        row = 0;
        for(id attrValue in group.attrDefs)
        {
            if (attrValue == object)
            {
                selectedAttributeIndex = [NSIndexPath indexPathForRow:row inSection:sect];
            }
            row ++;
        }
        sect ++;
    }
    if (!skipResignFirstResponder)
    {
        attrTableView.contentInset =  UIEdgeInsetsMake(0, 0, 400, 0);
        skipResignFirstResponder = YES;
        int row2scrolledto = selectedAttributeIndex.row - 3 ;
        if (row2scrolledto < 0)
        {
            row2scrolledto = 0;
        }
        [attrTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row2scrolledto inSection:selectedAttributeIndex.section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void) editor:(UITextField *) editor readyToEdit: (id) object;
{
    //skipResign = NO;
}

- (void) editor:(UITextField *) editor finishedToEdit: (id) object
{
    hasChanged = YES;
}
- (void) viewWillDisappear:(BOOL)animated
{
    if (hasChanged)
    {
        [self assignAttrValues];
    }
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [attrTableView reloadData];
}

#pragma UITableView
//resign first responder if user drag the table
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    skipResignFirstResponder = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!skipResignFirstResponder)
    {
        attrTableView.contentInset =  UIEdgeInsetsZero;
        [currentEditor resignFirstResponder];
    }
}

// a row can be deleted if it is a list
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
   SSAttrDefGroup *group = [attrDefGroups objectAtIndex:indexPath.section];
   return group.isList;
}
//
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        SSAttrDefGroup *group = [attrDefGroups objectAtIndex:indexPath.section];
        [group.attrDefs removeObjectAtIndex:indexPath.row];
        skipResignFirstResponder = NO;
        [attrTableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [attrDefGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SSAttrDefGroup *group = [attrDefGroups objectAtIndex:section];
    return [group.attrDefs count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSAttrCell *cell = nil;
    
    static NSString *searchCellIdentifier = @"SSAttrCellId";
    cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    
    //if (cell == nil)
    {
        NSArray *cells = [[NSBundle mainBundle] loadNibNamed:@"SSAttrCell" owner:self options:nil];
        cell = [cells objectAtIndex:0];
    }
    
    SSAttrDefGroup *group = [attrDefGroups objectAtIndex:indexPath.section];
    SSAttrDef *attr = [group.attrDefs objectAtIndex:indexPath.row];
    
    cell.userInteractionEnabled = [self isGroupEditable:group.name] && [self isAttributeEditable:attr.name inGroup:group.name];
    
    if (attr.dataType == SSActionType)
    {
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        attr.hideLabel = YES;
    }
    
    [cell updateCellUI: attr object: self.entity];
    cell.delegate = self;

    if ([attr isEqual:added])
    {
        cellAdded = cell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    SSAttrDefGroup *group = [attrDefGroups objectAtIndex:section];
    if (group.hideHeader)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    SSAttrDefGroup *group = [attrDefGroups objectAtIndex:section];
    
    if (group.hideHeader)
    {
        return 1;
    }
    else
    {
        return SECTION_HEIGHT;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int width = attrTableView.frame.size.width;
    SSAttrDefGroup *group = [attrDefGroups objectAtIndex:section];
    
    if (group.hideHeader)
    {
        return [[UIView alloc] initWithFrame:CGRectMake(10, 0, width-20, 1)];
    }
    
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, width - 20, group ? SECTION_HEIGHT : 1)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    
    headerLabel.font = [UIFont boldSystemFontOfSize:17];
    headerLabel.frame = CGRectMake(10, (SECTION_HEIGHT - 20) / 2, width - 20, group ? 20 : 1);
    headerLabel.text = [group displayName];
    headerLabel.textColor = [UIColor darkGrayColor];
    [customView addSubview:headerLabel];
    customView.backgroundColor = [UIColor lightGrayColor];
    //add address
    if (group.isAddress && [self isGroupEditable:group.name])
    {
        RoundButton *button = [RoundButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(currentAddress:)
         forControlEvents:UIControlEventTouchDown
         ];
        button.valueObject = group;
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"74-location"] forState:UIControlStateNormal];
        button.frame = CGRectMake(width-40, (SECTION_HEIGHT - 20) / 2, 32.0, 20.0);
        [customView addSubview:button];
    }
    //add child attr
    if (group.isList && [self isGroupEditable:group.name])
    {
        RoundButton *button = [RoundButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(addListItem:)
         forControlEvents:UIControlEventTouchDown
         ];
        button.valueObject = group;
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"10-medical"] forState:UIControlStateNormal];
        button.frame = CGRectMake(width-40, (SECTION_HEIGHT - 20) / 2, 32.0, 20.0);
        [customView addSubview:button];
    }
    customView.alpha = 0.8;
    return customView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SSAttrDefGroup *group = [attrDefGroups objectAtIndex:section];
    return group.name;
}

#pragma CoreAttrCellDelegate
- (void) actionPerformed:(SSAttrDef *)sender
{
    if(sender.onAction)
    {
        sender.onAction(sender);
    }
}

@end
