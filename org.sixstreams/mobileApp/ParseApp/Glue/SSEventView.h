//
//  SSEventView.h
//  SixStreams
//
//  Created by Anping Wang on 1/18/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSImageView.h"

@protocol SSEventViewDelegate <NSObject>
@optional
- (void) eventView:(id) eventView didSelect:(id) event;
@end

@interface SSEventView : UIView

@property (nonatomic, assign) id event;
@property (nonatomic) id<SSEventViewDelegate> delegate;
@property BOOL imageOnly;

- (id) initWithEvent:(id) event;
- (void) refreshUI;
- (SSImageView *) getImageVew;
@end
