//
//  SSTableRowCell.m
//  SixStreams
//
//  Created by Anping Wang on 12/8/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSTableRowCell.h"

@implementation SSTableRowCell 
#define seconds_in_day 24 * 3600

- (void)awakeFromNib
{
    [super awakeFromNib];
    vSunday.delegate = vMonday.delegate = vTuesday.delegate = vWednsday.delegate=vThursday.delegate=vFriday.delegate = vSaturday.delegate = self;
    vSaturday.header = @"Sat";
    vMonday.header = @"Mon";
    vTuesday.header = @"Tue";
    vWednsday.header = @"Wed";
    vThursday.header = @"Thu";
    vFriday.header = @"Fri";
    vSunday.header = @"Sun";
}

- (NSInteger) getDay:(NSDate *) date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    return [comp day];
}

- (void) callendarCell:(SSCalendarCell *)callendarCell didSelect:(id)entity
{
    if(self.delegate)
    {
        [self.delegate callendarCell:callendarCell didSelect:entity];
    }
}

- (NSArray *) getEvents:(SSCalendarCell *)tableView
{
    if (self.delegate) {
        return [self.delegate getEvents:tableView];
    }
    return nil;
}

- (void) reloadData
{
    if (self.week == -1)
    {
        vSunday.isHeader = vMonday.isHeader=vTuesday.isHeader=vWednsday.isHeader=vThursday.isHeader=vFriday.isHeader=vSaturday.isHeader = YES;
    }
    else
    {
        NSDateComponents *comp = [[NSDateComponents alloc]init];
        [comp setMonth:self.month];
        [comp setYear:self.year];
        [comp setDay:1];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *firstDate = [calendar dateFromComponents:comp];
        
        NSDateComponents *weekdayComponents =[calendar components:NSWeekdayCalendarUnit fromDate:firstDate];
        
        
        NSInteger weekday = [weekdayComponents weekday];
        
        vSunday.date = [firstDate dateByAddingTimeInterval:((self.week*7 - (weekday - 1)) * seconds_in_day)];
        vMonday.date = [vSunday.date dateByAddingTimeInterval:seconds_in_day];
        vTuesday.date = [vMonday.date dateByAddingTimeInterval:seconds_in_day];
        vWednsday.date = [vTuesday.date dateByAddingTimeInterval:seconds_in_day];
        vThursday.date = [vWednsday.date dateByAddingTimeInterval:seconds_in_day];
        vFriday.date = [vThursday.date dateByAddingTimeInterval:seconds_in_day];
        vSaturday.date = [vFriday.date dateByAddingTimeInterval:seconds_in_day];
        
        if (self.week == 0)
        {
            vSunday.inMonth = (weekday - 1) == 0;
            vMonday.inMonth = (weekday - 1) <= 1;
            vTuesday.inMonth = (weekday - 1) <= 2;
            vWednsday.inMonth = (weekday - 1) <= 3;
            vThursday.inMonth = (weekday - 1) <= 4;
            vFriday.inMonth = (weekday - 1) <= 5;
            vSaturday.inMonth = (weekday - 1) <= 6;
        }
        else if (self.week > 3)
        {
            vSunday.inMonth = [self getDay:vSunday.date] > 14;
            vMonday.inMonth = [self getDay:vMonday.date] > 14;
            vTuesday.inMonth = [self getDay:vTuesday.date] > 14;
            vWednsday.inMonth = [self getDay:vWednsday.date] > 14;
            vThursday.inMonth = [self getDay:vThursday.date] > 14;
            vFriday.inMonth = [self getDay:vFriday.date] > 14;
            vSaturday.inMonth = [self getDay:vSaturday.date] > 14;
        }
    }
    
    [vFriday reloadData];
    [vThursday reloadData];
    [vTuesday reloadData];
    [vWednsday reloadData];
    [vSaturday reloadData];
    [vSunday reloadData];
    [vMonday reloadData];
}
@end
