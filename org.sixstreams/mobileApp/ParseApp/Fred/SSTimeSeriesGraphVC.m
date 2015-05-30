//
//  SSTimeSeriesGraphVC.m
//  SixStreams
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <Chart2D/Chart2D.h>
#import "SSCategoryVC.h"
#import "SSTimeSeriesGraphVC.h"
#import "SSTimeSeriesView.h"
#import "SSTimeSeries.h"

#import "SSTableLayoutView.h"
#import "SSPropertiesView.h"

//display multiple serieses

@interface SSTimeSeriesGraphVC ()<TimeSeriesViewDelegate>
{
    IBOutlet SSTimeSeriesView *seriesView;
    IBOutlet SSPropertiesView *tbFacts;
    IBOutlet UIView  *controller;
    IBOutlet SSTableLayoutView *layoutView;
    IBOutlet UITextView *textView;
    NSString *seriesId;
    id properties;
    id theSeriesDef;
    RequestCallback dataCallback;
    
    int pointsInChart;
    Graph2DChartType chartType;
    BOOL gradient;
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
    seriesView.showGrowthRate = sender.selectedSegmentIndex == 1;
    [seriesView updateUI];
}

- (IBAction)setDuration : (UISegmentedControl *)sender
{
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            pointsInChart = 30;
            break;
        case 1:
            pointsInChart = 180;
            break;
        case 2:
            pointsInChart = 360;
            break;
            
        default:
            break;
    }
    seriesView.pointsInView = pointsInChart;
    [seriesView updateUI];
}

- (IBAction)changChartStyle:(UISegmentedControl *)sender
{
    if (seriesView.selected)
    {
        [self setChartType:seriesView.selected sender:sender];
    }
    else
    {
        for (SSTimeSeries *ts in [seriesView timeserieses]) {
            [self setChartType:ts sender:sender];
        }
    }
    [seriesView refresh];
}

- (void) setChartType:(SSTimeSeries *) ts sender:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 2)
    {
        seriesView.defaultStyle.chartType = Graph2DBarChart;
        seriesView.defaultStyle.barGap = 1;
    }
    else if(sender.selectedSegmentIndex == 0)
    {
        seriesView.defaultStyle.chartType = Graph2DLineChart;
        seriesView.defaultStyle.chartType = Graph2DLineChart;
        seriesView.defaultStyle.gradient = NO;
        
    }else if(sender.selectedSegmentIndex == 1)
    {
        seriesView.defaultStyle.chartType = Graph2DLineChart;
        seriesView.defaultStyle.gradient = YES;
    }
    
    ts.seriesStyle.chartType = seriesView.defaultStyle.chartType;
    ts.seriesStyle.gradient = seriesView.defaultStyle.gradient;
    ts.seriesStyle.barGap = seriesView.defaultStyle.barGap;
}

- (IBAction)clearAll:(id)sender
{
    [seriesView removeAll];
    [self.categoryVC clearSelections];
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

- (void) removeSeries:(id) series
{
    [seriesView removeSeries:series];
    if ([seriesView numberOfSeries] == 0) {
        properties = nil;
        theSeriesDef = nil;
        seriesId = nil;
        self.title = @"";
        layoutView.hidden = YES;
    }
    else{
        if([seriesView numberOfSeries] >= 1)
        {
            SSTimeSeries *selectedSeries = [seriesView seriesAt:0];
            id catId = selectedSeries.categoryId;
            
            if(!catId)
            {
                return;
            }
            [seriesView clearSelection];
            theSeriesDef = selectedSeries.seriesDef;
            seriesId = selectedSeries.categoryId;
            properties = [NSMutableDictionary dictionaryWithDictionary:theSeriesDef];
        }
        [self updateUI];
    }
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
        loadedData = data;
        id dic = [NSMutableDictionary dictionaryWithDictionary:[loadedData toDictionary]];
        
        if (dic[@"error_code"])
        {
            [self showAlert:dic[@"error_message"] withTitle:@"Error"];
            return;
        }
        if(tbFacts)
        {
            tbFacts.data = properties;
        }
        
        [dic setObject:properties forKey:@"seriesDef"];
        
        [seriesView addSeries:dic];
       
        
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
    seriesView.delegate = self;
    if (theSeriesDef)
    {
        [self updateUI];
    }
    tbFacts.data = properties;
    [self.view setNeedsLayout];
}

- (void) updateUI
{
    [layoutView removeChildViews];
    layoutView.hidden = NO;

    if ([seriesView numberOfSeries] == 1 || !seriesView.selected)
    {
        self.title = [theSeriesDef objectForKey:@"title"];
        textView.text = [NSString stringWithFormat:@"%@\n\n%@", self.title, [theSeriesDef objectForKey:@"notes"] ? [theSeriesDef objectForKey:@"notes"] : @""];
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
        //[layoutView addChildView:seriesView];
        [layoutView addChildView:seriesView];
        [layoutView addChildView:controller];
        [layoutView addChildView:textView];
        [layoutView addChildView:tbFacts];
    }
    else{
        self.title = @"Charts";
        textView.text = @"";
      //  [layoutView addChildView:controller];
        [layoutView addChildView:seriesView];
    }
 
    seriesView.hidden = NO;
    [self.view setNeedsDisplay];
}


- (void) timeSeriesView:(SSTimeSeriesView *)graph2DView didSelectSeries:(int)series atIndex:(int)index
{
    id catId = graph2DView.selected.categoryId;
    if(!catId)
    {
        return;
    }
    
    theSeriesDef = graph2DView.selected.seriesDef;
    seriesId = catId;
    properties = [NSMutableDictionary dictionaryWithDictionary:theSeriesDef];
    
    
    [self updateUI];
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
