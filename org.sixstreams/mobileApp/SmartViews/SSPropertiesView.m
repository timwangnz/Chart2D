//
//  SSPropertiesView.m
//  SixStreams
//
//  Created by Anping Wang on 1/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSPropertiesView.h"
@interface SSPropertiesView ()
{
    NSArray *sortedKeys;
}
@end

@implementation SSPropertiesView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.dataSource = self;
    self.delegate = self;
}


- (void) setData:(id)data
{
    _data = data;
   
    sortedKeys = [[data allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
       return [a compare:b];
    }];
    
    [self reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sortedKeys count];
}

#define LAYOUT_CELL @"propertyCell"
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:LAYOUT_CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:LAYOUT_CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    cell.textLabel.text = [sortedKeys objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [self.data objectForKey:cell.textLabel.text]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //do nothing
}

@end
