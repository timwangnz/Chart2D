//
//  WCByNBameVC.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/29/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCByNBameVC.h"
#import "WCRoasterDetailsVC.h"
#import "WCRoasterCell.h"
#import "SSFilter.h"

@interface WCByNBameVC ()

@end

@implementation WCByNBameVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Cafe", @"Cafe");
        self.objectType = COMPANY_CLASS;
        self.orderBy = @"name";
        self.ascending = YES;
    }
    return self;
}

- (void) setCity:(NSString *) city
{
    cityToShow = city;
    [self.predicates removeAllObjects];
    if (cityToShow)
    {
        [self.predicates addObject:[SSFilter on:@"city" op:EQ value:cityToShow]];
        [self forceRefresh];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedObject = [self.objects objectAtIndex:indexPath.row];
    WCRoasterDetailsVC *childVC = [[WCRoasterDetailsVC alloc] init];
    
    childVC.item2Edit = selectedObject;
    childVC.itemType = self.objectType;
    
    [self.navigationController pushViewController:childVC animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WCRoasterCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"WCRoasterCellId"];
    if (cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"WCRoasterCell" owner:self options:nil];
        cell = (WCRoasterCell *) [bundle objectAtIndex:0];
    }
    [cell configCell:[self.objects objectAtIndex:indexPath.row]];
    return cell;
}


@end
