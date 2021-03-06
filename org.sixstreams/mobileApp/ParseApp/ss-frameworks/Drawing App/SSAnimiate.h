//
//  SSAnimiate.h
//  SixStreams
//
//  Created by Anping Wang on 2/9/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSShape.h"
#import "SSDrawableLayer.h"

@interface SSAnimiate : NSObject

@property (nonatomic) SSDrawableLayer *view;

- (void) bounce:(SSShape *) shape;

- (void) stop;
@end
