//
//  SSCarouselView.m
//  SixStreams
//
//  Created by Anping Wang on 8/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSCarouselView.h"
#import "SSImageView.h"
#import "SSCommonVC.h"

@interface SSCarouselView ()<iCarouselDataSource, iCarouselDelegate>
{
    NSMutableArray *detailsViews;
    UITapGestureRecognizer *tapGesture;
    int animationIdx;
    NSArray *entites;
}

@end

@implementation SSCarouselView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void) updateUI:(id) objects
{
    self.delegate = self;
    self.dataSource = self;
    if (!detailsViews)
    {
        detailsViews = [NSMutableArray array];
    }
    
    for(UIView *view in detailsViews)
    {
        [view removeFromSuperview];
    }
    
    [detailsViews removeAllObjects];
    entites = objects;
    for (id item in objects)
    {
        SSImageView *eventView =[[SSImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        eventView.defaultImg = [UIImage imageNamed:@"people"];
        if (item[PICTURE_URL])
        {
            eventView.isUrl = YES;
            eventView.url = item[PICTURE_URL];
        }else
        {
            eventView.isUrl = NO;
            eventView.url = item[USER_INFO][REF_ID_NAME];
        }
        
        eventView.cornerRadius = self.width / 2;
        [detailsViews addObject:eventView];
    }
    self.type = iCarouselTypeLinear;
    [self reloadData];
}

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index
{
    return YES;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if(self.carouselViewDelegate && [self.carouselViewDelegate respondsToSelector:@selector(view:didSelect:)])
    {
        [self.carouselViewDelegate view:self didSelect: entites[index]];
    }
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [detailsViews count];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.2;
    }
    if (option == iCarouselOptionOffsetMultiplier)
    {
        return 1;
    }
    return value;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIView *label = nil;
    
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        view.contentMode = UIViewContentModeCenter;
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.tag = carousel.tag;;
        [view addSubview:label];
    }
    else
    {
        label = (UILabel *)[view viewWithTag:carousel.tag];
    }
    UIView *childView = [detailsViews objectAtIndex:index];
    [childView setUserInteractionEnabled:YES];
    [childView removeFromSuperview];
    [label addSubview:childView];
    return view;
}

@end
