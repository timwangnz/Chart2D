//
// AppliaticsWidgitVCViewController.m
// Appliatics
//
//  Created by Anping Wang on 6/14/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSWidgetVC.h"
#import "SSWidgetView.h"
#import "SSExpressionParser.h"
#import "NetworkWidgetView.h"
#import <Chart2D/Chart2D.h>

#import "SSWidgetWizardVC.h"
#import "SSEntityVC.h"

@interface SSWidgetVC ()<Graph2DChartDelegate, Graph2DDataSource>
{
    IBOutlet UILabel *titleLabel;
    IBOutlet UIButton *maxmin;
    IBOutlet UIButton *btnGraph;
    IBOutlet UILabel *status;
    IBOutlet UITableView *attrs;
    
    IBOutlet SSWidgetView *widgetView;
    IBOutlet NetworkWidgetView *networkView;
    IBOutlet Graph2DChartView *graphView;
    NSArray *data;
}

- (IBAction) showGraph:(id)sender;
- (IBAction) updateWidget:(id)sender;

@end

@implementation SSWidgetVC

- (IBAction) updateWidget:(id)sender
{
    [self.containerVC updateWidget:self];
}

- (IBAction) showGraph:(id)sender
{
    graphView.hidden = !graphView.hidden;
    graphView.frame = widgetView.frame;
}

- (IBAction)doMaxmin:(id)sender
{
    [UIView animateWithDuration:(0.4) animations:^{
        [self _doMaxmin : sender ];
    }];
}

- (void)_doMaxmin:(id)sender
{
    self.maximized = ! self.maximized;
    [self.containerVC doLayout];
    
    BOOL isHeirarchical = [[self.widget objectForKey:@"heirarchical"] boolValue];
    //
    if(self.maximized && isHeirarchical)
    {
        widgetView.hidden = YES;
        if (!networkView)
        {
            networkView = [[NetworkWidgetView alloc]init];
        }
        
        NSMutableArray *network = [NSMutableArray array];
        for (id item in widgetView.entities)
        {
            NSMutableDictionary *contact = [NSMutableDictionary dictionary];
            [contact setValue:[NSString stringWithFormat:@"%@ %@",
                               [item objectForKey:@"firstName"],
                               [item objectForKey:@"lastName"]
                               ] forKey:@"title"];
            [contact setValue:[[NSString stringWithFormat:@"%@.%@.png",
                               [item objectForKey:@"firstName"],
                               [item objectForKey:@"lastName"]  
                               ] lowercaseString] forKey:@"iconImg"];
            [contact setValue: [item objectForKey:@"jobTitle"]
                               forKey:@"subtitle"];
            
            [contact setValue: [item objectForKey:@"personId"]
                                forKey:REF_ID_NAME];
            
            [contact setValue:[item objectForKey:@"directsIds"]
                                forKey:@"connections"];
            
            [network addObject:contact];
        }
        
        networkView.data = network;
        networkView.backgroundColor = [UIColor whiteColor];
        networkView.hidden = NO;
        networkView.frame = widgetView.frame;
        [self.view addSubview:networkView];
        [networkView updateUI];
    }
    else{
        if (networkView)
        {
            networkView.hidden = YES;
        }
        widgetView.hidden = NO;
    }
}

- (void) refreshUI
{
    [widgetView refresUI];
}

- (void) updateUI;
{
    NSString *titleBinding = [self.widget objectForKey:@"titleBinding"];
    NSString *statusBinding = [self.widget objectForKey:@"statusBinding"];
    
    titleLabel.text = [SSExpressionParser parse:titleBinding forObject:self.entity];
    status.text = [SSExpressionParser parse:statusBinding forObject:self.entity];
    
    widgetView.controller = self;
    widgetView.entity = self.entity;
    widgetView.widget = self.widget;
    
    btnGraph.hidden = ![widgetView isCollection];
    [widgetView updateUI];
}

- (void) graph2DView :(Graph2DView *) graph2DView didSelectSeries:(int)series atIndex:(int)index
{
    
}

- (Graph2DAxisStyle *) xAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *style = [[Graph2DAxisStyle alloc]init];
    return style;
}

- (Graph2DAxisStyle *) yAxisStyle:(Graph2DView *)graph2DView
{
    Graph2DAxisStyle *style = [[Graph2DAxisStyle alloc]init];
    return style;
}

- (NSInteger) numberOfSeries:(Graph2DView *) graph2Dview
{
    return 1;
}

- (NSInteger) numberOfItems:(Graph2DView *) graph2Dview forSeries:(NSInteger) graph
{
    return [data count];
}

- (NSNumber *) graph2DView:(Graph2DView *) graph2DView valueAtIndex:(NSInteger)index forSeries:(NSInteger)series
{
    return [NSNumber numberWithFloat:[[data objectAtIndex:index] floatValue]];
}

- (NSNumber *) graph2DView:(Graph2DView *) graph2DView lowValueAtIndex:(NSInteger)index forSeries:(NSInteger)series
{
    return [NSNumber numberWithFloat:[[data objectAtIndex:index] floatValue]/3.0];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    data = [[NSArray alloc] initWithObjects: @"0.7", @"0.4", @"0.9", @"1.0", @"0.2", @"0.85",
            @"0.11", @"0.75", @"0.53", @"0.44", @"0.88", @"0.77", @"0.27", @"0.17",
            @"0.311", @"0.275", @"0.153", @"0.24",
            @"0.677", @"0.277", @"0.77", @"0.177", @"0.57", @"0.87", @"0.27", nil];
    
   
    graphView.dataSource = self;
    graphView.chartDelegate = self;
    graphView.chartType = Graph2DLineChart;
    graphView.topPadding = 5;
    graphView.topMargin = 5;
    graphView.bottomMargin = 5;
    graphView.barGap = 25;
    graphView.hidden = YES;
    graphView.fillStyle = nil;

}


@end
