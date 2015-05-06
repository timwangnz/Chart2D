//
//  ParnterVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/26/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "PartnerVC.h"
#import "PartnerEntityVC.h"

@interface PartnerVC ()
{
    id dataReceived;
    NSArray *data;
    IBOutlet UITableView *tvDataView;
}

@end

@implementation PartnerVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql = @"select * from bk_partner";
    [self getData];
}

- (void) didFinishLoading: (id)received
{
    dataReceived = received;
    NSArray *cats = received[@"data"];
    data = [NSMutableArray arrayWithArray:cats];
    [tvDataView reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return  nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;// (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"simpelCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;
    }
    id row = data[indexPath.row];
    cell.textLabel.text = row[@"PARTNER_NAME"];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PartnerEntityVC *entityVC = [[ PartnerEntityVC alloc]init];
     id row = data[indexPath.row];
    entityVC.partner = row;
    entityVC.title = row[@"PARTNER_NAME"];
    [self.navigationController pushViewController:entityVC animated:YES];
    
}

@end
