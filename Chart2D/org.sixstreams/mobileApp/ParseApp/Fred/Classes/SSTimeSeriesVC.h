//
//  SSTimeSeriesVC.h
//  SixStreams
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSFredCommonVC.h"
#import "SSTimeSeriesGraphVC.h"

@interface SSTimeSeriesVC : SSFredCommonVC

@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) SSTimeSeriesGraphVC *detailVC;


@end
