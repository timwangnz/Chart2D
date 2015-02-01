//
//  SSHightlightsVC.m
//  SixStreams
//
//  Created by Anping Wang on 5/14/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSHighlightsVC.h"
#import "SSPagesVC.h"
#import "iCarousel.h"
#import "SSImageView.h"
#import "SSApp.h"
#import "SSFilter.h"
#import "SSSpotlightView.h"
#import "SSProfileEditorVC.h"
#import "SSProfileVC.h"
#import "SSShadowView.h"
#import "SSMenuVC.h"
#import "SSValueField.h"
#import "SSStorageManager.h"

@interface SSHighlightsVC ()<iCarouselDataSource, iCarouselDelegate, SSPagesVCDelegate, SSImageViewDelegate, SSSpotlightViewDelegate>
{
    IBOutlet SSShadowView *pagesContainer;
    
    IBOutlet UIView *headerView;
    IBOutlet UIView *highlightsView;
    
    IBOutlet UIView *deckViewContainer;
    
    IBOutlet SSPagesVC *pagesVC;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *detailLabel;
    NSMutableArray *detailsViews;
    NSMutableArray *categoryViews;
    
    
    IBOutlet iCarousel *detailCarousel;
    NSInteger currentPage;
    UITapGestureRecognizer *tapGesture;
    NSTimer *timer;
    int animationIdx;
    
    UIViewController *popupVC;
    UIGestureRecognizer *myGestureRec;
    
    NSArray *presetFitlers;
}

@end

@implementation SSHighlightsVC

#define FILTERS_KEY @"hightsfilters"

static int ITEM_WIDTH = 130;


- (void) setupInitialValues
{
    [super setupInitialValues];
    self.title = [[SSApp instance] name];
    
    detailsViews=[NSMutableArray array];
    self.tabBarItem.image = [UIImage imageNamed:@"mind_map-32.png"];
    self.addable = NO;
    self.showBusyIndicator = NO;
    self.limit = 40;
    self.queryPrefixKey = TITLE;
    self.orderBy = CREATED_AT;
    self.ascending = NO;
    
    categoryViews = [NSMutableArray array];
    
    if (self.categories == 0)
    {
        self.categories = 1;
    }
    
    for(int i = 0; i< self.categories; i++)
    {
        SSImageView *eventsView =[[SSImageView alloc]init];
        eventsView.contentMode = UIViewContentModeScaleAspectFill;
        [categoryViews addObject:eventsView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture
{
    return YES;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    currentPage = -1;
    self.categories = 1;
    [pagesVC initialize:pagesContainer pageDelegate:self];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(currentPage == -1)
    {
        if (self.predicates)
        {
            presetFitlers = [NSArray arrayWithArray:self.predicates];
        }
        
        [self refreshOnSuccess:^(id data) {
            self.navigationController.navigationBar.hidden = YES;
            currentPage = 0;
            [pagesVC reloadPages];
            [self headview];
            [self refreshUI];
        } onFailure:^(NSError *error) {
            //
        }];
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.view layoutIfNeeded];
    
}

- (NSUInteger) numberOfPagesFor: (SSPagesVC* )pageControl
{
    return [categoryViews count];
}

- (UIView *) pagesVC:(SSPagesVC* ) pageControl viewAtPage:(NSUInteger ) page
{
    return [categoryViews objectAtIndex:page];
}

- (void) pagesVC:(id)pageControl didChangeTo :(NSUInteger) page
{
    if (currentPage == page) {
        return;
    }
    currentPage = page;
}

- (void) onDataReceived:(id) objects
{
    [super onDataReceived:objects];
    for(UIView *view in detailsViews)
    {
        [view removeFromSuperview];
    }
    
    [detailsViews removeAllObjects];
    
    for (id item in objects)
    {
        CGRect rect = CGRectMake(0, 0, ITEM_WIDTH, [self isIPad] ? 120 + ITEM_WIDTH : 2 * ITEM_WIDTH);
        SSSpotlightView *eventView =[[SSSpotlightView alloc]initWithFrame:rect];
        eventView.entityType = self.objectType;
        
        eventView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        eventView.entity = item;
        eventView.delegate = self;
        //eventView.cornerRadius = 0;
        [detailsViews addObject:eventView];
        [eventView refreshUI];
    }
    
    if(currentPage < 0)
    {
        currentPage = 0;
        [pagesVC reloadPages];
    }
    
    if ([detailsViews count] > 0 && currentPage >=0) {
        SSImageView *categoryView = categoryViews[currentPage];
        categoryView.delegate = self;
        
        categoryView.frame = pagesContainer.bounds;
        categoryView.cornerRadius = 0;
        SSSpotlightView *eventView =detailsViews[0];
        categoryView.owner = [eventView getImageView].owner;
        categoryView.url = [eventView getImageView].url;
        categoryView.backupUrl = [eventView getImageView].backupUrl;
    }
    
    detailCarousel.type = iCarouselTypeLinear;
    [detailCarousel reloadData];
    
    [detailCarousel scrollToItemAtIndex:[detailsViews count] animated:YES];
    [detailCarousel scrollToItemAtIndex:1 animated:YES];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    
    tapGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
    
    [pagesContainer addGestureRecognizer:tapGesture];
    currentPage = 0;
}

- (void) headview
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = headerView.bounds;
    
    UIColor *from = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.3];
    UIColor *middle = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:.2];
    UIColor *to = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.05];
    UIColor *last = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.0];
    
    gradient.colors = [NSArray arrayWithObjects:(id)[from CGColor], (id)[middle CGColor], (id)[to CGColor], (id)[last CGColor], nil];
    [headerView.layer insertSublayer:gradient atIndex:0];
}

- (void) imageView:(id) imageView didLoadImage:(id) image
{
    animationIdx = 0;
    [self animate];
    [self startAnimation];
}

- (void) startAnimation
{
    if (timer)
    {
        [timer invalidate];
    }
    SSImageView *categoryView = categoryViews[currentPage];
    categoryView.transitionDuration = 2;
    if (_animationInterval == 0)
    {
        _animationInterval = 5;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:_animationInterval target:self selector:@selector(animate) userInfo:nil repeats:YES];
}

- (void) dismissPopup:(id) sender
{
    [popupVC dismissViewControllerAnimated:YES completion:nil];
    popupVC = nil;
}

- (void) selectEntity : (NSInteger) index
{
    if(index < 0 || index >= [detailsViews count])
    {
        return;
    }
    SSSpotlightView *eventView =detailsViews[index];
    SSEntityEditorVC *entityEditor = [[SSApp instance] entityVCFor:eventView.entityType];
    entityEditor.item2Edit = eventView.entity;
    entityEditor.readonly = YES;
    entityEditor.itemType = eventView.entityType;
    entityEditor.view.tag = 1;
    [self showVC:entityEditor];
}

- (void) view:(SSSpotlightView *)view didSelect:(id)event
{
    SSEntityEditorVC *entityEditor = [[SSApp instance] entityVCFor:view.entityType];
    entityEditor.item2Edit = view.entity;
    entityEditor.readonly = YES;
    entityEditor.itemType = view.entityType;
    entityEditor.view.tag = 1;
    [self showVC:entityEditor];
}

- (void) showVC : (UIViewController *) vc
{
    if (self.navigationController)
    {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: @""
                                       style: UIBarButtonItemStyleBordered
                                       target: nil action: nil];
        
        [self.navigationItem setBackBarButtonItem: backButton];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        popupVC = [[UINavigationController alloc]initWithRootViewController:vc];
        [self showPopup:popupVC sender:self];
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [vc.view addGestureRecognizer:recognizer];
        recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [vc.view addGestureRecognizer:recognizer];
    }
}

- (void) didPan:(UITapGestureRecognizer *)aTapGesture
{
    [self dismissPopup:self];
}

- (void) didTap:(UITapGestureRecognizer *)aTapGesture
{
    if (aTapGesture == tapGesture)
    {
        [self selectEntity:animationIdx - 1];
    }
}

- (void) animate
{
    if ([detailsViews count]==0) {
        return;
    }
    
    if(animationIdx > [detailsViews count] - 1)
    {
        animationIdx = 0;
    }
    
    SSImageView *icon = nil;
    
    SSSpotlightView *view = detailsViews[animationIdx++];
    id item = view.entity;
    
    NSString *newText = [[SSApp instance] highlightTitle: item forCategory:currentPage];
    NSString *detailsText = [[SSApp instance] highlightSubtitle: item forCategory:currentPage];
    
    icon = [view getImageView];
    if (icon.image)
    {
        SSImageView *categoryView = categoryViews[currentPage];
        [categoryView changeImage:icon.image];
    }
    [UIView animateWithDuration:0.5 animations:^{
        headerView.alpha  = 1;
        headerView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            headerView.alpha  = 0;
            titleLabel.text = detailsText;
            detailLabel.text = newText;
            headerView.alpha  = 1;
            
        }];
    }];
}

- (NSArray *) getItemViews
{
    return detailsViews;
}

#pragma iCarousel

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index
{
    return YES;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [self selectEntity: index];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [detailsViews count];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * (carousel == detailCarousel ? 1.01f : 1.0f);
    }
    if (option == iCarouselOptionOffsetMultiplier)
    {
        return 1;
    }
    return value;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIView *label = nil;
    
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ITEM_WIDTH, 2*ITEM_WIDTH)];
        ((UIImageView *)view).image = [UIImage imageNamed:@"browser03_bg-school"];
        view.contentMode = UIViewContentModeCenter;
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        label.tag = carousel.tag;;
        [view addSubview:label];
    }
    else
    {
        label = (UILabel *)[view viewWithTag:carousel.tag];
    }
    UIView *childView = [detailsViews objectAtIndex:index];
    [childView setUserInteractionEnabled:YES];
    [childView removeFromSuperview];
    [label addSubview:childView];
    return view;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
