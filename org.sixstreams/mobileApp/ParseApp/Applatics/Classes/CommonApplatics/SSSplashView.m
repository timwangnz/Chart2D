//
// AppliaticsSplashView.m
// Appliatics
//
//  Created by Anping Wang on 9/27/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSSplashView.h"
#import "SSRoundView.h"
#import "SSRoundLabel.h"

@interface SSSplashView()
{
    UIView *splashView;
    UIView *roundBack;
    UIView *parentView;
}

@end

@implementation SSSplashView

- (void) hide:(CompleteHide) complete
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
       [self hideme];
       complete();
    });
}

- (void) hideme
{
    
    [splashView removeFromSuperview];
    [roundBack removeFromSuperview];
    splashView = nil;
    roundBack= nil;
}

- (void) showInView:(UIView *) view
{
    parentView = view;
    splashView = [[UIView alloc] initWithFrame: parentView.frame];
    splashView.center = CGPointMake(parentView.frame.size.width/2, parentView.frame.size.height/2);
    
    [parentView addSubview:splashView];
    [parentView bringSubviewToFront:splashView];
    splashView.backgroundColor = self.background ? self.background : [UIColor grayColor];
    splashView.alpha = 0.5;
    
    roundBack = [[SSRoundView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    roundBack.tag = 5;
    roundBack.center = CGPointMake(splashView.center.x - self.x, splashView.center.y - self.y);
    
    roundBack.backgroundColor = self.color ? self.color : [UIColor redColor];
    [parentView addSubview:roundBack];
    [parentView bringSubviewToFront:roundBack];
    
    //Create and add the Activity Indicator to splashView
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(100,100);
    activityIndicator.hidesWhenStopped = NO;
    [roundBack addSubview:activityIndicator];
    if (self.title)
    {
        UILabel *title = [[SSRoundLabel alloc]initWithFrame:CGRectMake(10,170,180,20)];
        title.text = self.title;
        title.backgroundColor = [UIColor lightGrayColor];
        title.textAlignment = NSTextAlignmentCenter;
        [roundBack addSubview:title];
    }
    [activityIndicator startAnimating];
    
}

@end
