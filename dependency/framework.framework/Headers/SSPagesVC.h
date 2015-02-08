//
//  PageController.h
//  Oracle Daas
//
//  Created by Anping Wang on 10/1/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> 
@class SSPagesVC;

@protocol SSPagesVCDelegate <NSObject>
@required
- (NSUInteger) numberOfPagesFor: (SSPagesVC *) pageControl;
- (UIView *) pagesVC:(SSPagesVC *) pageControl viewAtPage:(NSUInteger ) page;
- (void) pagesVC:(SSPagesVC *) pageControl didChangeTo :(NSUInteger) page;
@end

@interface SSPagesVC : UIViewController<UIScrollViewDelegate>

@property BOOL showPageControl;

- (void) setPageTo:(NSUInteger) page;
- (void) initialize : (UIView *) parentView pageDelegate : (id) delegate;

- (UIView *) getCurrentPage;

- (void) reloadPages;
- (IBAction) pageControlValueChanged:(UIPageControl*)sender;
- (void) disablesSwipe;

@end
