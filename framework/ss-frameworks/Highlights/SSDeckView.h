//
//  SSSpotlightView.h
//  SixStreams
//
//  Created by Anping Wang on 5/14/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSImageView.h"
#import "SSShadowView.h"

@class SSDeckView;

@protocol SSDeckViewDelegate <NSObject>
@optional
- (void) view:(SSDeckView *) view didSelect:(id) event;
- (void) view:(SSDeckView *) view didSwipeLeft:(id) event;
- (void) view:(SSDeckView *) view didSwipeRight:(id) event;

- (void) view:(SSDeckView *) view isMoving:(id) event;
- (void) view:(SSDeckView *) view didFinishMoving:(id) event;

@end


@interface SSDeckView : SSShadowView

@property (nonatomic, assign) id entityType;
@property (nonatomic, assign) id entity;
@property (nonatomic) id <SSDeckViewDelegate> delegate;

@property NSString *likeText;
@property NSString *dislikeText;

- (id) initWithEntity:(id) entity;

- (void) refreshUI;
- (UIView *) getSpotlightView;
- (void) underDeck;

- (void) vote:(BOOL) vote;

@end
