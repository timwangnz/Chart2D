//
//  TreeIconsLV.m
// Appliatics2
//
//  Created by Anping Wang on 5/3/13.
//  Copyright (c) 2013 s. All rights reserved.
//

#import "TreeIconsLV.h"
#import "TreeNodeIconVC.h"
#import "AttributeValue.h"

@interface TreeIconsLV()
{
    BOOL afterLayout;
}
@end

@implementation TreeIconsLV

- (IconViewVC *) createIconView :(AttributeValue *) userInfo
{
    TreeNodeIconVC * treeNode = [[TreeNodeIconVC alloc] initWithNibName:@"IconViewVC" bundle:nil];
    treeNode.iconSize = userInfo.iconSize;
    return treeNode;
}

- (void) drawRect:(CGRect) rect
{
    [self drawLinks];
}

- (void) drawLink:(IconViewVC *) from to:(IconViewVC *) to
{
    if (!to || !from)
    {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 0.5);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {0.9, 0.9, 0.9, 1.0};
    
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, color);
    
    CGPoint fromPt = [from getCenter];
    CGPoint toPt = [to getCenter];
    
    CGContextMoveToPoint(context, fromPt.x, fromPt.y);
    
    CGContextAddLineToPoint(context, fromPt.x, (toPt.y + fromPt.y)/2);
    
    CGContextAddLineToPoint(context, toPt.x, (toPt.y + fromPt.y)/2);
    
    CGContextAddLineToPoint(context, toPt.x, toPt.y);
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
}

- (void) drawLinks
{
    if(afterLayout)
    {
        for(IconViewVC *item in [self getIconViews])
        {
            for (IconViewVC *child in [item getChildren]) {
                [self drawLink:item to:child];
            }
        }
    }
}

- (NSArray *) getChildrenAtLevel:(int) level
{
    NSMutableArray *array = [NSMutableArray array];
    for(IconViewVC *item in [self getIconViews])
    {
        if (item.row == level)
        {
            [array addObject:item];
        }
    }
    if ([array count] == 1)
    {
        return array;
    }
    NSArray *sortedArray;
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        int col1 = [(IconViewVC*)a col];
        int col2 = [(IconViewVC*)b col];
        return col1 > col2;
    }];
    
    return sortedArray;
}

- (void) setCol: (TreeNodeIconVC *) item col:(int) col
{
    item.col = col;
    NSArray *children = [item getChildren];
    int i = 1;
    for (TreeNodeIconVC *child in children)
    {
        [self setCol:child col: (col *10 ) + (i++)];
        
    }
}

- (void) doLayout
{
    afterLayout = NO;
    CGFloat x = 100.0f;
    CGFloat y = 0.0f;
    
    int col = 0;
    int hGap = 10;
    int maxHeight = 0;
    int maxWidth = 0;
    float averageWidth = 0;
    
    int totalLevels = 0;
    
    TreeNodeIconVC *rootItem = nil;
    
    for(TreeNodeIconVC *item in [self getIconViews])
    {
        item.row = [item getLevel];
        if (item.row + 1 > totalLevels)
        {
            totalLevels = item.row + 1;
        }
        if (item.row == 0)
        {
            rootItem = item;
        }
    }
    NSInteger totalcols = 0;
    
    if (rootItem)
    {
        [self setCol:rootItem col:1];
        for (int i = 0; i< totalLevels; i++) {
            NSArray *childrenAtLevel = [self getChildrenAtLevel:i];
            if ([childrenAtLevel count]>totalcols)
            {
                totalcols = [childrenAtLevel count];
            }
            col = 0;
            for (TreeNodeIconVC *item in childrenAtLevel)
            {
                UIView *iconView =  item.view;
                CGFloat iconWidth = self.width == 0 ? iconView.frame.size.width : self.width;
                CGFloat iconHeight = self.height == 0 ? iconView.frame.size.height : self.height;
                if(item.iconSize.width != 0)
                {
                    iconWidth = item.iconSize.width;
                    iconHeight = item.iconSize.height;
                }
                averageWidth = iconWidth;
                
                iconView.frame = CGRectMake(x + col * (iconWidth + hGap) + hGap, y + i * (iconHeight + self.vGap)
                                            + self.vGap +
                                            self.topMargin,
                                            iconWidth,
                                            iconHeight
                                            );
                col++;
                [self addSubview:iconView];
                if ((iconView.frame.origin.x + iconView.frame.size.width + hGap) > maxWidth)
                {
                    maxWidth = iconView.frame.origin.x + iconView.frame.size.width + hGap;
                }
                
                if ((iconView.frame.origin.y + iconView.frame.size.height + self.vGap) > maxHeight)
                {
                    maxHeight = iconView.frame.origin.y + iconView.frame.size.height + self.vGap;
                }
            }
        }
    }
    //adjust horizontally
    for (int i = 0; i < totalLevels; i++)
    {
        NSArray *items = [self getChildrenAtLevel:i];
        
        
        col = 0;
        if(totalcols % 2 == 0)
        {
            x = maxWidth / 2 - [items count] * averageWidth/2 - hGap *([items count] - 1)/2.0;
        }
        else {
            x = maxWidth / 2 - (([items count])/ 2.0) * averageWidth;
        }
        // x = 0;
        for (IconViewVC *levelItem in items)
        {
            UIView *iconView =  levelItem.view;
            CGFloat iconWidth = iconView.frame.size.width;
            CGFloat iconHeight = iconView.frame.size.height;
            
            iconView.frame = CGRectMake(x + (col++) * (iconWidth + hGap) + hGap, iconView.frame.origin.y, iconWidth, iconHeight);
            
        }
    }
    
    
    maxWidth = maxWidth + averageWidth + hGap;
    
    self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,
                            maxWidth > self.frame.size.width ? maxWidth : self.frame.size.width,
                            maxHeight > self.frame.size.height ? maxHeight : self.frame.size.height);
    
    afterLayout = YES;
    [self setNeedsDisplay];
}

@end
