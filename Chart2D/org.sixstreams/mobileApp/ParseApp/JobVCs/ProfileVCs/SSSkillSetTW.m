//
//  SSSkillSetTW.m
//  SixStreams
//
//  Created by Anping Wang on 4/2/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSSkillSetTW.h"
#import "SSApp.h"
#import "SSSkillSetEditorVC.h"

@implementation SSSkillSetTW

- (id) createItem
{
    NSMutableDictionary *newItem = [NSMutableDictionary dictionary];
    newItem[JOB_TITLE] = self.item[JOB_TITLE];
    return newItem;
}

- (void) tableViewCell:(UITableViewCell *) cell forItem:(id) item
{
    cell.textLabel.text = item[DISPLAY_VALUES][SKILL];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.text = [[SSApp instance] displayValue: [item objectForKey: SKILL_LEVEL] forAttr:SKILL_LEVEL ofType:JOB_CLASS];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
}

- (NSString *) displayValueFor:(id) item
{
    return item[DISPLAY_VALUES][SKILL];
}


- (SSEntityEditorVC *) createEditor
{
    return [[SSSkillSetEditorVC alloc]init];
}

@end
