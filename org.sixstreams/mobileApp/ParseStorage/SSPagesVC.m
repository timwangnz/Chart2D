//
//  PageController.m
//  Oracle Daas
//
//  Created by Anping Wang on 10/1/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSPagesVC.h"
#import "DebugLogger.h"

@interface SSPagesVC()
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    
    UIView *parentView;
    NSMutableArray *childPages;
    NSUInteger toPage;
    NSUInteger currentPage;
    BOOL swipeDisabled;
}
@property (strong, nonatomic) id <SSPagesVCDelegate> delegate;

@end



@implementation SSPagesVC


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Page View";
    }
    return self;
}

- (void) dealloc
{
    childPages = nil;
}

- (void) disablesSwipe
{
    swipeDisabled = YES;
}

- (IBAction)pageControlValueChanged:(UIPageControl *)sender
{
    [self setPageTo:sender.currentPage];
}

- (void) reloadPages
{
    scrollView.scrollEnabled = !swipeDisabled;
    NSUInteger pages = [self.delegate numberOfPagesFor:self];
    childPages = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < pages; i++)
    {
        [childPages addObject:[NSNull null]];
    }
    
    CGRect frame = parentView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.view.frame = frame;
    
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(frame.size.width * pages, frame.size.height);// - pageControl.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = YES;
    scrollView.delegate = self;
    scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);// - pageControl.frame.size.height);
    
    pageControl.numberOfPages = pages;
    pageControl.currentPage = 0;
    pageControl.hidden = !self.showPageControl;
    
    for (int i = 0; i< pages; i++)
    {
        [self loadScrollViewWithPage:i];
    }

    [self.delegate pagesVC:self didChangeTo: pageControl.currentPage];
}

- (void) initialize : (UIView *) inView pageDelegate : (id) delegate
{
  //  if(!childPages)
    {
        self.delegate = delegate;
        parentView = inView;
        [self.view removeFromSuperview];
        [parentView addSubview:self.view];
        [parentView sendSubviewToBack:self.view];
        [parentView setNeedsLayout];
    }
}

- (void) setPageTo:(NSUInteger) page
{
    if (page == toPage)
    {
        return;
    }
    
    toPage = page;
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * toPage;
    frame.origin.y = 0;
    pageControl.currentPage = toPage;
    [scrollView scrollRectToVisible:frame animated:YES];
}

-(UIView *)getCurrentPage
{
    return [childPages objectAtIndex:pageControl.currentPage];
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
    {
        return;
    }
    
    if (page >= [childPages count])
    {
        return;
    }
    
    UIView *pageView = [childPages objectAtIndex:page];
    if ((NSNull *)pageView == [NSNull null])
    {
        pageView = [self.delegate pagesVC:self viewAtPage:page];
        [childPages replaceObjectAtIndex:page withObject:pageView];
    }
    
    CGRect frame = scrollView.frame;
    frame.origin.x = self.view.frame.size.width * page;
    frame.origin.y = 0;
    frame.size = scrollView.frame.size;
    pageView.frame = frame;
    [scrollView addSubview:pageView];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    

}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollview
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if(currentPage != page)
    {
        [self setPageTo:page];
    }
    
    [self.delegate pagesVC:self didChangeTo: toPage];
    currentPage = toPage;
}


@end
