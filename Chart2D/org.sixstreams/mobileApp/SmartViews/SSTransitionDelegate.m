//
//  SSTransitionDelegate.m
//  SixStreams
//
//  Created by Anping Wang on 5/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSTransitionDelegate.h"
#import "SSTransitionStrategy.h"

@implementation SSTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    SSTransitionStrategy *transitioning = [[SSTransitionStrategy alloc]init];
    return transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    SSTransitionStrategy *transitioning = [[SSTransitionStrategy alloc]init];
    transitioning.reverse = YES;
    return transitioning;
}

@end
