//
//  BKFrontPageVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/22/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKFrontPageVC.h"

@interface BKFrontPageVC ()

@end

@implementation BKFrontPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql = @"select * from BK_ORACLE_VIEW where CREATED_AT between sysdate -1 and sysdate";
    sections = @{
                   @"Profiles" : @[@"PROFILES", @"UPDATED_IN30DAYS", @"UPDATED_IN7DAYS", @"UPDATED_24HR"],
                 @"ID Types" : @[@"ANDROID_IDS", @"APPLE_AD_IDS", @"STATS_ID", @"VERIZON_UIDHS", @"GOOGLE_AD_IDS", @"DESKTOP_IDS", @"FIRST_PARTY_IDS"],
               
                 @"Operational" : @[@"OFFLINE_UPDATED", @"ID_SWAPPED",@"TOTAL_TAGGED",@"TAGGED_TODAY"]
                 };
  
    self.cacheTTL = 30;
    
    displayNames = @{
                  @"ANDROID_IDS":@"Android Ids",
                  @"APPLE_AD_IDS":@"Apple Ad Ids",
                  @"STATS_ID" : @"Stats Ids",
                  @"VERIZON_UIDHS" : @"Verizon UIDH",
                  @"GOOGLE_AD_IDS" : @"Google Ad Ids",
                  @"DESKTOP_IDS" : @"Desktop Ids",
                  @"FIRST_PARTY_IDS" : @"First Party Ids",
                  @"PROFILES" : @"Profiles",
                  @"UPDATED_IN30DAYS" : @"Updated in 30 Days",
                  @"UPDATED_IN7DAYS" : @"Updated in 7 Days",
                  @"UPDATED_24HR" : @"Updated in 24 Hr",
                  @"OFFLINE_UPDATED" : @"Total Offline Updates",
                  @"ID_SWAPPED" : @"Total Id Swaps",
                  @"TOTAL_TAGGED" : @"Total Tags",
                  @"TAGGED_TODAY" : @"Tags Generated in 24 Hr."
                 };
    [self getData];
}

@end
