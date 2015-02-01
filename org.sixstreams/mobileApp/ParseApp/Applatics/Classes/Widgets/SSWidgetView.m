//
// AppliaticsWidgetView.m
// Appliatics
//
//  Created by Anping Wang on 4/2/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSWidgetView.h"
#import "SSConnection.h"
#import "SSExpressionParser.h"

@interface SSWidgetView()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *entitiesView;
    id columns;
}
@end

@implementation SSWidgetView

- (void) forceRefresh
{
    SSConnection *syncher = [SSConnection connector];
    NSString * url = [self.widget objectForKey:@"dataUrl"];
    url = [SSExpressionParser parse:url forObject:self.entity];
    [syncher objects:nil
              ofType:self.objectType
             orderBy:nil
           ascending:YES
              offset:0 limit:200
           onSuccess:^(NSDictionary *data) {
               self.entities = [data objectForKey:@"data"];
               [entitiesView reloadData];
           }
           onFailure:^(NSError *error) {
               DebugLog(@"%@",error);
           }
     ];
}

- (BOOL) isCollection
{
    BOOL collection = [[self.widget objectForKey:@"collection"] boolValue];
    return collection;
}

- (void) setWidget:(id)widget
{
    _widget = widget;
    columns =[widget objectForKey:@"columns"];
    
    self.showHeaders = NO;
    
    if ((columns == [NSNull null] || !columns || [columns count] == 0))
    {
        columns = nil;
    }
    else
    {
        NSMutableArray *visibleColumns = [NSMutableArray array];
        for (id column in columns) {
            id style = [column objectForKey:@"style"];
            BOOL visible = [[style objectForKey:@"visible"] boolValue];
            if (visible)
            {
                [visibleColumns addObject:column];
            }
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:SEQUENCE  ascending:YES];
        columns = [NSMutableArray arrayWithArray:
                   [visibleColumns sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
    }
    self.tableColumns = columns ? [columns count] : 1;
    
}
- (void) refresUI
{
    [entitiesView reloadData];
}

- (void) updateUI
{
    entitiesView = [[UITableView alloc]initWithFrame:self.frame style:UITableViewStylePlain];
    entitiesView.dataSource = self;
    entitiesView.delegate = self;
    [entitiesView setSeparatorInset:UIEdgeInsetsZero];
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    entitiesView.frame = frame;
    
    [self addSubview:entitiesView];
    
    if ([self isCollection])
    {
        [self forceRefresh];
    }
    else
    {
        self.entities = [self.widget objectForKey:@"columns"];
        self.tableColumns = 1;
        [entitiesView reloadData];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entities count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && self.showHeaders)
    {
        return [self tableView:tableView cellForHeaderAtIndexPath:indexPath];
    }
    
    NSInteger row = indexPath.row - (self.showHeaders ? 1 : 0);
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    
    for (UIView *child in [cell.contentView subviews])
    {
        [child removeFromSuperview];
    }
    
    cell.textLabel.text = @"";
    
    if (row % 2 == 0)
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.9];
    }
    else{
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    if(![self isCollection])
    {
        NSDictionary *object = [self.entities objectAtIndex:indexPath.row];
        
        id title  = [object objectForKey:NAME];
        NSString *valueBinding = [object objectForKey:@"titleBinding"];
        NSString *valueStr = [SSExpressionParser parse: valueBinding forObject: self.entity];
        
        cell.textLabel.text =[title fromCamelCase];
        cell.detailTextLabel.text = valueStr;
    }
    else
    {
        float x = 10;
        
        for(int i = 0; i < self.tableColumns; i++)
        {
            UIView *cellFrame = [self tableViewCell:cell itemAtRow:row col: i];
            
            [cell.contentView addSubview: cellFrame];
            
            int cellHeight = cellFrame.frame.size.height;
            
            int y = (cell.contentView.frame.size.height - cellFrame.frame.size.height) / 2;
            
            float left = cellFrame.frame.origin.x;
            float width = [self tableView:tableView widthForColumn:i];
            cellFrame.frame = CGRectMake(x + left, y, width - 10, cellHeight);
            
            x += width;
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView widthForColumn:(int) col
{
    id style = [[columns objectAtIndex:col]objectForKey:@"style"];
    int colWidth = [[style objectForKey:@"width"] intValue];
    if (colWidth != 0)
    {
        return colWidth;
    }
    
    return tableView.frame.size.width / self.tableColumns;
}

- (NSString *) getText:(id) item atCol:(NSDictionary *) column
{
    NSString *binding = column ? [column objectForKey:@"titleBinding"] : NAME;
    id displayName = [item objectForKey:binding];
    
    if (!displayName)
    {
        displayName = [SSExpressionParser parse:binding forObject:item];
    }
    
    if ([displayName isKindOfClass:[NSArray class]])
    {
        return [displayName count] == 0 ? @"" : [displayName objectAtIndex:0];
    }
    else
    {
        if (column)
        {
            id metaType = [column objectForKey:META_TYPE];
            if ((metaType != [NSNull null]) && [metaType isEqualToString:@"currency"])
            {
                displayName = [displayName toCurrency];
            }
        }
        return displayName;
    }
}


- (NSString *) getHeaderText:(int) col
{
    return [NSString stringWithFormat:@"%@", columns ? [[columns objectAtIndex:col] objectForKey:NAME] : NAME];
}


- (NSString *) getCellText:(id) item atCol:(NSInteger) col
{
    return [NSString stringWithFormat:@"%@", [self getText:item atCol: [columns objectAtIndex:col]]];
}

- (UIView *) tableViewCell:(UITableViewCell *) cell itemAtRow:(NSInteger) row col:(NSInteger) col
{
    UILabel *uiLabel = [[UILabel alloc]init];
    
    id item  = [self.entities objectAtIndex:row];
    
    NSString *cellText = [self getCellText:item atCol:col];
    
    if ([cellText isEqual:[NSNull null]] || !cellText)
    {
        cellText = @"";
    }
    
    uiLabel.text = cellText;
    uiLabel.backgroundColor = [UIColor clearColor];
    uiLabel.textColor = [UIColor blackColor];
    uiLabel.font = [UIFont systemFontOfSize:12];
    uiLabel.frame = CGRectMake(0,0,100,26);
    return uiLabel;
}

- (UIView *) tableViewCell:(UITableViewCell *) cell headerAt:(int) col
{
    UILabel *uiLabel = [[UILabel alloc]init];
    uiLabel.text = [[self getHeaderText:col] fromCamelCase];
    uiLabel.backgroundColor = [UIColor clearColor];
    return uiLabel;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    
    for (UIView *child in [cell.contentView subviews])
    {
        [child removeFromSuperview];
    }
    
    float x = 10;
    
    for(int i = 0; i < self.tableColumns; i++)
    {
        UIView *cellFrame = [self tableViewCell:cell headerAt:i];
        [cell.contentView addSubview: cellFrame];
        float width = [self tableView:tableView widthForColumn:i];
        cellFrame.frame = CGRectMake(x, 1, width + 1, cell.contentView.frame.size.height - 2);
        x += width;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
