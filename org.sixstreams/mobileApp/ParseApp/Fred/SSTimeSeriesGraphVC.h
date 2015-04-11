//
//  SSTimeSeriesGraphVC.h
//  SixStreams
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSFredCommonVC.h"
#import "HTTPConnector.h"


@class SSCategoryVC;

@interface SSTimeSeriesGraphVC : SSFredCommonVC<UISplitViewControllerDelegate>

@property SSCategoryVC *categoryVC;

- (void) loadDataFor:(id) seriesDef withBlock:(RequestCallback)block;
- (void) updateUI;

- (void) removeSeries:(id) series;


@end
