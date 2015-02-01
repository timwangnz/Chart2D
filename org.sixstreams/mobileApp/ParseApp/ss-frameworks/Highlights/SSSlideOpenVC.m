//
//  SSSlideOpenVC.m
//  SixStreams
//
//  Created by Anping Wang on 7/30/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSSlideOpenVC.h"
#import "SSSlideView.h"

@interface SSSlideOpenVC ()<SSSlideViewDelegate>
{
    __weak IBOutlet UIView *leftDoorView;
    __weak IBOutlet SSSlideView *rightDoorView;
    BOOL isOpen;
}

@end

@implementation SSSlideOpenVC

- (void) view:(UIView *)view isMoving:(float)percent
{
    DebugLog(@"Moving %f", percent);
    [self openDoor:percent];
}

- (void) view:(UIView *)view moveEnded:(float)percent
{
    DebugLog(@"Ended %f", percent);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    leftDoorView.layer.anchorPoint = CGPointMake(0, 0.5); // hinge around the left edge
    leftDoorView.center = CGPointMake(0.0, self.view.bounds.size.height/2.0); //compensate for anchor offset
    rightDoorView.delegate = self;
    
    rightDoorView.layer.anchorPoint = CGPointMake(1.0, 0.5); // hinge around the right edge
    rightDoorView.center = CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height/2.0); //compensate for anchor offset

    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0f/500;
    leftDoorView.layer.transform = transform;
    rightDoorView.layer.transform = transform;
    
}

- (IBAction)toggleDoor:(id)sender
{
    if (isOpen)
    {
        [self close];
    }
    else{
        [self open];
    }
    isOpen = !isOpen;
}

- (IBAction)open
{
    [UIView animateWithDuration:0.5 animations:^{
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0f/500;
        leftDoorView.layer.transform = CATransform3DRotate(transform, M_PI_2*0.8, 0, 1, 0);
        transform = CATransform3DScale(transform, 0.6, 0.6, 1.0);
        rightDoorView.layer.transform = CATransform3DRotate(transform, -M_PI_2*0.8, 0, 1, 0);
    }];
}

- (void)openDoor:(float) percent
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0f/500;
    
    transform = CATransform3DScale(transform, 0.6*(2-percent), 0.6*(2-percent), 1.0);
    rightDoorView.layer.transform = CATransform3DRotate(transform, -M_PI_2*0.8*percent, 0, 1, 0);
    
}

- (IBAction)close
{
    [UIView animateWithDuration:0.5 animations:^{
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0f/500;
        leftDoorView.layer.transform = transform;
        rightDoorView.layer.transform = transform;
    }];
}


@end
