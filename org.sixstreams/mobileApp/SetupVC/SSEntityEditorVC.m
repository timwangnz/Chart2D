//
//  SSEntityEditorVC.m
//  SixStreams
//
//  Created by Anping Wang on 4/9/13.
//  Copyright (c) 2013 SixStreams. All rights reserved.
//

#import "SSEntityEditorVC.h"
#import "SSEntityAttributeEditorVC.h"

@interface SSEntityEditorVC ()<PropertyEditDelegate>
{
    
}
@end

@implementation SSEntityEditorVC

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.entity || [[self.entity allKeys] count] == 0)
    {
        return 0;
    }
    return [[self.entity allKeys] count] + 1;
}

- (id) getItem:(int) section row:(int) row
{
    NSString *sectionKey = [[self.entity allKeys] objectAtIndex:section];
    NSArray *groupedItem = [self.entity objectForKey:sectionKey];
    return [groupedItem objectAtIndex:row];
}

- (void) save
{
    //
}

- (BOOL) isLastSection:(NSIndexPath *)indexPath
{
    return indexPath.section ==  [[self.entity allKeys] count];
}

- (NSString *) getDisplayName:(NSString *) attrName
{
    return attrName;
}

- (NSString *) getDisplayValue:(id) value
{
    return [value description];
}

- (void) setAttrValue:(id)value forAttr:(NSString *)attrName
{
    NSMutableDictionary *sectionItem = [self.entity objectForKey:self.selectedSection];
    [sectionItem setValue: value forKey:attrName];
}

- (id) valueToEdit
{
    return self.selectedValue;
}

- (void) valueDidChange : (id) sender
{
    NSString *key = [self.selectedValue objectForKey:@"name"];
    [self setAttrValue:sender forAttr:key];
    [self.navigationController popViewControllerAnimated:YES];
    [attrTableView reloadData];
}

- (BOOL) shouldValueChange :(id) sender
{
    return YES;
}

- (void) actionCancelled :(id) sneder
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == [[self.entity allKeys] count])
    {
        return @"";
    }
    return [[self.entity allKeys] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == [[self.entity allKeys] count])
    {
        return 1;
    }
    NSString *paramGroup = [[self.entity allKeys] objectAtIndex:section];
    return [[self.entity objectForKey:paramGroup] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.editable)
    {
        return;
    }
    
    if ([self isLastSection:indexPath])
    {
        [tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionBottom];
        [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        [self save];
        return;
    }
    
    self.selectedSection = [[self.entity allKeys] objectAtIndex:indexPath.section];
    self.selectedValue = [self getItem:indexPath.section row:indexPath.row];
    
    SSEntityAttributeEditorVC *editor = [[SSEntityAttributeEditorVC alloc]init];
    editor.propertyEditorDelegate = self;
    editor.view.frame = self.view.frame;
    editor.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
    [self.navigationController pushViewController:editor animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    static NSString *DefaultCellIdentifier = @"defaultCell";
    UITableViewCell  *cell = [self isLastSection:indexPath] ? [tableView dequeueReusableCellWithIdentifier: DefaultCellIdentifier] : [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    if (cell == nil)
    {
        if ([self isLastSection:indexPath])
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier: DefaultCellIdentifier];
        }
        else
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    if ([self isLastSection:indexPath])
    {
        cell.textLabel.text = self.editable ? @"Save" : @"";
        cell.detailTextLabel.text = @"";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
    
    NSDictionary *prop = [self getItem:indexPath.section row:indexPath.row];
    
    id value = [prop objectForKey:@"value"];
    
    if ([value isKindOfClass:[NSDictionary class]])
    {
        cell.textLabel.text = [prop objectForKey:@"name"];
        cell.detailTextLabel.text = @"Dictioinary";
    }
    else
    {
        cell.textLabel.text = [self getDisplayName:[prop objectForKey:@"displayName"]];
        cell.detailTextLabel.text = [self getDisplayValue:value];
    }
    return cell;
}


@end
