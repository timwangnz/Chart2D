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
#import "SSDataView.h"

//display multiple serieses

@interface SSTimeSeriesGraphVC ()
{
    IBOutlet SSDataView *seriesView;
    IBOutlet SSPropertiesView *tbFacts;
    IBOutlet UIView  *controller;
    IBOutlet SSTableLayoutView *layoutView;
    IBOutlet UITextView *textView;
    NSString *seriesId;
    id properties;
    id theSeriesDef;
    RequestCallback dataCallback;
    NSData *loadedData;
}

- (IBAction)clearAll:(id)sender;
- (IBAction)changChartStyle:(UISegmentedControl *)sender;
- (IBAction)setOperation : (UISegmentedControl *)sender;

@end

@implementation SSTimeSeriesGraphVC
static NSString  *timePeriod =  @"";//@"&realtime_start=2014-01-01&realtime_end=2015-03-28";
static NSString  *fredCatSeri = @"http://api.stlouisfed.org/fred/series/observations?api_key=ef673da26430e206a8b7d3ce658b7162&file_type=json";

- (IBAction)setOperation : (UISegmentedControl *)sender
{
    
}

- (IBAction)changChartStyle:(UISegmentedControl *)sender
{
    
}

- (IBAction)clearAll:(id)sender
{
    [seriesView removeAll];
    properties = nil;
    theSeriesDef = nil;
    seriesId = nil;
    layoutView.hidden = YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (NSString *) getUrl:(NSString *)catId
{
    seriesId = catId;
    return [NSString stringWithFormat:@"%@%@&series_id=%@", fredCatSeri, timePeriod, catId];
}

- (void) loadDataFor:(id) seriesDef withBlock:(RequestCallback)block
{
    id catId = [seriesDef objectForKey:@"id"];
    if(!catId)
    {
        return;
    }
    
    theSeriesDef = seriesDef;
    seriesId = [seriesDef objectForKey:@"id"];
    properties = [NSMutableDictionary dictionaryWithDictionary:seriesDef];
    dataCallback = block;
    
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
        [self showAlert:@"Failed to get data, please try again later" withTitle:@"Network Failure"];
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    if (theSeriesDef)
    {
        [self updateUI];
    }
}

- (void) updateUI
{
    
    id dic = [NSMutableDictionary dictionaryWithDictionary:[loadedData toDictionary]];
    if (dic[@"error_code"])
    {
        [self showAlert:dic[@"error_message"] withTitle:@"Error"];
        return;
    }
    
    tbFacts.data = properties;
    self.title = [theSeriesDef objectForKey:@"title"];
    textView.text = [NSString stringWithFormat:@"%@\n\n%@", self.title, [theSeriesDef objectForKey:@"notes"] ? [theSeriesDef objectForKey:@"notes"] : @""];
    

    [dic setObject:tbFacts.data forKey:@"seriesDef"];
    
    [seriesView addSeries:dic];
    
    seriesView.hidden = NO;
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
    
    [layoutView addChildView:controller];
    [layoutView addChildView:seriesView];
    [layoutView addChildView:textView];
    [layoutView addChildView:tbFacts];
}

- (void)splitViewController:(UISplitViewController*)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem*)barButtonItem
       forPopoverController:(UIPopoverController*)pc
{
    [barButtonItem setTitle:@"Categories"];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController*)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

@end
