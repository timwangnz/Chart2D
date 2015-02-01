//
//  SSQnAVC.m
//  Medistory
//
//  Created by Anping Wang on 9/24/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSSplitsModelVC.h"
#import "SSSecurityVC.h"

@interface SSSplitsModelVC (){
    
    IBOutlet UIView *splitsView;
    IBOutlet UIView *eventView;
    IBOutlet UIView *swimmerProfile;
}



@end

@implementation SSSplitsModelVC

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
