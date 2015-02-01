//
//  SSTimeSeriesGraphVC.h
//  SixStreams
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSFredCommonVC.h"
#import "HTTPConnector.h"

@interface SSTimeSeriesGraphVC : SSFredCommonVC<UISplitViewControllerDelegate>

- (void) addSeries:(id) series;
- (void) loadData:(RequestCallback) block;
- (void) updateUI;

@end
