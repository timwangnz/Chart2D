//
//  SSQnAVC.m
//  ;
//
//  Created by Anping Wang on 9/24/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSDeviceTrackerVC.h"
#import "SSSecurityVC.h"
#import "SSImageView.h"

@interface SSDeviceTrackerVC ()<SSImageViewDelegate, UIScrollViewDelegate>{
    
    IBOutlet UIView *swimmerProfile;
    IBOutlet UILabel *textLabel;
    IBOutlet UITapGestureRecognizer *tapRecongnizer;
    IBOutlet UIScrollView *scrollView;
    NSMutableArray *points;
    CGFloat distance;
    IBOutlet UIView *view1, *view2;
    CGRect initalRect;
}

@end

@implementation SSDeviceTrackerVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetZoom];
}
- (void) viewDidLoad
{
    [super viewDidLoad];
    initalRect = iconView.frame;
    view1.layer.cornerRadius = 2;
    view2.layer.cornerRadius = 2;
    scrollView.minimumZoomScale = 0.5;
    scrollView.maximumZoomScale = 6.0;
    scrollView.delegate = self;
    [view1 removeFromSuperview];
    [view2 removeFromSuperview];
    [iconView addSubview:view1];
    [iconView addSubview:view2];
   // [self resetZoom];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return iconView;
}

- (void) setLocations
{
    if (points.count <=1)
    {
        return;
    }
    NSValue *vP1 = points[0];
    CGPoint p1 = vP1.CGPointValue;
    NSValue *vP2 = points[1];
    CGPoint p2 = vP2.CGPointValue;
    view1.center = p1;
    view2.center = p2;
    
    view1.hidden = view2.hidden = NO;
}

- (IBAction)pickPoint:(id)sender
{
    UITapGestureRecognizer *rec = sender;
    CGPoint pt = [rec locationInView:iconView];
    NSValue *vPt = [NSValue valueWithCGPoint:pt];
    if (points.count <= 1) {
        [points addObject:vPt];
    }
    else{
        points[1] = vPt;
    }
    
    if (points.count == 2)
    {
        NSValue *vP1 = points[0];
        CGPoint p1 = vP1.CGPointValue;
        NSValue *vP2 = points[1];
        CGPoint p2 = vP2.CGPointValue;
        CGFloat xDist = (p2.x - p1.x);
        CGFloat yDist = (p2.y - p1.y);
        distance = sqrt((xDist * xDist) + (yDist * yDist));
    }
    [self setLocations];
    textLabel.text = [NSString stringWithFormat:@"%.2f", distance];
}

- (IBAction)changeMode:(id)sender
{
    tapRecongnizer.enabled = !tapRecongnizer.enabled;
}

- (IBAction)clearPoints:(id)sender
{
    points = [[NSMutableArray alloc]init];
    textLabel.text = @"";
    view1.hidden = view2.hidden = YES;
}

- (IBAction) resetZoom
{
    scrollView.zoomScale = 1.0;
}

- (void) uiWillUpdate:(id)object
{
    layoutTable.flow = YES;
    tapRecongnizer.enabled = NO;
    points = [[NSMutableArray alloc]init];
    [layoutTable addChildView:swimmerProfile];
    [self linkEditFields];
}
@end
