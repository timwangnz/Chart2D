//
//  Graph2DFillStyle.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/19/12.
//
#import <UIKit/UIKit.h>
#import "Graph2DStyle.h"

enum
{
    Graph2DFillLeftRight                       = 0,
    Graph2DFillBottomTop                       = 2,
    Graph2DFillRightLeft                       = 1,
    Graph2DFillTopBottom                       = 3,
};

typedef NSUInteger Graph2DFillDirection;

@interface Graph2DFillStyle : Graph2DStyle

@property (nonatomic, strong) UIColor * colorFrom;
@property (nonatomic, strong) UIColor * colorTo;
@property (nonatomic) Graph2DFillDirection direction;


@end
