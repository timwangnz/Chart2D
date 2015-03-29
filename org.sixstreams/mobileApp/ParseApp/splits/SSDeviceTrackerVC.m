//
//  SSQnAVC.m
//  Medistory
//
//  Created by Anping Wang on 9/24/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSDeviceTrackerVC.h"
#import "SSSecurityVC.h"

@interface SSDeviceTrackerVC (){
    
    IBOutlet UIView *splitsView;
    IBOutlet UIView *eventView;
    IBOutlet UIView *swimmerProfile;
}



@end

@implementation SSDeviceTrackerVC

- (IBAction)nextStep:(id)sender
{
    [layoutTable nextStep];
}

- (void) uiWillUpdate:(id)object
{
    layoutTable.flow = YES;
    [layoutTable addChildView:swimmerProfile];
    [layoutTable addChildView:eventView];
    [layoutTable addChildView:splitsView];
    [layoutTable disablesSwipe];
    [self linkEditFields];
}


@end
