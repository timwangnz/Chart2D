//
//  SSShuttleVC.m
//  Applatics
//
//  Created by Anping Wang on 10/13/13.
//  Copyright (c) 2013 Sixstreams. All rights reserved.
//

#import "SSShuttleVC.h"

@interface SSShuttleVC ()<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tvFrom;
    IBOutlet UITableView *tvTo;
    NSIndexPath *fromSelectedPath, *toSelectedPath;
}

@end

@implementation SSShuttleVC

- (void) reloadData
{
    [tvFrom reloadData];
    [tvTo reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tvFrom) {
        return [self.from count];
    }
    else
    {
        return [self.to count];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    id item = nil;
    if (tableView == tvFrom)
    {
        if (fromSelectedPath==nil || ![fromSelectedPath isEqual:indexPath])
        {
            fromSelectedPath = indexPath;
            return;
        }
        fromSelectedPath = indexPath;
        item = [self.from objectAtIndex:indexPath.row];
        [self.from removeObject:item];
        [self.to addObject:item];
        if (self.delegate && [self.delegate respondsToSelector:@selector(shuttleVC:itemAdded:)])
        {
            [self.delegate shuttleVC:self itemAdded:item];
        }
    }
    else{
        if (toSelectedPath==nil || ![toSelectedPath isEqual:indexPath])
        {
            toSelectedPath = indexPath;
            return;
        }
        toSelectedPath = indexPath;
        item = [self.to objectAtIndex:indexPath.row];
        [self.to removeObject:item];
        [self.from addObject:item];
        if (self.delegate && [self.delegate respondsToSelector:@selector(shuttleVC:itemRemoved:)])
        {
            [self.delegate shuttleVC:self itemRemoved:item];
        }
    }
    [tvFrom reloadData];
    [tvTo reloadData];
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    
    cell.textLabel.text = [[tableView == tvFrom ? self.from : self.to objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}

@end
