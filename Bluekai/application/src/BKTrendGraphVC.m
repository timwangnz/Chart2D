//
//  BKTrendGraphVCViewController.m
//  Bluekai
//
//  Created by Anping Wang on 5/27/15.
//  Copyright (c) 2015 cdss. All rights reserved.
//

#import "BKTrendGraphVC.h"

@interface BKTrendGraphVC ()

@end

@implementation BKTrendGraphVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.days = 1;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"7 Days" style:UIBarButtonItemStyleDone target:self action:@selector(toggleDays:)];
    [self updateChart];
}

- (void) toggleDays:(id) sender
{
    if (self.days == 1)
    {
        self.days = 7;
        self.navigationItem.rightBarButtonItem.title = @"1 Day";
    }
    else{
        self.days = 1;
        self.navigationItem.rightBarButtonItem.title = @"7 Day";
    }
    [self updateChart];
}

- (void)updateChart
{
    //to be overrided
}

@end
