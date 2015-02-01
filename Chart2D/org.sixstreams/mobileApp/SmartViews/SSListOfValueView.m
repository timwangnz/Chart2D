//
//  ListOfValueView.m
// Appliatics
//
//  Created by Anping Wang on 10/8/13.
//  Copyright (c) 2013 Oracle. All rights reserved.
//

#import "SSListOfValueView.h"
@interface SSListOfValueView ()
{
    UITableView *optionsView;
}
@end

@implementation SSListOfValueView

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.options count];
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
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    cell.textLabel.text = [self.options objectAtIndex:indexPath.row];
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.text = [self.options objectAtIndex:indexPath.row];
    [optionsView removeFromSuperview];
    optionsView.hidden = YES;
}

- (void)showLov
{
    if (!optionsView)
    {
        optionsView = [[UITableView alloc]init];
        optionsView.dataSource = self;
        optionsView.delegate = self;
        optionsView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        optionsView.backgroundColor = [UIColor lightGrayColor];
        optionsView.hidden = YES;
    }
    optionsView.hidden = !optionsView.hidden;
    [self.superview addSubview:optionsView];
    optionsView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 200);
    [self.superview bringSubviewToFront:optionsView];
    [optionsView reloadData];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self showLov];
}

@end
