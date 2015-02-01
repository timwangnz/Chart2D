//
//  SSEntityEditorVC.m
//  SixStreams
//
//  Created by Anping Wang on 4/9/13.
//  Copyright (c) 2013 SixStreams. All rights reserved.
//

#import "SSSettingEditorVC.h"
#import "SSSettingAttributeEditorVC.h"
#import "SSConfigManager.h"

@interface SSSettingEditorVC ()<PropertyEditDelegate>
{
}
@end

@implementation SSSettingEditorVC

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.entity || [orderedSections count] == 0)
    {
        return 0;
    }
    return [orderedSections count];
}

- (id) getItem:(int) section row:(int) row
{
    NSString *sectionKey = [orderedSections objectAtIndex:section];
    NSArray *groupedItem = [self.entity objectForKey:sectionKey];
    return [groupedItem objectAtIndex:row];
}


- (void) save
{
    //
}

- (BOOL) isLastSection:(NSIndexPath *)indexPath
{
    return indexPath.section ==  [orderedSections count];
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
    if (section == [orderedSections count])
    {
        return @"";
    }
    
    NSString *sectionName = [orderedSections objectAtIndex:section];
    NSArray *comp = [sectionName componentsSeparatedByString:@"."];
    return [NSString stringWithFormat:@"  %@", [comp count] > 1 ? comp[1] : sectionName];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == [orderedSections count])
    {
        return 1;
    }
    NSString *paramGroup = [orderedSections objectAtIndex:section];
    return [[self.entity objectForKey:paramGroup] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.editable)
    {
        return;
    }
    
    self.selectedSection = [orderedSections objectAtIndex:indexPath.section];
    self.selectedValue = [self getItem:indexPath.section row:indexPath.row];
    BOOL readonly = [[self.selectedValue objectForKey:READ_ONLY] boolValue];
    if(readonly)
    {
        return;
    }
    
    id value = [self.selectedValue objectForKey:@"value"];
    
    NSString *type = [self.selectedValue objectForKey:@"type"];
    if ([type isEqualToString:@"viewController"]) {
        Class vcClass = NSClassFromString(value);
        UIViewController *ui = [[vcClass alloc] init];
        [self.navigationController pushViewController:ui animated:YES];
    }
    else if ([value isKindOfClass:[NSString class]]) {
        SSSettingAttributeEditorVC *editor = [[SSSettingAttributeEditorVC alloc]init];
        editor.propertyEditorDelegate = self;
        editor.view.frame = self.view.frame;
        editor.preferredContentSize = self.preferredContentSize;
        [self.navigationController pushViewController:editor animated:YES];
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
        //TODO
    }
   }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    static NSString *DefaultCellIdentifier = @"defaultCell";
    
    UITableViewCell  *cell = [self isLastSection:indexPath] ? [tableView dequeueReusableCellWithIdentifier: DefaultCellIdentifier] : [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    
    NSDictionary *prop = [self getItem:indexPath.section row:indexPath.row];
    
    id value = [prop objectForKey:@"value"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *type = [prop objectForKey:@"type"];
    cell.textLabel.text = [self getDisplayName:[prop objectForKey:NAME]];
    
    if ([value isKindOfClass:[NSDictionary class]])
    {
        cell.detailTextLabel.text = @"Dictioinary";
    }
    else if([type isEqualToString:@"string"])
    {
        
        if ([@"Y" isEqualToString:[prop objectForKey:@"isSecret"]])
        {
            cell.detailTextLabel.text = @"*****";
        }
        else{
            cell.detailTextLabel.text = [self getDisplayValue:value];
        }
    }
    else
    {
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}


@end
