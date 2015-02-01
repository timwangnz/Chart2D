//
//  SSContainerVC.m
//  SixStreams
//
//  Created by Anping Wang on 6/9/13.
//  Copyright (c) 2013 SixStreams. All rights reserved.
//

#import "SSContainerVC.h"
#import "SSLayoutVC.h"
#import "SSApp.h"

@interface SSContainerVC ()<SSNavMenuDelegate>
{
    BOOL menuOpen;
    BOOL shouldOpen;
}

- (IBAction)handlePanning: (UIPanGestureRecognizer *)recognizer;

@end

@implementation SSContainerVC

- (void) navMenu:(id)menu itemSelected:(id)item
{
    [self openMenu:item];
    self.mainVC.entity = item;
}

-(IBAction)openMenu:(id)sender
{
    float gap = [self isIPad] ? self.menuVC.view.frame.size.width : self.view.frame.size.width * 4 / 5;
    
    [UIView animateWithDuration: 0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
     
                     animations:^{
                         CGRect rect = self.mainVC.view.frame;
                         if (menuOpen)
                         {
                             rect.origin.x = 0;
                         }
                         else
                         {
                             rect.origin.x = gap;
                         }
                         self.mainVC.view.frame = rect;
                     }
     
                     completion:^(BOOL finished){
                         
                         menuOpen = !menuOpen;
                         
                     }];
}

- (IBAction)handlePanning: (UIPanGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateEnded && shouldOpen)
    {
        [self openMenu:recognizer];
        shouldOpen = NO;
    }
    else
    {
        CGPoint translation = [recognizer translationInView: self.view];
        
        if ((menuOpen && translation.x >= 0)||(!menuOpen && translation.x <= 0)) {
            return;
        }
        
        float mWidth = self.mainVC.view.frame.size.width;
        float mX = self.mainVC.view.center.x;
        float mY = self.mainVC.view.center.y;
        
        
        if ((mX + translation.x) > mWidth / 2 && (mX+ translation.x) < (mWidth* 4 / 5 + mWidth / 2))
        {
            self.mainVC.view.center = CGPointMake(mX + translation.x, mY);
            shouldOpen = YES;
        }
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.mainVC == nil)
    {
        [self setupChildren];
    }
}

- (void)setupChildren
{
    SSMainVC *mainVC = [[SSMainVC alloc] initWithRootViewController:[[SSApp instance] getLayoutVC]] ;
    
    SSNavMenuVC *menuVC = [[SSNavMenuVC alloc] init];
    self.mainVC.view.frame = self.view.frame;
    self.mainVC = mainVC;
    self.menuVC = menuVC;
    self.menuVC.delegate = self;
    
    [self.view addSubview: self.mainVC.view];
    if (self.menuVC)
    {
        [self.menuVC refreshOnSuccess:^(id data) {
            [self addChildViewController:self.menuVC];
            [self.view addSubview:self.menuVC.view];
            [self.view sendSubviewToBack:self.menuVC.view];
            float width = [self isIPad] ? self.menuVC.view.frame.size.width : self.view.frame.size.width;
            self.menuVC.view.frame = CGRectMake(0,20, width , self.view.frame.size.height - 20);
        } onFailure:^(NSError *error) {
            //
        }];
    }
}

@end
