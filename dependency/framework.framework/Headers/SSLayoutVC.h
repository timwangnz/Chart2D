//
//  SSChildrenVC.h
//  SixStreams
//
//  Created by Anping Wang on 6/24/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCommonVC.h"

@interface SSLayoutVC : SSCommonVC

@property (retain, nonatomic) id entity;
@property int columns;

- (void) addIconView :(id) iconVC;
- (void) entityChanged;
- (void) doLayout;

- (void) showDetails:(UIViewController *)detailsVC;

@end
