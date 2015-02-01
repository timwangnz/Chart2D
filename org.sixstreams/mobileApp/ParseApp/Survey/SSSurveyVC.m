//
//  SSSurveyVC.m
//  SixStreams
//
//  Created by Anping Wang on 7/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSSurveyVC.h"
#import "SSSurveyCell.h"

@interface SSSurveyVC ()
{
    NSMutableArray *sortedFilteredKeys;
    NSMutableArray *selectedItems;
}

@end

@implementation SSSurveyVC

- (void) setItems:(NSDictionary *)items
{
    _items = items;
    [self sortAndFilter];
}

- (void) sortAndFilter
{
    if (self.sectioned)
    {
        sortedFilteredKeys = [NSMutableArray array];
        NSMutableArray *allKeys = [NSMutableArray arrayWithArray:[self.items allKeys]];
        for (id key in allKeys)
        {
            [sortedFilteredKeys addObject:key];
        }
    }
    else
    {
        sortedFilteredKeys = [NSMutableArray array];
        NSMutableArray *allKeys = [NSMutableArray arrayWithArray:[self.items allKeys]];
        
        for (id key in allKeys) {
            [sortedFilteredKeys addObject:key];
        }

    }
    [sortedFilteredKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2];
    }];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.sectioned)
    {
        return sortedFilteredKeys.count;
    }
    else{
        return 1;
    }
}

- (NSArray *) itemAt:(NSIndexPath *)indexPath
{
    if (self.sectioned)
    {
        return self.items[sortedFilteredKeys[indexPath.section]][indexPath.row];
    }
    else
    {
        return sortedFilteredKeys[indexPath.row];;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.sectioned)
    {
        return [self.items[sortedFilteredKeys[section]] count];
    }
    else{
        return sortedFilteredKeys.count;
    }
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL) isSelected:(NSIndexPath *)indexPath
{
    return [selectedItems containsObject:[self itemAt:indexPath]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self itemAt:indexPath];
    
    static NSString *CellIdentifier = @"SSServeyCellId";
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    SSSurveyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SSSurveyCell" owner:self options:nil];
        cell = (SSSurveyCell *)[nib objectAtIndex:0];
        cell.tableview = tableView;
        cell.indentationLevel = 0;
    }
    
    if([self isSelected:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.item = object;
    [cell updateCell:object];
    /*
    cell.textLabel.text = [object capitalizedString];
    
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    */
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"  %@", sortedFilteredKeys[section]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!selectedItems)
    {
        selectedItems = [NSMutableArray array];
    }
    if([self isSelected:indexPath])
    {
        [selectedItems removeObject:[self itemAt:indexPath]];
    }
    else
    {
        [selectedItems addObject:[self itemAt:indexPath]];
    }
    [tableView reloadData];
}

@end
