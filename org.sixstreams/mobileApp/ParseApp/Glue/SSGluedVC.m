//
//  SSGluedVC.m
//  SixStreams
//
//  Created by Anping Wang on 12/28/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSGluedVC.h"
#import "SSFilter.h"
#import "SSMeetupEditorVC.h"
#import "iCarousel.h"
#import "SSEventVC.h"
#import "SSEventView.h"
#import "SSSecurityVC.h"
#import "SSProfileVC.h"
#import "SSImageView.h"
#import "SSProfileEditorVC.h"
#import "SSPagesVC.h"
#import "SSEventView.h"

@interface SSGluedVC ()<iCarouselDataSource, iCarouselDelegate, SSPagesVCDelegate, SSImageViewDelegate,SSEventViewDelegate>
{
     IBOutlet UILabel *focusLabel;
     IBOutlet UIView *pagesContainer;
     IBOutlet SSPagesVC *pagesCV;
     NSMutableArray *detailsViews;
     NSMutableArray *categoryViews;
     IBOutlet iCarousel *detailCarousel;
     int topVisibleIndex;
     UIView *viewHolder;
     NSUInteger currentPage;
     NSTimer *timer;
     int animationIdx;
     UITapGestureRecognizer *tapGesture;
     BOOL isUpview; //inidicate a touch on the top image
}

-  (IBAction)setCategory:(UIButton *)sender;

@end

@implementation SSGluedVC

-  (IBAction)setCategory:(UIButton *)sender
{
     [pagesCV setPageTo:sender.tag];
}

- (void) setupInitialValues
{
     [super setupInitialValues];
     self.objectType = FILE_CLASS;
     //self.tableColumns = 1;
     self.title = @"Glue";
     detailsViews=[NSMutableArray array];
     self.tabBarItem.image = [UIImage imageNamed:@"mind_map-32.png"];
     self.addable = NO;
     
     self.limit = 40;
     self.queryPrefixKey = TITLE;
     self.orderBy = CREATED_AT;
     self.ascending = NO;
     
     [self.predicates removeAllObjects];
     [self.predicates addObject:[SSFilter on:RELATED_TYPE op:EQ value: MEETING_CLASS]];
     categoryViews = [NSMutableArray array];
     //
     for(int i = 0; i< 2; i++)
     {
          SSImageView *eventsView =[[SSImageView alloc]initWithFrame:pagesContainer.frame];
          [eventsView changeImage:[UIImage imageNamed:[NSString stringWithFormat:@"sub03_0%d", i+1]]];
          [categoryViews addObject:eventsView];
     }
     
}

- (SSEntityEditorVC *) createEditorFor:(id) item
{
     SSEntityEditorVC *entityEditor = [[SSMeetupEditorVC alloc]init];
     entityEditor.itemType = self.objectType;
     [entityEditor updateEntity:item OfType: MEETING_CLASS];
     if(item)
     {
          entityEditor.readonly = YES;
          entityEditor.title = @"Meeting";
     }
     return entityEditor;
}

#pragma view lifecycle
- (void) viewDidLoad
{
     [super viewDidLoad];
     
     currentPage = -1;
     [pagesCV initialize:pagesContainer pageDelegate:self];
}

- (void) viewWillAppear:(BOOL)animated
{
     if(currentPage == -1)
     {
          [super viewWillAppear:animated];
          [pagesCV reloadPages];
          
     }
     self.navigationController.navigationBar.hidden = YES;
}

#pragma page control
 

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
     
     if(page == 0)
     {
          self.objectType = FILE_CLASS;
          [self.predicates removeAllObjects];
          [self.predicates addObject:[SSFilter on:RELATED_TYPE op:EQ value: MEETING_CLASS]];
     }
     else if(page == 1)
     {
          self.objectType = MEETING_CLASS;
          [self.predicates removeAllObjects];
          [self.predicates addObject:[SSFilter on:SPOT_LIGHTS op:EQ value: [NSNumber numberWithBool:YES]]];
     }
     currentPage = page;
     [self forceRefresh];
}

//reload different data
- (void) imageView:(id)imageView didLoadImage:(id)image
{
     if ([detailsViews count] > 0 && imageView == detailsViews[0]) {
          SSImageView *categoryView = categoryViews[currentPage];
          [categoryView changeImage:image];
     }
}

- (void) onDataReceived:(id) objects
{
     [super onDataReceived:objects];
     
     
     for(UIView *view in detailsViews)
     {
          [view removeFromSuperview];
     }
     
     [detailsViews removeAllObjects];
     
     if([self.objectType isEqualToString:FILE_CLASS])
     {
          int i = 0;
          for (id item in objects)
          {
               SSImageView *eventsView =[[SSImageView alloc]initWithFrame:CGRectMake(2, (i++%2)*ITEM_WIDTH + 2, ITEM_WIDTH - 4, ITEM_WIDTH - 4)];
               eventsView.info = item;
               eventsView.delegate = self;
               [detailsViews addObject:eventsView];
                eventsView.url = item[REF_ID_NAME];
            }
     } else
     {
          for (id item in objects)
          {
               SSEventView *eventView =[[SSEventView alloc]initWithFrame:CGRectMake(0, 0, ITEM_WIDTH, 2*ITEM_WIDTH)];
               eventView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
               eventView.event = item;
               eventView.delegate = self;
               [detailsViews addObject:eventView];
               [eventView refreshUI];
          }
          
          if ([detailsViews count] > 0) {
               SSImageView *categoryView = categoryViews[currentPage];
               SSEventView *eventView =detailsViews[0];
               categoryView.owner = [eventView getImageVew].owner;
               categoryView.url = [eventView getImageVew].url;
               categoryView.backupUrl = [eventView getImageVew].backupUrl;
          }
     }
     
     detailCarousel.type = iCarouselTypeLinear;
     [detailCarousel reloadData];
     [detailCarousel scrollToItemAtIndex:[detailsViews count] animated:YES];
     [detailCarousel scrollToItemAtIndex:1 animated:YES];
     
     tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
     tapGesture.delegate = (id <UIGestureRecognizerDelegate>)self;
     for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
          [self.view removeGestureRecognizer:recognizer];
     }
     [self.view addGestureRecognizer:tapGesture];
     [self startAnimation];
}


- (void) eventView:(id)eventView didSelect:(id)event
{
     SSMeetupEditorVC * meetVC = [[SSMeetupEditorVC alloc]init];
     meetVC.readonly = YES;
     [meetVC updateEntity:event OfType:MEETING_CLASS];
     meetVC.title = [event objectForKey:TITLE];
     [self.navigationController pushViewController:meetVC animated:YES];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(UITouch *)touch
{
     return gesture == tapGesture;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
     return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gesture
{
     return gesture == tapGesture;
}

- (void) didTap:(UITapGestureRecognizer *)aTapGesture
{
     if (aTapGesture == tapGesture)
     {
          CGPoint p = [aTapGesture locationInView:self.view];
          isUpview = p.y > 420;
          if (p.y < 319)
          {
               [self selectEvent:animationIdx - 1];
          }
     }
}

- (void) animate
{
    if ([detailsViews count]==0) {
        return;
    }
    
    NSString *newText = nil;
    
    if(animationIdx > [detailsViews count] - 1)
    {
        animationIdx = 0;
    }
    SSImageView *icon = detailsViews[animationIdx++];
    if([icon isKindOfClass:[SSEventView class]])
    {
        newText = [((SSEventView *) icon).event objectForKey:TITLE];
        icon = [((SSEventView *) icon) getImageVew];
    }
    
    if (icon.image)
    {
        SSImageView *categoryView = categoryViews[currentPage];
        [categoryView changeImage:icon.image];
    }
    
    [UIView animateWithDuration:1 animations:^{
        focusLabel.alpha  = 1;
        focusLabel.text = focusLabel.text;
        focusLabel.alpha  = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            focusLabel.alpha  = 0;
            focusLabel.text = newText;
            focusLabel.alpha  = 1;
        }];
    }];
    
}

- (void) startAnimation
{
     animationIdx = 0;
     if (timer)
     {
          [timer invalidate];
     }
     SSImageView *categoryView = categoryViews[currentPage];
     categoryView.transitionDuration = 2;
     timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self
                                       selector:@selector(animate)
                                       userInfo:nil repeats:YES];
}

- (void) selectEvent : (int) index
{
     if(![self.objectType isEqualToString:FILE_CLASS])
     {
          id event = [self.objects objectAtIndex:index];
          SSMeetupEditorVC * meetVC = [[SSMeetupEditorVC alloc]init];
          meetVC.readonly = YES;
          
          [meetVC updateEntity:event OfType:MEETING_CLASS];
          meetVC.title = [event objectForKey:TITLE];
          [self.navigationController pushViewController:meetVC animated:YES];
     }
     else{
          id file = [self.objects objectAtIndex:index];
          NSString *eventId = [file objectForKey:RELATED_ID];
          __block SSMeetupEditorVC *meetVC;
          
          [self getObject:eventId objectType:MEETING_CLASS OnSuccess:^(id data) {
               meetVC = [[SSMeetupEditorVC alloc]init];
               meetVC.readonly = YES;
               
               [meetVC updateEntity:data OfType:MEETING_CLASS];
               meetVC.title = [data objectForKey:TITLE];
               [self.navigationController pushViewController:meetVC animated:YES];
          } onFailure:^(NSError *error)
           {
                DebugLog(@"%@", error);
           }];
          
     }
}

#pragma iCarousel
static int ITEM_WIDTH = 109;
- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index
{
     return YES;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
     [self selectEvent:[self.objectType isEqualToString:FILE_CLASS] ? (2*index + (isUpview ? 1 : 0)) : index];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
     return [self.objectType isEqualToString:FILE_CLASS] ? [detailsViews count] / 2 : [detailsViews count];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
     if (option == iCarouselOptionSpacing)
     {
          return value * (carousel == detailCarousel ? 1.01f : 1.0f);
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
     
     if(![self.objectType isEqualToString:FILE_CLASS] )
     {
          UIView *childView = [detailsViews objectAtIndex:index];
          [childView setUserInteractionEnabled:YES];
          [childView removeFromSuperview];
          [label addSubview:childView];
     } else
     {
          UIView *childView = [detailsViews objectAtIndex:2*index];
          [childView removeFromSuperview];
          [label addSubview:childView];
          childView = [detailsViews objectAtIndex:2*index + 1];
          [childView removeFromSuperview];
          [label addSubview:childView];

     }
     return view;
}

- (BOOL)prefersStatusBarHidden {
     return YES;
}
@end
