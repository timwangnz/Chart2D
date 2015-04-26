//
//  CampaignVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/25/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "CampaignVC.h"

@interface CampaignVC ()
{
    
        IBOutlet UITableView *tvCampaigns;
        NSMutableArray *campaigns;
        
        id dataReceived;
    
}

@end

@implementation CampaignVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql = @"select campaign_id from bk_campaign";
    [self getData];
}

- (void) didFinishLoading: (id)data
{
    dataReceived = data;
    NSArray *cats = data[@"data"];
    campaigns = [NSMutableArray arrayWithArray:cats];
    [tvCampaigns reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [campaigns count];
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
    id category = campaigns[indexPath.row];
    cell.textLabel.text = category[@"CAMPAIGN_ID"];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

@end
