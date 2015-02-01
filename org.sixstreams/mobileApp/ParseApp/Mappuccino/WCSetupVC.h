//
//  WCSetupVC.h
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/6/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSSearchVC.h"
#import "SSCommonVC.h"


@interface WCSetupVC : SSCommonVC
{
    NSMutableDictionary *setupParemeter;
    IBOutlet UITextField *code;
    IBOutlet UITextField *username;
    IBOutlet UITextField *email;
    IBOutlet UIImageView *adminMode;
    IBOutlet UIButton *saveBtn;
    NSMutableArray *filteredRoasters;
    IBOutlet UITableView *tableViewRoasters;
}

- (IBAction)updateParameter:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)syncNow:(id)sender;
+ (NSString *) getUsername;
+ (BOOL) isAdmin;

@end
