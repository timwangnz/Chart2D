//
// AppliaticsIconView.m
// AppliaticsMobile
//
//  Created by Anping Wang on 3/31/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "IconsLayoutView.h"
#import "IconViewVC.h"
#import "AttributeValue.h"
@interface IconsLayoutView()
{
    int showMode;
    NSMutableArray *iconViews;
    
}
@end

@implementation IconsLayoutView

-(IBAction)reorder:(id)sender
{
    [iconViews exchangeObjectAtIndex:0 withObjectAtIndex :1];
    [iconViews exchangeObjectAtIndex:3 withObjectAtIndex :5];
    [UIView transitionWithView: self duration:0.75
					   options:UIViewAnimationOptionTransitionNone
					animations:^ {
                        [self doLayout];
                    }
					completion:nil];
    
}

- (void) onSelect: (id) sender object: (id) object
{
    if (self.iconViewDelegate)
    {
        [self.iconViewDelegate onSelect: sender object:object];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.columns = 4;
        self.vGap = 20;
        self.topMargin = 0;
    }
    return self;
}
- (void) doLayout
{
    _columns = 4;
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    
    int i = 0;
    
    for(IconViewVC *item in iconViews)
    {
        UIView *iconView =  item.view;
        int row = i / _columns;
        int col = i - row * _columns;
        
        CGFloat iconWidth = self.width == 0 ? iconView.frame.size.width : self.width;
        CGFloat iconHeight = self.height == 0 ? iconView.frame.size.height : self.height;
        
        
        int hGap = (self.frame.size.width - iconWidth * _columns)/(_columns + 1);
        
        iconView.frame = CGRectMake(x + col * (iconWidth + hGap) + hGap, y + row * (iconHeight + _vGap) + _vGap + _topMargin, iconWidth, iconHeight);
        
        [self addSubview:iconView];
        i++;
    }
}

- (IconViewVC *) createIconView :(AttributeValue *) userInfo
{
    return [[IconViewVC alloc] init];
}

- (NSArray *) getIconViews
{
    return iconViews;
}

- (void) setItems:(NSArray *) items
{
    for (IconViewVC *iconView in iconViews)
    {
        [iconView.view removeFromSuperview];
    };
    
    iconViews = nil;
    if (items)
    {
        iconViews = [[NSMutableArray alloc] initWithCapacity:[items count]];
        
        for (AttributeValue *item in items)
        {
            if (showMode != 0)
            {
                if (showMode == 1 && item.sequence % 2 != 0) {
                    continue;
                }
                if (showMode == 2 && item.sequence % 2 == 0)
                {
                    continue;
                }
            }
            
            IconViewVC *iconView = [self createIconView: item];
            iconView.iconViewDelegate = self;
            iconView.subtitle = item.subtitle;
            iconView.imageUrl =  item.iconImg;
            iconView.label = item.name;
            iconView.badges = item.badges;
            iconView.userInfo = item;
            [iconViews addObject:iconView];
        }
        
        for (IconViewVC *iconView in iconViews)
        {
            AttributeValue *item = iconView.userInfo;
            for(AttributeValue *childValue in [item getChildren])
            {
                for (IconViewVC *childIconView in iconViews)
                {
                    AttributeValue *childItem = childIconView.userInfo;
                    if ([childValue isEqual:childItem])
                    {
                        [iconView addChild:childIconView];
                        childIconView.parentIconView = iconView;
                    }
                }
            }
        }
    }
    [self doLayout];
}

@end
