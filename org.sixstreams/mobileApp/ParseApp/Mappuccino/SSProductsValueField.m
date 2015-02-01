//
//  SSProductsValueField.m
//  SixStreams
//
//  Created by Anping Wang on 4/8/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSProductsValueField.h"
#import "SSProductEditorVC.h"

@implementation SSProductsValueField

- (id) createItem
{
    NSMutableDictionary *newItem = [NSMutableDictionary dictionary];
    [newItem setObject:@"product name" forKey:NAME];
    return newItem;
}

- (void) tableViewCell:(UITableViewCell *) cell forItem:(id) item
{
    cell.textLabel.text = [item objectForKey: NAME];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.text = [item objectForKey: PRICE];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
}

- (SSEntityEditorVC *) createEditor
{
    return [[SSProductEditorVC alloc]init];
}

@end
