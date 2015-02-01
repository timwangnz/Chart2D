//
//  SSTimeSeriesGraphVC.m
//  SixStreams
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <Chart2D/Chart2D.h>

#import "SSTimeSeriesGraphVC.h"

#import "SSTableLayoutView.h"
#import "SSPropertiesView.h"

@interface SSTimeSeriesGraphVC ()
{
    NSMutableArray *serieses;
    NSMutableDictionary *obvservations;
    IBOutlet SSTimeSeriesView *seriesView;
    IBOutlet SSPropertiesView *tbFacts;
    
    IBOutlet SSTableLayoutView *layoutView;
    IBOutlet UITextView *textView;
    NSString *seriesId;
    id properties;
    id theSeries;
    RequestCallback dataCallback;
    NSData *loadedData;
}

@end

@implementation SSTimeSeriesGraphVC

static NSString  *fredCatSeri = @"http://api.stlouisfed.org/fred/series/observations?api_key=ef673da26430e206a8b7d3ce658b7162&file_type=json";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        serieses = [NSMutableArray array];
        obvservations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *) getUrl:(NSString *)catId
{
    seriesId = catId;
    return [NSString stringWithFormat:@"%@&series_id=%@", fredCatSeri, catId];
}

- (void) setSeries:(id) series
{
    theSeries = series;
    seriesId = [series objectForKey:@"id"];
    properties = [NSMutableDictionary dictionaryWithDictionary:theSeries];
    [properties removeObjectForKey:@"title"];
    [properties removeObjectForKey:@"id"];
    [properties removeObjectForKey:@"notes"];
    [properties removeObjectForKey:@"realtime_end"];
    [properties removeObjectForKey:@"realtime_start"];
    [properties removeObjectForKey:@"frequency_short"];
    [properties removeObjectForKey:@"observation_end"];
    [properties removeObjectForKey:@"observation_start"];
    [properties removeObjectForKey:@"seasonal_adjustment_short"];
    [properties removeObjectForKey:@"units_short"];
   // [self updateUI];
}

- (void) loadData:(RequestCallback)block
{
    dataCallback = block;
    id catId = [theSeries objectForKey:@"id"];
    
    
    if(!catId)
    {
        return;
    }
    
    HTTPConnector *conn = [[HTTPConnector alloc]init];

    [conn get:[self getUrl:catId] onSuccess:^(NSData *data) {
        loadedData= data;
        if (dataCallback)
        {
            dataCallback(nil, data);
        }
    } onProgress:^(id data) {
        //
    } onFailure:^(NSError *error) {
        //
    }];
}

- (void) addSeries:(id) series
{
    [serieses removeAllObjects];
    [serieses addObject:series];
    if ([serieses count]>0) {
        [self setSeries:[serieses objectAtIndex:0]];
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    if (theSeries)
    {
        [self updateUI];
    }
}

- (void) updateUI
{
    tbFacts.data = properties;
    textView.text = [NSString stringWithFormat:@"%@\n\n%@", self.title, [theSeries objectForKey:@"notes"] ? [theSeries objectForKey:@"notes"] : @""];
    
    id dic = [NSMutableDictionary dictionaryWithDictionary:[loadedData toDictionary]];
    [dic setObject:tbFacts.data forKey:@"seriesDef"];
    
    [obvservations setObject:dic forKey:seriesId];
    
    [seriesView addSeries:dic];
    
    
    [layoutView removeChildViews];
    layoutView.hidden = NO;
    if([self isIPad])
    {
        CGRect rect = seriesView.frame;
        rect.size.height = 500;
        seriesView.frame = rect;
        rect.size.height = 200;
        textView.frame = rect;
    }
    
    [textView setScrollEnabled:YES];
    [textView sizeToFit];
    [textView setScrollEnabled:NO];
    
    [layoutView addChildView:seriesView];
    [layoutView addChildView:textView];
    [layoutView addChildView:tbFacts];
}

- (void)splitViewController:(UISplitViewController*)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem*)barButtonItem
       forPopoverController:(UIPopoverController*)pc
{
    [barButtonItem setTitle:@"your title"];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}


- (void)splitViewController:(UISplitViewController*)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

@end
