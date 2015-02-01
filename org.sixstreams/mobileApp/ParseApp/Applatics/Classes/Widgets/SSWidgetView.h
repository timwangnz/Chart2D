//
// AppliaticsWidgetView.h
// Appliatics
//
//  Created by Anping Wang on 4/2/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTableViewVC.h"

@class SSWidgetVC;

@interface SSWidgetView : UIView

@property (nonatomic, strong) SSWidgetVC *controller;
@property (nonatomic, strong) NSArray *entities;
@property (nonatomic, strong) id entity;
@property (nonatomic, strong) id widget;
@property (nonatomic, strong) NSString * objectType;
@property BOOL showHeaders;
@property NSInteger tableColumns;
- (void) updateUI;
- (void) refresUI;

- (BOOL) isCollection;
@end
