//
//  BKTrendGraphVCViewController.h
//  Bluekai
//
//  Created by Anping Wang on 5/27/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

#import "BKStorageCommonVC.h"

@interface BKTrendGraphVC : BKStorageCommonVC
@property int days;

- (void)updateChart;

@end
