//
//  SSScrollView.m
//  SixStreams
//
//  Created by Anping Wang on 4/21/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSScrollView.h"
@interface SSScrollView()
{
    SSScrollViewCallback createChildCallback;
    NSMutableArray *newChildViews;
    NSMutableArray *childViews;
    NSMutableArray *dataObjects;
    
    NSDictionary *result;
    NSMutableArray *facets;
}
@end;

@implementation SSScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.offset = 0;
        self.pageSize = 20;
        self.queryString = @"*";
        self.orderBy = @"dateCreated,desc";
    }
    return self;
}

- (NSUInteger) numberOfChildViews
{
    return [childViews count];
}

- (void) clearAll
{
    for (UIView *view in childViews)
    {
        [view removeFromSuperview];
    }
    dataObjects = nil;
    childViews = nil;
}

- (void) addChildView:(UIView *) view
{
    if (!newChildViews)
    {
        newChildViews = [NSMutableArray array];
    }
    if (!childViews)
    {
        childViews = [NSMutableArray array];
    }
    if ([childViews containsObject:view])
    {
        return;
    }
    [self addSubview:view];
    [newChildViews addObject:view];
}

- (void) doLayout
{
    if (self.mode == 0)
    {
        [self doVerticalLayout];
    }
    else{
        [self doHorizotalLayout];
    }
}

- (void) doVerticalLayout
{
    int vGap = 5;
    int hGap = 5;
    int i = vGap;
    
    for(UIView *item in childViews)
    {
        item.frame = CGRectMake(vGap /2, i , self.frame.size.width - hGap, item.frame.size.height);
        i += vGap + item.frame.size.height;
    }
    [self setContentSize: CGSizeMake(self.frame.size.width, i + vGap)];
}

- (void) doHorizotalLayout
{
    if ([childViews count]==0)
    {
        return;//nothing to do
    }
    UIView *firstView = [childViews objectAtIndex:0];
    int vGap = (self.frame.size.height - firstView.frame.size.height) / 2;
    int hGap = 20;
    int i = hGap /2;
    
    for(UIView *item  in childViews)
    {
        item.frame = CGRectMake(i, vGap, item.frame.size.width, item.frame.size.height);
        i += hGap /2 + item.frame.size.width;
    }
    
    [self setContentSize: CGSizeMake(fmax(self.frame.size.width, i + hGap), self.frame.size.height)];
}

- (void) refreshViewOnSuccess:(SSScrollViewCallback) callback
{
    createChildCallback = callback;
    [self getObjects];
}

- (void) handleError:(SSCallbackEvent *)event
{
    [self updateUI:event];
}

- (void) delete : (id) item ofType:(NSString *) type
{
    [[SSClient getClient] deleteObject: [item objectForKey:@"id"]
                                ofType: type
                            onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error)
         {
             [self handleError:event];
         }
         
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             [self getObjects];
         }
     }
     ];
}

//when user tab on the subview, we will call delegate to handle the event.
- (void)viewTaped:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:0.25
                     animations:^(void){
                         gestureRecognizer.view.alpha = 0.25f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.25 animations:^(void){
                             gestureRecognizer.view.alpha = 1.0f;
                         }
                                          completion:^(BOOL finished) {
                                              if (self.scrollViewDelegate && [self.scrollViewDelegate respondsToSelector:@selector(scrollView:didSelectView:)])
                                              {
                                                  [self.scrollViewDelegate scrollView:self didSelectView:gestureRecognizer.view];
                                              }
                                          }
                          ];
                     }];
}

- (void) addTap:(UIView *) iv
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTaped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    [iv addGestureRecognizer:singleTap];
    [iv setUserInteractionEnabled:YES];
}

- (void) delete:(id) item
{
    [self delete:item ofType:self.objectType];
}

- (void) updateUI:(SSCallbackEvent *)event
{
    result = event.data;
    if (!result)
    {
        result = event.cachedEvent.data;
    }
    
    NSMutableArray *newActivities = [NSMutableArray array];
    for(id item in result)
    {
        BOOL exists = NO;
        for (id object in dataObjects)
        {
            if ([[object objectForKey:@"id"] isEqualToString:[item objectForKey:@"id"]])
            {
                exists = YES;
                break;
            }
        }
        if (!exists)
        {
            [newActivities addObject:item];
        }
    }
    //
    //add an array, this will call addChildView one by one
    //
    createChildCallback(self, newActivities);
    
    if (!dataObjects)
    {
        dataObjects = newActivities;
    }
    else
    {
        [dataObjects addObjectsFromArray:newActivities];
    }
    if ([childViews count]==0)
    {
        childViews = newChildViews;
        newChildViews = nil;
    }
    else
    {
        NSMutableArray *mergedViews = [NSMutableArray arrayWithArray:newChildViews];
        [mergedViews addObjectsFromArray:childViews];
        newChildViews = nil;
        childViews = mergedViews;
    }
    
    //merge oldChildView and newChildView
    for(UIView *item in childViews)
    {
        if ([[item gestureRecognizers] count] ==0)
        {
            [self addTap:item];
        }
    }
    [self doLayout];
    
}

- (SSQuery *) getQuery
{
    SSQuery *query = [[SSQuery alloc]init];
    [[[[[query setLimit:self.pageSize]
        setOffset:self.offset]
       setQuery:self.queryString]
      setOrderBy:self.orderBy]
     setDistanceFilter:self.distanceFilter];
    return query;
}

- (void) getObjects
{
    [[SSClient getClient] query: [self getQuery]
                         ofType: self.objectType
                     onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error)
         {
             [self handleError:event];
         }
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             [self updateUI:event];
         }
     }];
}

@end
