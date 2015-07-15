//
//  Graph2DMarkerStyle.h
//  Chart2D
//
//  Created by Anping Wang on 3/29/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

enum
{
    Graph2DMarkerNone                   = 0,
    Graph2DMarkerRect                   = 2,
    Graph2DMarkerCross                  = 1,
    Graph2DMarkerCircle                 = 3,
};

typedef NSInteger Graph2DMarkerType;

@interface Graph2DMarkerStyle : NSObject

@property (nonatomic) UIColor * color;
@property (nonatomic) int size;
@property (nonatomic) Graph2DMarkerType markerType;


@end
