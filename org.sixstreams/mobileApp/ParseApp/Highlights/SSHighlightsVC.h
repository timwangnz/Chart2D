//
//  SSHightlightsVC.h
//  SixStreams
//
//  Created by Anping Wang on 5/14/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"

@class SSMenuVC;

@protocol SSHighlightsVCDelegate <NSObject>
@optional
- (UIView *) highlightsVC:(id) vc viewFor:(id) item;
@end

@interface SSHighlightsVC : SSTableViewVC

@property int categories;
@property int animationInterval;

- (NSArray *) getItemViews;

@end
