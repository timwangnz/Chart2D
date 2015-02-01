//
//  SSCarouselView.h
//  SixStreams
//
//  Created by Anping Wang on 8/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "iCarousel.h"

@class SSCarouselView;

@protocol SSCarouselViewDelegate <NSObject>
@optional
- (void) view:(SSCarouselView *) view didSelect : (id) entity;
@end


@interface SSCarouselView : iCarousel

@property (nonatomic) int width;
@property (nonatomic) int height;

@property (nonatomic, retain) id<SSCarouselViewDelegate> carouselViewDelegate;

- (void) updateUI:(id) objects;

@end
