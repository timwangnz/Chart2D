//
//  SSTableLayoutView.h
//  SixStreams
//
//  Created by Anping Wang on 12/22/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSTableLayoutView : UITableView<UITableViewDataSource, UITableViewDelegate>

@property BOOL flow;
@property(nonatomic, retain) NSMutableArray *childViews;

- (void) addChildView : (UIView *) childView;
- (void) removeChildView: (UIView *) childView;
- (void) addChildView : (UIView *) childView at:(int) idx;
- (void) removeChildViews;
- (void) replaceChildView : (UIView *) childView with:(UIView *) newView;

- (void) disablesSwipe;
- (void) nextStep;
@end
