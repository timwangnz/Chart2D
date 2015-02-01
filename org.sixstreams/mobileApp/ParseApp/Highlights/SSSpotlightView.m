//
//  SSSpotlightView.m
//  SixStreams
//
//  Created by Anping Wang on 5/14/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSSpotlightView.h"
#import "SSApp.h"
#import "SixStreams.h"
#import "SSImagesVC.h"

@interface SSSpotlightView()
{
    SSImageView *eventIcon;
}
@end

@implementation SSSpotlightView


- (id) initWithEntity:(id) entity
{
    self = [super init];
    if (self)
    {
        self.entity = entity;
    }
    return self;
}

- (void) cleanupUI
{
    for (UIView *childView in [self subviews])
    {
        [childView removeFromSuperview];
    }
}

- (SSImageView *) getImageView
{
    return eventIcon;
}

- (void) setupUI
{
    self.clipsToBounds = YES;
    int size = self.frame.size.width;
    
    eventIcon =[[SSImageView alloc]initWithFrame:CGRectMake(0, size, size, size)];
    eventIcon.defaultImg = [[SSApp instance] defaultImage:self.entity ofType:self.entityType];
    eventIcon.image = eventIcon.defaultImg;
    eventIcon.url = self.entity[REF_ID_NAME];
    eventIcon.backupUrl = self.entity[ORGANIZER][REF_ID_NAME];
    eventIcon.contentMode = UIViewContentModeScaleAspectFill;
    eventIcon.cornerRadius = 0;
    
    [self addSubview:eventIcon];
    [self sendSubviewToBack:eventIcon];
}

- (void) refreshUI
{
    for (UIView *childView in [self subviews])
    {
        [childView removeFromSuperview];
    }
    [[SSApp instance] updateHighlightItem:self.entity ofType:self.entityType inView:self];
    [self setupUI];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(view:isMoving:)])
    {
        [self.delegate view:self isMoving:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(view:didSelect:)])
    {
        [self.delegate view:self didSelect:event];
        return;
    }
}


@end
