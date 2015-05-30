//
//  BKTrendGraphVCViewController.h
//  Bluekai
//
//  Created by Anping Wang on 5/27/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

#import "StorageCommonVC.h"

@interface BKTrendGraphVC : StorageCommonVC
@property int days;

- (void)updateChart;

@end
