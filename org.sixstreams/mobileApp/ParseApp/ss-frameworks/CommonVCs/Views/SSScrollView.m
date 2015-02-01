//
//  SSScrollView.m
//  Mappuccino
//
//  Created by Anping Wang on 4/21/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSScrollView.h"
@interface SSScrollView()
{
    SSScrollViewCallback createChildCallback;
    NSMutableArray *childViews;
}
@end;

@implementation SSScrollView

- (NSUInteger) numberOfChildViews
{
    return [childViews count];
}

- (void) reset
{
    for (UIView *view in childViews)
    {
        view.hidden = YES;
    }
    //childViews = nil;
}

- (void) addChildView:(UIView *) view
{
    if (!childViews)
    {
        childViews = [NSMutableArray array];
    }
    
    if ([childViews containsObject:view])
    {
        return;
    }
    
    [self addSubview:view];
    [childViews addObject:view];
}

- (void) doLayout
{
    if (self.mode == 0)
    {
        [self doVerticalLayout];
    }
    else{
        [self doHorizotalLayout];
    }
} 

- (void) doVerticalLayout
{
    int vGap = self.vGap == 0 ? 10 : self.vGap;
    int hGap = self.hGap == 0 ? 5 : self.hGap;
    int i = vGap;
    
    for(UIView *item in childViews)
    {
        if(item.hidden)
        {
            continue;
        }

        item.frame = CGRectMake(hGap /2, i , self.frame.size.width - hGap, item.frame.size.height);
        i += vGap /2 + item.frame.size.height;
    }
    [self setContentSize: CGSizeMake(self.frame.size.width, i + vGap)];
}

- (void) doHorizotalLayout
{
    if ([childViews count]==0)
    {
        return;//nothing to do
    }
   
    int hGap = self.hGap == 0 ? 10 : self.hGap;
   // UIView *firstView = [childViews objectAtIndex:0];
   // int vGap = (self.frame.size.height - firstView.frame.size.height) / 2;
  
    int i = hGap /2;
    
    for(UIView *item  in childViews)
    {
        if(item.hidden)
        {
            continue;
        }
        item.frame = CGRectMake(i, item.frame.origin.y, item.frame.size.width, item.frame.size.height);
        i += hGap /2 + item.frame.size.width;
    }
   
    [self setContentSize: CGSizeMake(fmax(self.frame.size.width, i + hGap), self.frame.size.height)];
}

//when user tab on the subview, we will call delegate to handle the event.
- (void)viewTaped:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:0.25
                     animations:^(void){
                        gestureRecognizer.view.alpha = 0.25f;
                     }
     completion:^(BOOL finished) {
         [UIView animateWithDuration:0.25 animations:^(void){
             gestureRecognizer.view.alpha = 1.0f;
         }
        completion:^(BOOL finished) {
            if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(scrollView:didSelectView:)])
            {
                [self.scrollViewDelegate scrollView:self didSelectView:gestureRecognizer.view];
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

- (void) refreshUI
{

    for(UIView *item in childViews)
    {
        if ([[item gestureRecognizers] count] ==0)
        {
            [self addTap:item];
        }
    }
    [self doLayout];
    
}

@end
