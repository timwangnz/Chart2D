//
//  CategoryVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/25/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKCategoriesVC.h"
#import "SqlGraphView.h"

@interface BKCategoriesVC ()
{
    NSMutableDictionary *categories;
    NSArray *types;
    BOOL showAll;
    int selectedCategory;
}

@end

@implementation BKCategoriesVC

- (IBAction) closeChartView:(id) sender
{
    selectedCategory = 0;
    [self updateLayout];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    types = @[@"Public", @"Private"];
    if (self.siteId == -1)
    {
        self.sql =
        [NSString stringWithFormat:@"select cat.category_name, inv.INVENTORY, inv.ab_tested,  created_at, cat.category_id, cat.is_leaf from bk_inventory_view inv, bk_category cat where inv.site_id(+)=-1 and cat.parent_id=%d and cat.category_id = inv.category_id(+) and to_char(created_at(+), 'DD-MM-YYYY') = '%@' order by cat.category_name", self.parentId, [self today]];
    }
    else if (self.parentId == 344)
    {
        NSString *sqlFmt = @"select cat.parent_id, cat.depth, cat.category_name, inv.inventory, inv.ab_tested, created_at, cat.category_id, cat.is_leaf from bk_inventory_view inv, bk_category cat where inv.site_id = %d and cat.category_id(+) = inv.category_id and to_char(created_at(+), 'DD-MM-YYYY') = '%@' and cat.depth in (select min(cat.depth) from bk_inventory_view inv, bk_category cat where inv.site_id = %d and cat.category_id(+) = inv.category_id and to_char(created_at(+), 'DD-MM-YYYY') = '%@') order by cat.category_name";
        self.sql  = [NSString stringWithFormat:sqlFmt, self.siteId, [self today], self.siteId, [self today]];
    }
    else
    {
        self.sql =
        [NSString stringWithFormat:@"select cat.category_name, inv.inventory, inv.ab_tested, created_at, cat.category_id, cat.is_leaf from bk_inventory_view inv, bk_category cat where inv.site_id=%d and cat.parent_id=%d and cat.category_id = inv.category_id(+) and to_char(created_at(+), 'DD-MM-YYYY') = '%@' order by cat.category_name", self.siteId, self.parentId, [self today]];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Show All" style:UIBarButtonItemStyleDone target:self action:@selector(actionDetails)];
    tableview.hidden = YES;
    self.titleField = @"CATEGORY_NAME";
    self.cacheTTL = 3600*24;
    [self getData];
}

-(void) showTrend:(int) categoryId
{
  
    trend.sql = [NSString stringWithFormat:
                     @"select to_char(created_at, 'MM/DD') CREATED_AT, AB_TESTED, INVENTORY from bk_inventory_view where category_id = %d and site_id = %d and sysdate - created_at < 30 order by created_at", categoryId, self.siteId];
    

    selectedCategory = categoryId;
    trend.limit = 30;
    trend.title = @"Inventory";
    trend.valueFields[0] = @"INVENTORY";
    trend.valueFields[1] = @"AB_TESTED";
    trend.xLabelField = @"CREATED_AT";
    trend.topMargin = 20;
    trend.bottomMargin = 40;
    trend.leftMargin = 60;
    trend.topPadding = 0;
    trend.legendType = Graph2DLegendNone;
    trend.yMin = 0;
    trend.autoScaleMode = Graph2DAutoScaleMax;
    trend.xAxisStyle.tickStyle.majorTicks = 8;
        trend.yAxisStyle.tickStyle.majorTicks = 6;
    trend.displayNames =@{@"INVENTORY":@"Tagged in 30 Days", @"AB_TESTED":@"AB Tested 30 Days"};
    trend.legendType = Graph2DLegendTop;
    showAll = NO;
    trend.cacheTTL = 3600;
    self.titleField = @"CATEGORY_NAME";
    if (categoryId == 344)
    {
        trend.hidden = YES;
    }
    else{
        [trend reload];
        [self updateLayout];
    }
}

- (void) actionDetails
{
    showAll = !showAll;
    [self updateModel];
    self.navigationItem.rightBarButtonItem.title = showAll ? @"Hide":@"Show All";
}

- (void) updateModel
{
    if([filteredObjects count] == 0)
    {
        return;
    }
    
    NSMutableArray * privateCategories = [NSMutableArray array];
    NSMutableArray * publicCategories = [NSMutableArray array];
    categories = [NSMutableDictionary dictionary];
    for (id cat in filteredObjects)
    {
        if ([cat[@"INVENTORY"] intValue] > 0 || showAll)
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
    }
    [categories setValue:privateCategories forKey:types[1]];
    [categories setValue:publicCategories forKey:types[0]];
    tableview.hidden = NO;
    [tableview reloadData];
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
    id category = [categories objectForKey:types[indexPath.section]][indexPath.row];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"simpelCell"];
        
        cell.indentationLevel = 0;
    }
  
    cell.accessoryType = [category[@"IS_LEAF"] isEqualToString:@"1"] ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", category[@"CATEGORY_NAME"], category[@"CATEGORY_ID"] ];
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    cell.detailTextLabel.text = [formatter stringFromNumber: category[@"INVENTORY"]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.textColor =  [UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id category = [categories objectForKey:types[indexPath.section]][indexPath.row];
    int categoryId = [category[@"CATEGORY_ID"] intValue];
    if (categoryId == selectedCategory)
    {
        if ([category[@"IS_LEAF"] isEqualToString:@"1"]) {
            return;
        }
        BKCategoriesVC *categoryVC = [[BKCategoriesVC alloc]init];
        categoryVC.parentId = [category[@"CATEGORY_ID"] intValue];
        categoryVC.title = category[@"CATEGORY_NAME"];
        categoryVC.siteId = self.siteId;
        [self.navigationController pushViewController:categoryVC animated:YES];
    }
    else{
        [self showTrend:categoryId];
        selectedCategory = categoryId;
    }
}


- (void) updateLayout
{
    [UIView animateWithDuration:0.4 animations:^{
        [self _updateLayout];
    }];
}

- (void) _updateLayout
{
    int header = 0;
    int height = self.view.bounds.size.height / 3;
    if (!selectedCategory) {
        height = 0;
    }
    trend.frame = CGRectMake(trend.frame.origin.x, self.view.bounds.size.height - height, trend.frame.size.width, height);
    
    if (selectedCategory == 344) {
        tableview.frame = CGRectMake(tableview.frame.origin.x, header, tableview.frame.size.width, self.view.bounds.size.height - header);
    }
    else{
        tableview.frame = CGRectMake(tableview.frame.origin.x, header, tableview.frame.size.width, self.view.bounds.size.height - trend.frame.size.height - header);
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selectedCategory = 0;
    [self _updateLayout];
    
}

@end
