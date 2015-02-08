//
//  SSSpotlightView.m
//  SixStreams
//
//  Created by Anping Wang on 5/14/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSDeckView.h"
#import "SSApp.h"
#import "SixStreams.h"
#import "SSImagesVC.h"

@interface SSDeckView()
{
    UIView *spotlightView;
    CGPoint startPoint;
    CGPoint startCenter;
    CGPoint superviewCenter;
    UILabel *like, *dislike;
    BOOL swiping;
    BOOL movingParent;
    BOOL superviewCentered;
    float startY;
}
@end

@implementation SSDeckView


- (id) initWithEntity:(id) entity
{
    self = [super init];
    if (self)
    {
        self.entity = entity;
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CALayer *layer = self.layer;
    layer.cornerRadius = 0;
    layer.masksToBounds = YES;
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    [super drawRect: rect];
    CGContextRestoreGState(currentContext);
}

- (void) cleanupUI
{
    [spotlightView removeFromSuperview];
}

- (UIView *) getSpotlightView
{
    return spotlightView;
}

- (void) setupUI
{
    self.clipsToBounds = YES;
    int size = self.frame.size.width;
    spotlightView = [[SSApp instance] spotlightView:self.entity ofType:self.entityType];
    spotlightView.frame = CGRectMake(0, 0, size, self.frame.size.height);
    [self addSubview:spotlightView];
    [self sendSubviewToBack:spotlightView];
    
    like = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 120, 40)];
    like.textColor = [UIColor greenColor];
    like.textAlignment = NSTextAlignmentRight;
    like.font = [UIFont boldSystemFontOfSize:30];
    [self addSubview:like];
    
    like.text = self.likeText;
    like.alpha = 0;
   
    dislike = [[UILabel alloc]initWithFrame:CGRectMake(size - 120 - 10, 20, 120, 40)];
    dislike.textColor = [UIColor redColor];
    dislike.text = self.dislikeText;
    dislike.font = [UIFont boldSystemFontOfSize:30];
    [self addSubview:dislike];
    
    dislike.alpha = 0;
}

- (void) refreshUI
{
    for (UIView *childView in [self subviews])
    {
        [childView removeFromSuperview];
    }
    
    
    UIView *inView = self;
    
    int size = self.frame.size.width;
    inView = [[UIView alloc]initWithFrame:CGRectMake(0, size, size, 40)];
    [self addSubview:inView];
    
    
    [[SSApp instance] updateHighlightItem:self.entity ofType:self.entityType inView:inView];
    startCenter = self.center;
    [self setupUI];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    
    startPoint= [touch locationInView:self.superview];
    startY = self.superview.frame.origin.y;
    swiping = NO;
    if(!superviewCentered)
    {
        superviewCenter = self.superview.center;
        superviewCentered = YES;
    }
}
#define TOUCH_CIRCLE_SIZE 20.0
#define SWIPE_CIRCLE_SIZE 10.0
#define DegreesToRadians(x) ((x) * M_PI / 180.0)

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint currentPoint= [touch locationInView:self.superview];
    
    float dx = currentPoint.x - startPoint.x;
    float dy = currentPoint.y - startPoint.y;
    
    if (fabs(dx) > SWIPE_CIRCLE_SIZE && !movingParent && startY ==0)
    {
        swiping = YES;
        self.center = CGPointMake(startCenter.x + dx, startCenter.y + 0.2 * dy);
        self.transform = CGAffineTransformMakeRotation(DegreesToRadians(0.05 * dx));
        if (dx < 0)
        {
            dislike.alpha = 2*(self.frame.size.width/2 - self.center.x) / self.frame.size.width;
            like.alpha = 0;
        }
        if (dx > 0)
        {
            like.alpha = 2*(self.center.x - self.frame.size.width/2) / self.frame.size.width;
            dislike.alpha = 0;
        }
        movingParent = NO;
    }
    else if (((dy < TOUCH_CIRCLE_SIZE && startY > 0) || (dy > TOUCH_CIRCLE_SIZE && startY == 0)) && !swiping)
    {
        movingParent = YES;
        //self.superview.center = CGPointMake(self.superview.center.x, self.superview.center.y + dy);
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(view:isMoving:)])
    {
        [self.delegate view:self isMoving:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint currentPoint= [touch locationInView:self.superview];
    float dx = currentPoint.x - startPoint.x;
    float dy = currentPoint.y - startPoint.y;
    
    if (!swiping && fabs(dx) < TOUCH_CIRCLE_SIZE && fabs(dy) < TOUCH_CIRCLE_SIZE && startY ==0 && !movingParent)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(view:didSelect:)])
        {
            [self.delegate view:self didSelect:event];
            return;
        }
    }
    
    if (fabs(dx) < 100 || movingParent)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.center = startCenter;
            self.alpha = 1;
            
            self.transform = CGAffineTransformMakeRotation(DegreesToRadians(0.0));
            /*
            if(!swiping)
            {
                if (startY == 0)
                {
                    if (dy < 0)
                    {
                       //
                    }
                    else
                    {
                        self.superview.center =  CGPointMake(superviewCenter.x,  3 * superviewCenter.y - 80);
                    }
                }
                else{
                    self.superview.center = superviewCenter;
                }
            }
            */
            like.alpha = dislike.alpha = 0;
            movingParent = NO;
            swiping = NO;
        } completion:^(BOOL finished) {
            if([self.delegate respondsToSelector:@selector(view:didFinishMoving:)])
            {
                [self.delegate view:self didFinishMoving:event];
            }

        }];
    }
    else
    {
        swiping = NO;
        if(dx < 0 && [self.delegate respondsToSelector:@selector(view:didSwipeLeft:)])
        {
            [self.delegate view:self didSwipeLeft:event];
        }
        else if(dx > 0 && [self.delegate respondsToSelector:@selector(view:didSwipeRight:)])
        {
            [self.delegate view:self didSwipeRight:event];
        }
    }
}

- (void) underDeck
{
    [self.superview sendSubviewToBack:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.center = startCenter;
        self.alpha = 1;
        like.alpha = dislike.alpha = 0;
        self.transform = CGAffineTransformMakeRotation(DegreesToRadians(0.0));
    } completion:^(BOOL finished) {
        
    }];
}

- (void) vote:(BOOL) vote
{
    float dx = vote ? 200 : -200;
    float dy = 10;
    like.alpha = dislike.alpha = 0;
    startCenter = self.center;

    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
        like.alpha = vote ? 1 : 0;
        dislike.alpha = 1 - like.alpha;
        self.center = CGPointMake(startCenter.x + dx, startCenter.y + dy);
        self.transform = CGAffineTransformMakeRotation(DegreesToRadians(0.05*dx));
        
    } completion:^(BOOL finished) {
        if(vote && [self.delegate respondsToSelector:@selector(view:didSwipeLeft:)])
        {
            [self.delegate view:self didSwipeLeft:nil];
        }
        else if(!vote &&  [self.delegate respondsToSelector:@selector(view:didSwipeRight:)])
        {
            [self.delegate view:self didSwipeRight:nil];
        }
    }
     ];
}

@end
