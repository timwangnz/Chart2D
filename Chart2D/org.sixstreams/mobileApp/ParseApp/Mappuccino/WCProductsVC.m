//
//  WCProductsVC.m
//  Mappuccino
//
//  Created by Anping Wang on 10/28/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCProductsVC.h"
#import "WCProductListVC.h"

@interface WCProductsVC ()

@end

@implementation WCProductsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) addProduct:(id) sender
{
    WCProductListVC *viewController3 = [[WCProductListVC alloc] initWithNibName:@"WCProductListVC" bundle:nil];
    [self.navigationController pushViewController:viewController3 animated:YES];
    viewController3.title = @"Product List";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProduct:)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"SavedSearchCellId"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]init];
    }
    
    cell.textLabel.text = [products objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    return cell;
}


@end
