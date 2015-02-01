//
//  SSEducationTW.m
//  JobsExchange
//
//  Created by Anping Wang on 3/5/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSEducationTW.h"
#import "SSEducationVC.h"
#import "SSJSONUtil.h"
#import "SSJobApp.h"

@interface SSEducationTW()
@end;


@implementation SSEducationTW

- (id) createItem
{
    NSMutableDictionary *newItem = [NSMutableDictionary dictionary];
    [newItem setObject:@"0" forKey:DEGREE];
    return newItem;
}

- (void) tableViewCell:(UITableViewCell *) cell forItem:(id) item
{
   
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.text =[[SSApp instance] displayValue:[item objectForKey: DEGREE] forAttr:DEGREE ofType:JOB_CLASS ];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if ([item objectForKey:SCHOOL])
    {
        @try {
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ (%@ - %@)",[item objectForKey: SCHOOL], [[item objectForKey:YEAR_START] toYearMonthString], [[item objectForKey:YEAR_END]toYearMonthString]];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        }
        @catch (NSException *exception) {
            //
        }
    }
    
}

- (NSString *) displayValueFor:(id) item
{
    return [[SSApp instance] displayValue:[item objectForKey: DEGREE] forAttr:DEGREE ofType:JOB_CLASS ];
}


- (SSEntityEditorVC *) createEditor
{
    return [[SSEducationVC alloc]init];
}

@end
