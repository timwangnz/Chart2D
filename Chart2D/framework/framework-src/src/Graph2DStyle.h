//
//  Graph2DStyle.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/19/12.
//

#import <UIKit/UIKit.h>

@interface Graph2DStyle : NSObject

enum
{
    LineStyleSolid                        = 0,
    LineStyleDash                         = 2,
    LineStyleDotted                       = 1
};

typedef NSUInteger Graph2DLineType;

enum
{
    BarStyleStack                       = 1,
    BarStyleCluster                     = 0
};

typedef NSUInteger Graph2DBarStyle;

//should be unionable
enum
{
    BorderStyleNone                        = -1,
    BorderStyleLeft                        = 1,
    BorderStyleRight                       = 2,
    BorderStyleTop                         = 3,
    BorderStyleBottom                      = 4,
    BorderStyle4Sides                      = 0,
};

typedef NSUInteger Graph2DBorderStyle;

@property (nonatomic, strong) UIColor * color;

@end
