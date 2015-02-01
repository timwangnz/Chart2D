//
//  WCByCityVC.h
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/29/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTableViewVC.h"


@interface WCByCityVC : SSTableViewVC
{
    NSMutableArray *cities;
    IBOutlet UITableView *tableViewRoasters;

}

@end
