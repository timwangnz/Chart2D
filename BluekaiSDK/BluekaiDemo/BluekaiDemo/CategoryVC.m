//
//  CategoryVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/25/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "CategoryVC.h"

@interface CategoryVC ()
{
    IBOutlet UITableView *tvCategories;
    NSMutableDictionary *categories;
    NSArray *types;
    id dataReceived;
}

@end

@implementation CategoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql = [NSString stringWithFormat:@"select category_id, category_name, profiles, is_leaf from bk_raw_inventory_view where parent_id= %d", self.parentId];
    types = @[@"Public", @"Private"];
    tvCategories.hidden = YES;
    [self getData];
}

- (void) didFinishLoading: (id)data
{
    dataReceived = data;
    NSArray *cats = data[@"data"];
    NSMutableArray * privateCategories = [NSMutableArray array];
    NSMutableArray * publicCategories = [NSMutableArray array];
    categories = [NSMutableDictionary dictionary];
    
    for (id cat in cats)
    {
        if ([cat[@"CATEGORY_NAME"] rangeOfString:@"Private"].location == NSNotFound)
        {
            [publicCategories addObject:cat];
        }
        else
        {
            
            [cat setObject:@"Y" forKey:@"private"];
            [privateCategories addObject:cat];
        }
    }
    
    [categories setValue:privateCategories forKey:types[1]];
    [categories setValue:publicCategories forKey:types[0]];
    tvCategories.hidden = NO;
    [tvCategories reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[categories objectForKey:types[section]] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.parentId == 344 ? [types count] : 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.parentId == 344 ? types[section] : nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;// (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"simpelCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;
    }
    id category = [categories objectForKey:types[indexPath.section]][indexPath.row];
    cell.textLabel.text = category[@"CATEGORY_NAME"];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%ld", [category[@"PROFILES"] longValue]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id category = [categories objectForKey:types[indexPath.section]][indexPath.row];
    if ([category[@"IS_LEAF"] isEqualToString:@"1"]) {
        return;
    }
    CategoryVC *categoryVC = [[CategoryVC alloc]init];
    categoryVC.parentId = [category[@"CATEGORY_ID"] intValue];
    categoryVC.title = category[@"CATEGORY_NAME"];
    
    [self.navigationController pushViewController:categoryVC animated:YES];
}

@end
