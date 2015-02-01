//
//  SSListVC.h
//
//  Created by Anping Wang on 6/11/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTableViewVC.h"
#import "SSMyViewsVC.h"

@class SSIconView;
/**
    This is the genric table view to show a list of objects
 **/
@interface SSDataViewVC : SSTableViewVC

@property BOOL selected;

@property (nonatomic, strong) id subscription;

@property (nonatomic, strong) IBOutlet SSIconView *iconView;
@property (nonatomic, strong) SSMyViewsVC *parentVC;
@property NSInteger tableColumns;
@property BOOL showHeaders;
@property BOOL hasSummaryRow;

@property int cellLeftPadding;

- (void) updateUI;
- (void) onSelect;

@end
