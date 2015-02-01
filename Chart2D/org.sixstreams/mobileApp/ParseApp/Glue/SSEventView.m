//
//  SSEventView.m
//  SixStreams
//
//  Created by Anping Wang on 1/18/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSEventView.h"
#import "SSImageView.h"
#import "SSAddress.h"
#import "SSCommonVC.h"
#import "SSTimeUtil.h"
#import "SSApp.h"
#import "SSImagesVC.h"

@interface SSEventView()<SSImageViewDelegate>
{
    SSImageView *eventIcon;
    UILabel *lStartAt;
    UILabel *lseats;
    UILabel *lAddress1;
    UILabel *lTitle;
    UILabel *lStartDate;
}

@end

@implementation SSEventView

- (id) initWithEvent:(id) event
{
    self = [super init];
    if (self)
    {
        self.event = event;
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CALayer *layer = self.layer;
    layer.cornerRadius = 8;
    layer.masksToBounds = YES;
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    [super drawRect: rect];
    CGContextRestoreGState(currentContext);
}

- (void) refreshUI
{
    if (self.imageOnly)
    {
        self.clipsToBounds = YES;
        [self cleanupUI];
        eventIcon =[[SSImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        id organizer = self.event [ORGANIZER];
        eventIcon.defaultImg = [UIImage imageNamed:@"120"];
        
        eventIcon.owner = organizer[USERNAME];
        eventIcon.backupUrl = organizer[REF_ID_NAME];
        if([self.event objectForKey:MEETING_ID]) //it is an referred item
        {
            eventIcon.url = self.event[MEETING_ID];
        }
        else{
            eventIcon.url = self.event[REF_ID_NAME];
        }
        eventIcon.cornerRadius = 4;
        eventIcon.info = self.event;
        eventIcon.delegate = self;
        [self addSubview:eventIcon];
        
    }
    else
    {
        [self refreshUIDetails];
    }
}

- (void) imageView:(id) imageView didSelect:(id)image
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(eventView:didSelect:)]) {
        [self.delegate eventView:self didSelect:self.event];
    }
}

- (void) cleanupUI
{
    [eventIcon removeFromSuperview];
    [lseats removeFromSuperview];
    [lStartAt removeFromSuperview];
    [lTitle removeFromSuperview];
    [eventIcon removeFromSuperview];
}

- (SSImageView *) getImageVew
{
    return eventIcon;
}

- (void) setupUI
{
    int width = self.frame.size.height;
    if (width < 120)
    {
        [self browserLayout];
    }
    else{
        [self spotlightLayout];
    }
}

- (void) spotlightLayout
{
    self.clipsToBounds = YES;
    int size = self.frame.size.width;
    
    eventIcon =[[SSImageView alloc]initWithFrame:CGRectMake(0, size, size, size)];
    
    lStartDate= [[UILabel alloc]initWithFrame:CGRectMake(0, 5, size, 14)];
    lStartDate.textColor = [UIColor blueColor];
    lStartDate.textAlignment = NSTextAlignmentCenter;
    lStartDate.font = [UIFont boldSystemFontOfSize:12];
    
    lStartAt= [[UILabel alloc]initWithFrame:CGRectMake(0, 20, size, 14)];
    lStartAt.textColor = [UIColor blueColor];
    lStartAt.textAlignment = NSTextAlignmentCenter;
    lStartAt.font = [UIFont boldSystemFontOfSize:12];
    
    lseats= [[UILabel alloc]initWithFrame:CGRectMake(0, 34, size, 14)];
    lseats.textColor = [UIColor grayColor];
    lseats.textAlignment = NSTextAlignmentCenter;
    lseats.font = [UIFont systemFontOfSize:12];
    
    
    lAddress1 = [[UILabel alloc]initWithFrame:CGRectMake(2, 52, size - 5, 10)];
    lAddress1.textColor = [UIColor grayColor];
    lAddress1.textAlignment = NSTextAlignmentCenter;
    lAddress1.font = [UIFont systemFontOfSize:11];
    

    lTitle= [[UILabel alloc]initWithFrame:CGRectMake(2, 60, size - 5, 50)];
    lTitle.textColor = [UIColor grayColor];
    lTitle.textAlignment = NSTextAlignmentCenter;
    lTitle.font = [UIFont boldSystemFontOfSize:11];
    [lTitle setNumberOfLines:2];
    
    [self addSubview:lAddress1];
    [self addSubview:lStartDate];
    [self addSubview:lStartAt];
    [self addSubview:lTitle];
    [self addSubview:lseats];
    [self addSubview:eventIcon];
}

#define icon_size 44

- (void) browserLayout
{
    self.clipsToBounds = YES;
    int size = self.frame.size.width;
    eventIcon =[[SSImageView alloc]initWithFrame:CGRectMake(0, 0, icon_size, icon_size)];
    
    lStartDate= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, size, 12)];
    lStartDate.textColor = [UIColor blueColor];
    lStartDate.textAlignment = NSTextAlignmentRight;
    lStartDate.font = [UIFont boldSystemFontOfSize:9];
    
    lStartAt= [[UILabel alloc]initWithFrame:CGRectMake(0, 12, size, 12)];
    lStartAt.textColor = [UIColor blueColor];
    lStartAt.textAlignment = NSTextAlignmentRight;
    lStartAt.font = [UIFont boldSystemFontOfSize:9];
    
    lseats= [[UILabel alloc]initWithFrame:CGRectMake(0, 32, size, 12)];
    lseats.textColor = [UIColor grayColor];
    lseats.textAlignment = NSTextAlignmentRight;
    lseats.font = [UIFont systemFontOfSize:10];
    
    lAddress1 = [[UILabel alloc]initWithFrame:CGRectMake(2, size - 18, size - 5, 10)];
    lAddress1.textColor = [UIColor grayColor];
    lAddress1.textAlignment = NSTextAlignmentCenter;
    lAddress1.font = [UIFont systemFontOfSize:11];
    
    lTitle= [[UILabel alloc]initWithFrame:CGRectMake(2, size - 58, size - 5, 50)];
    lTitle.textColor = [UIColor grayColor];
    lTitle.textAlignment = NSTextAlignmentCenter;
    lTitle.font = [UIFont boldSystemFontOfSize:11];
    [lTitle setNumberOfLines:2];
    
    [self addSubview:lAddress1];
    [self addSubview:lStartDate];
    [self addSubview:lStartAt];
    [self addSubview:lTitle];
    [self addSubview:lseats];
    [self addSubview:eventIcon];
}

- (void) refreshUIDetails
{
    if(eventIcon == nil)
    {
        [self setupUI];
    }
    id data = self.event;
    SSAddress *address = [[SSAddress alloc]initWithDictionary:[data objectForKey:ADDRESS]];
    id organizer = [data objectForKey:ORGANIZER];
    lTitle.text = [NSString stringWithFormat:@"%@", [data objectForKey: TITLE]];
   
    lStartDate.text = [SSTimeUtil stringFromDateWithFormat:[[SSApp instance] dateFormat] date: [data objectForKey: DATE_FROM]];
    lStartAt.text = [SSTimeUtil stringFromDateWithFormat:[[SSApp instance] timeFormat] date: [data objectForKey: DATE_FROM]];
    
    eventIcon.defaultImg = [UIImage imageNamed:@"120"];
    eventIcon.owner = [organizer objectForKey:USERNAME];
    eventIcon.backupUrl = [organizer objectForKey:REF_ID_NAME];
    
    //get files
    eventIcon.url = data[REF_ID_NAME];
    
    lseats.text = [NSString stringWithFormat:@"(%d/%d)",
                   [[data objectForKey:INVITEES] intValue],
                   [[data objectForKey:SEATS] intValue]
                   ];
    lAddress1.text = [NSString stringWithFormat:@"%@", address.location ? address.location : @""];
}


@end
