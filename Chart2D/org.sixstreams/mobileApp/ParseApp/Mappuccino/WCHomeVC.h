//
//  WCFirstViewController.h
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/16/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTableViewVC.h"

#define BEANS @"beans"
#define HOURS @"hours"

@interface WCHomeVC : SSTableViewVC
{
    NSArray *roasters;
}


- (IBAction) showByName:(id)sender;
- (IBAction) showByCity:(id)sender;
- (IBAction) showRecommend:(id)sender;

@end
