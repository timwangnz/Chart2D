//
//  WCByCityVC.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/29/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCByCityVC.h"
#import "SSFilter.h"

#import "WCByNBameVC.h"

@interface WCByCityVC ()

@end

@implementation WCByCityVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"City", @"City");
        self.tabBarItem.image = [UIImage imageNamed:@"06-magnify"];
        self.objectType = @"com.sixstreams.mappuccino.City";
        self.orderBy = @"city";
        self.ascending = YES;
        self.limit = 200;
    }
    return self;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id selectedCity = [self.objects objectAtIndex:indexPath.row];
    WCByNBameVC *childVC = [[WCByNBameVC alloc] init];
    childVC.city = [selectedCity objectForKey:CITY];
    [self.navigationController pushViewController:childVC animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"SavedSearchCellId"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]init];
    }
    
    cell.textLabel.text = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"city"];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    return cell;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}



@end
