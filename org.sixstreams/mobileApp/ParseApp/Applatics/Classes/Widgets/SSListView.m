//
// AppliaticsCommonView.m
// Appliatics
//
//  Created by Anping Wang on 3/25/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSListView.h"
#import "SSTableViewVC.h"

@interface SSListView()
{
     IBOutlet UITableView *dataView;
}
@end

@implementation SSListView


- (void) refreshUI
{
    [dataView reloadData];
}

- (NSString *) getCellTitle:(id) item
{
    NSString *title = [item objectForKey:NAME] ? [item objectForKey:NAME] : [item objectForKey:@"firstName"];
    if ([title isEqual:[NSNull null]])
    {
        title = [item objectForKey:REF_ID_NAME];
    }
    return title;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [self deleteObject : [self.objects objectAtIndex:indexPath.row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entities count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [self.entities objectAtIndex:indexPath.row];
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    NSString *title  = [self getCellTitle:object];
    cell.textLabel.text = title == nil ? @"Unknown Object" : title;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.controller doSelect:indexPath.row];
}


@end
