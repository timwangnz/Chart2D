//
//  SSSlideView.h
//  SixStreams
//
//  Created by Anping Wang on 7/30/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSSlideViewDelegate <NSObject>
@required
- (void) view:(UIView *) view isMoving:(float) percent;
- (void) view:(UIView *) view moveEnded:(float) percent;
@end

@interface SSSlideView : UIView

@property id<SSSlideViewDelegate> delegate;

@end
