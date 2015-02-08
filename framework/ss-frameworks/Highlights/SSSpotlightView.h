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

@class SSSpotlightView;

@protocol SSSpotlightViewDelegate <NSObject>
@optional
- (void) view:(SSSpotlightView *) view didSelect:(id) event;


- (void) view:(SSSpotlightView *) view isMoving:(id) event;
- (void) view:(SSSpotlightView *) view didFinishMoving:(id) event;

@end


@interface SSSpotlightView : SSShadowView

@property (nonatomic, assign) id entityType;
@property (nonatomic, assign) id entity;
@property (nonatomic) id <SSSpotlightViewDelegate> delegate;

- (id) initWithEntity:(id) entity;

- (void) refreshUI;
- (SSImageView *) getImageView;


@end
