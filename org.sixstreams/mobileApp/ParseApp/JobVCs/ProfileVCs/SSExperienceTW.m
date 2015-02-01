//
//  SSEmployerTV.m
//  JobsExchange
//
//  Created by Anping Wang on 2/9/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSExperienceTW.h"
#import "SSExperienceVC.h"
#import "SSCommonVC.h"
#import "SSJSONUtil.h"
#import "SSJobApp.h"

@interface SSExperienceTW()
@end;

@implementation SSExperienceTW

- (id) createItem
{
    NSMutableDictionary *newItem = [NSMutableDictionary dictionary];
    [newItem setObject:@"0" forKey:JOB_TITLE];
    return newItem;
}

- (void) tableViewCell:(UITableViewCell *) cell forItem:(id)item
{
    cell.textLabel.text =[[SSApp instance] value:item forKey:JOB_TITLE];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    NSString *companyRef = [[SSApp instance] value:item forKey:COMPANY];
    if(companyRef)
    {
        @try {
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ (%@ - %@)",
                                         companyRef, [[item objectForKey:YEAR_START]toYearMonthString],
                                         [[item objectForKey:YEAR_END]toYearMonthString]];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        }
        @catch (NSException *exception) {
            //
        }
    }
}

- (NSString *) displayValueFor:(id) item
{
    return [[SSApp instance] value:item forKey:JOB_TITLE];
}

- (SSEntityEditorVC *) createEditor
{
    return [[SSExperienceVC alloc]init];;
}


@end
