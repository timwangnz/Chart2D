//
// AppliaticsMainVC.m
//  SyncClientSample
//
//  Created by Anping Wang on 3/11/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSMainVC.h"
#import "SSConnection.h"
#import "SSLayoutVC.h"

@interface SSMainVC()
{
    SSLayoutVC *contentVC;
}

@end

@implementation SSMainVC

- (id) initWithRootViewController:(UIViewController *)rootViewController
{
    contentVC = (SSLayoutVC*) rootViewController;
    return [super initWithRootViewController:rootViewController];
}

- (void) setEntity:(id)entity
{
    _entity = entity;
    [self popToRootViewControllerAnimated:NO];
    contentVC.entity = entity;
}

@end
