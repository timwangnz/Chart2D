//
//  Graph2DVC.h
//  Oracle Daas
//
//  Created by Anping Wang on 11/16/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Chart2D/Chart2D.h>

@interface Graph2DVC : UIViewController<Graph2DDataSource, Graph2DChartDelegate>
{
    IBOutlet UIScrollView *svGraphContainer;
    IBOutlet UISegmentedControl *chartType;
} 
- (IBAction)changChartType:(id)sender;
- (IBAction) maximze:(id)sender;

@end
