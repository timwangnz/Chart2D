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
}

@end

@implementation CampaignVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql = @"select campaign_id from bk_campaign";
    self.titleField = @"CAMPAIGN_ID";
    self.detailField = @"WINS";
    [self getData];
}

@end
