//
//  CampaignWinsVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/9/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "CampaignWinsVC.h"

@interface CampaignWinsVC ()

@end

@implementation CampaignWinsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.partnerId)
    {
        self.sql = [NSString stringWithFormat:
                    @"select fact.* from bk_campaign_view fact, bk_campaign campaign where campaign.campaign_id = fact.campaign_id and  campaign.partner_id = %ld and to_char(created_at, 'DD-MM-YYYY') = '%@'", (long)self.partnerId, [self today]];
    }
    else
    {
        self.sql = @"select * from bk_campaign_view where created_at between sysdate - 1 and sysdate";
    }
    
    self.titleField = @"CAMPAIGN_ID";
    self.detailField = @"WINS";
    [self getData];
}

- (NSString *) objectTitle : (id) object
{
    return [NSString stringWithFormat:@"%@", object[self.titleField]];
}

- (NSString *) objectDetail : (id) object
{
    NSString *detailLabel =  [NSString stringWithFormat:@"%@ Wins", object[self.detailField]];
    return detailLabel;
}

@end
