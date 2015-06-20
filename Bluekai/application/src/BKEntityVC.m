//
//  BKEntityVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/24/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKEntityVC.h"

@interface BKEntityVC ()

@end

@implementation BKEntityVC

- (void) processServerData: (id)data
{
    dataReceived = data;
    NSArray *cats = data[@"data"];
    if ([cats count] == 0)
    {
        return;
    }
    entity = cats[0];
    objects = [NSMutableArray array];
    for (id key in [entity allKeys]) {
        [objects addObject: key];
    }
    filteredObjects = [NSMutableArray  arrayWithArray:objects];
    [self updateModel];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sections allKeys][section];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionName = [sections allKeys][section];
    return [sections[sectionName] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return  [sections count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;// (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"simpelCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;
    }
    
    //NSString *key = filteredObjects[indexPath.row];
    NSString *sectionName = [sections allKeys][indexPath.section];
    
    id key = sections[sectionName][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:17];
    cell.detailTextLabel.textColor =  [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1];
    
    cell.textLabel.text = displayNames[key];
    cell.detailTextLabel.text = [self formatValue:[entity objectForKey:key]];
    

    
    return cell;
}


@end
