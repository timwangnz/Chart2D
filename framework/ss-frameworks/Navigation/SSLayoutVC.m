//
//  SSChildrenVC.m
//  SixStreams
//
//  Created by Anping Wang on 6/24/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSLayoutVC.h"

@interface SSLayoutVC ()
{
    __weak IBOutlet UILabel *titleLabel;
    IBOutlet UITableView *menuTable;
    NSMutableArray *iconViews;
    IBOutlet UIScrollView *iconsView;
    UIView *childView;
    UIViewController *childVC;
    IBOutlet UILabel *msgLabel;
    IBOutlet UIButton *btnCreateApp;
}
@end

@implementation SSLayoutVC

- (void) updateUI
{
    if ([iconViews count]==0)
    {
        msgLabel.hidden = NO;
        msgLabel.text = [NSString stringWithFormat:@"%@ - %@",
                         [self.entity objectForKey:NAME],
                         @"No views found"];
    }
    else{
        msgLabel.hidden = YES;
    }
    [self doLayout];
}

- (void) entityChanged
{
    //does nothing;
}

- (void) showDetails:(UIViewController *)detailsVC
{
    float windowWidth = self.view.frame.size.width;
    float width = detailsVC.view.frame.size.width;// * 1.25;
    if (![[childVC.view superview] isEqual:self.view])
    {
        [childVC removeFromParentViewController];
        [childVC.view removeFromSuperview];
        childVC = detailsVC;
        detailsVC.view.frame = CGRectMake(self.view.frame.size.width, 0, width, self.view.frame.size.height);
        [self.view addSubview:detailsVC.view];
        [UIView animateWithDuration:0.5 animations:^{
            detailsVC.view.frame = CGRectMake(windowWidth - width, 0, width, self.view.frame.size.height);
            iconsView.frame = CGRectMake(0, 64, windowWidth - width, self.view.frame.size.height - 64);
            [self doLayout];
        } completion:^(BOOL finished) {
        }];
    } else{
        detailsVC.view.frame = CGRectMake(windowWidth - width, 0, width, self.view.frame.size.height);
        [self.view addSubview:detailsVC.view];
        [UIView animateWithDuration:0.5 animations:^{
            detailsVC.view.alpha = 0;
            [childVC.view removeFromSuperview];
            childVC = detailsVC;
            detailsVC.view.alpha = 1;
            
        }];
    }
}

- (void) setTitle:(NSString *)title
{
    [super setTitle:title];
    titleLabel.text = title;
}

- (void) setEntity:(id)entity
{
    _entity = entity;
    [childVC removeFromParentViewController];
    [childVC.view removeFromSuperview];

    for(UIView *view in iconViews)
    {
        [view removeFromSuperview];
    }
    [iconViews removeAllObjects];
    iconsView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
    [self entityChanged];
    msgLabel.hidden = [iconViews count] == 0;
}

- (void) addIconView :(id) iconVC
{
    if (iconViews == nil)
    {
        iconViews = [NSMutableArray array];
    }
    [iconViews addObject:iconVC];
}

- (NSArray *) getIconViews
{
    return iconViews;
}

- (void) clearIconViews
{
    for (UIViewController *listView in iconViews)
    {
        [listView.view removeFromSuperview];
    }
    iconViews = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void) doLayout
{
    self.columns = self.columns > 0 ? self.columns : [self isIPad] ? 4 : 2;
    float vGap = 30, topMargin = 20;
    float height;
    
    int col = 0, row = 0;
    CGFloat iconWidth,iconHeight;
    for(UIView *item in iconViews)
    {
        iconWidth = item.frame.size.width;
        iconHeight = item.frame.size.height;
    }
    int hGap = 30;//(self.view.frame.size.width - iconWidth * self.columns)/(self.columns + 1);
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    for(UIView *item in iconViews)
    {
        x = (col++) * (iconWidth + hGap) + hGap/2;
        if (x + iconWidth > iconsView.frame.size.width)
        {
            col = 0;
            x = (col++) * (iconWidth + hGap) + hGap/2;
            row ++;
            height = y + iconHeight;
        }
        y = row * (iconHeight + vGap) + topMargin;
        item.frame = CGRectMake(x, y, iconWidth, iconHeight);
        [iconsView addSubview:item];
    }
    
    [iconsView setContentSize: CGSizeMake(iconsView.frame.size.width, y + iconHeight + topMargin)];
    
    self.navigationItem.rightBarButtonItem = nil;
    
}

@end
