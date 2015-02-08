//
// AppliaticsIconView.m
// Appliatics
//
//  Created by Anping Wang on 9/25/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSIconView.h"
@interface SSIconView ()
{
    NSDate *timeDown;
    NSTimer *timer;
}

@end

@implementation SSIconView

- (IBAction) open:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(iconView:itemSelected:)])
    {
        [self.delegate iconView:self itemSelected:self.subscription];
    }
}

- (void) showBadge
{
    [timer invalidate];
    timer = nil;
    self.badges = 2;
    //self.backgroundColor = [UIColor redColor];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    timeDown = [NSDate date];
    if (timer)
    {
        [timer invalidate];
    }
    imageView.alpha = 0.8;
    //self.backgroundColor = [UIColor lightGrayColor];
    //timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showBadge) userInfo:nil repeats:NO];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    imageView.alpha = 1;
    [self open:self];
}

- (void) updateUI
{
    self.tag = 2;
    titleLabel.text = [self.subscription objectForKey:@"name"];
    id notifs = [self.subscription objectForKey:@"notifications"];
    if (!notifs || [notifs isEqual:[NSNull null]])
    {
        badgesIndicator.hidden = YES;
    }
    else
    {
        badgesIndicator.hidden = NO;
        [badgesIndicator setTitle:notifs forState:UIControlStateNormal];
    }
    
    //self.backgroundColor = self.selected ? [UIColor lightGrayColor] : [UIColor clearColor];
    imageView.url = self.imageUrl;
}

@end
