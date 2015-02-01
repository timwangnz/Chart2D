//
//  SSCalendarCell.m
//  SixStreams
//
//  Created by Anping Wang on 12/9/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSCalendarCell.h"
#import "SSJSONUtil.h"

@interface SSCalendarCell()
{
    UILabel *label;
    UIButton *event;
    NSArray *events;
    UIColor *origColor;
}
@end

@implementation SSCalendarCell

- (void) drawRect:(CGRect)rect
{
    CALayer *layer = self.layer;
     layer.masksToBounds = NO;
     layer.cornerRadius = 8; // if you like rounded corners
     layer.shadowOffset = CGSizeMake(2, 2);
     layer.shadowRadius = 2;
     layer.shadowOpacity = 0.4;
    
    [super drawRect: rect];
}
 
- (void)awakeFromNib
{
    [super awakeFromNib];
    int imgSize = 16;
    label = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, self.frame.size.width - 5, 20)];
    [self addSubview:label];
    label.text = @"2";
    
    self.inMonth = YES;
    [self addTap:self];
    label.textAlignment = NSTextAlignmentLeft;
    event = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width / 2 - imgSize / 2, self.frame.size.height / 2 - 2, imgSize, imgSize)];
    [event setBackgroundImage:[UIImage imageNamed:@"red-indicator.png"] forState:UIControlStateNormal];
    
    event.enabled = YES;
    [event setUserInteractionEnabled:NO];
    event.hidden = YES;
    event.titleLabel.font = [UIFont systemFontOfSize:10];
    origColor = self.backgroundColor;
    [self addSubview:event];
}

- (void)viewTaped:(UIGestureRecognizer *)gestureRecognizer
{
    if ([events count] == 0) {
        return;
    }
    [UIView animateWithDuration:0.25
                     animations:^(void){
                         gestureRecognizer.view.alpha = 0.25f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.25 animations:^(void)
                          {
                              gestureRecognizer.view.alpha = 1.0f;
                          }
                                          completion:^(BOOL finished)
                          {
                              
                              if (!self.isHeader && self.delegate)
                              {
                                  [self.delegate callendarCell:self didSelect:self.data];
                              }
                              
                          }
                          ];
                     }];
}

- (void) addTap:(UIView *) iv
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    [iv addGestureRecognizer:singleTap];
    [iv setUserInteractionEnabled:YES];
}

- (void) reloadData
{
    events = nil;
    if (self.isHeader)
    {
        self.backgroundColor = [UIColor clearColor];
        label.text = self.header;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        if (!self.inMonth)
        {
            label.textColor =[UIColor grayColor];
        }
        else
        {
            label.textColor =[UIColor whiteColor];
        }
        
        if([self.date isToday])
        {
            
            self.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor redColor];
        }
        else
        {
            self.backgroundColor = [UIColor clearColor];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d"];
        label.text = [dateFormatter stringFromDate:self.date];
        event.hidden = YES;
        if (self.delegate)
        {
            events = [self.delegate getEvents:self];
            if (events && [events count]>0)
            {
                [event setTitle:@([events count]).stringValue forState:UIControlStateNormal];
                event.hidden = NO;
            }
        }
    }
}

@end
