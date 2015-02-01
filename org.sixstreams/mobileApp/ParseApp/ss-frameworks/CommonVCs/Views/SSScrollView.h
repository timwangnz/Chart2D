//
//  SSScrollView.h
//  Mappuccino
//
//  Created by Anping Wang on 4/21/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DebugLogger.h"

@class SSScrollView;

@protocol SSScrollViewDelegate <NSObject>
@optional
- (void) scrollView: (SSScrollView *) ssClient didSelectView:(id) view;
@end

typedef void (^SSScrollViewCallback)(id ssScrollView, NSArray *objects);


@interface SSScrollView : UIScrollView

@property int mode;
@property int hGap;
@property int vGap;

- (void) addChildView:(UIView *) view;

@property (strong, nonatomic) id<SSScrollViewDelegate> scrollViewDelegate;

- (void) refreshUI;
- (void) reset;
@end
