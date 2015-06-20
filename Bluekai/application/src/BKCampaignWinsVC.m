//
//  CampaignWinsVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 5/9/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKCampaignWinsVC.h"


@interface BKCampaignWinsVC ()
{
    
    int selected;

}

@end

@implementation BKCampaignWinsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.partnerId)
    {
        self.sql = [NSString stringWithFormat:
                    @"select campaign_id, sum(wins) wins from BK_CAMPAIGN_DELIVERY_VIEW where campaign_id in (select campaign_id from bk_campaign where partner_id = %ld) group by campaign_id", (long)self.partnerId];
    }
    else
    {
        self.sql = @"select * from bk_campaign_view where created_at between sysdate - 1 and sysdate";
    }
    
    self.cacheTTL = 3600;
    
    self.titleField = @"CAMPAIGN_ID";
    self.detailField = @"WINS";
    self.cellStyle = UITableViewCellStyleValue1;
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


-(void) showTrend:(int) campaignId
{
    
    trend.sql = [NSString stringWithFormat:
                 @"select start_time, sum(wins) wins, sum(targeted) targeted, sum(loss_budget) budget, sum(loss_publisher) PUBLISHER, sum(loss_sdtuser) sdt_user, sum(prevwin) PREV_WINS from BK_CAMPAIGN_DELIVERY_VIEW where campaign_id=%d and start_time > sysdate-1 group by start_time order by start_time", campaignId];
    
    
    selected = campaignId;
    trend.limit = 30;
    trend.title = @"Campaign Wins/Losses";
    trend.valueFields[0] = @"WINS";
    trend.valueFields[1] = @"TARGETED";
    trend.valueFields[2] = @"PREV_WINS";
    trend.valueFields[3] = @"SDT_USER";
    trend.valueFields[4] = @"PUBLISHER";
    
    trend.xLabelField = @"START_TIME";
    trend.topMargin = 20;
    trend.bottomMargin = 40;
    trend.leftMargin = 60;
    trend.topPadding = 0;
    trend.legendType = Graph2DLegendNone;
    trend.yMin = 0;
    trend.autoScaleMode = Graph2DAutoScaleMax;
    trend.xAxisStyle.tickStyle.majorTicks = 8;
    trend.yAxisStyle.tickStyle.majorTicks = 6;
    trend.displayNames =@{@"WINS":@"Wins", @"TARGETED":@"Targeted", @"PREV_WINS" : @"Previous Win", @"SDT_USER":@"SDT User", @"PUBLISHER":@"Publisher", @"CAMPAIGN": @"Campaigns"};
    trend.legendType = Graph2DLegendTop;
    
    trend.cacheTTL = 3600;
    self.titleField = @"CAMPAIGN_ID";
    
    [trend reload];
    [self updateLayout];
    
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id category = [filteredObjects objectAtIndex:indexPath.row];
    int campaignId = [category[@"CAMPAIGN_ID"] intValue];
    if (campaignId == selected)
    {
        
    }
    else{
        [self showTrend:campaignId];
        selected = campaignId;
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
    int header = 62;
    int height = self.view.bounds.size.height / 2;
    if (!selected) {
        height = 0;
    }
    trend.frame = CGRectMake(trend.frame.origin.x, self.view.bounds.size.height - height, trend.frame.size.width, height);
    tableview.frame = CGRectMake(tableview.frame.origin.x, header, tableview.frame.size.width, self.view.bounds.size.height - trend.frame.size.height - header);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selected = 0;
    [self _updateLayout];
    
}


@end
