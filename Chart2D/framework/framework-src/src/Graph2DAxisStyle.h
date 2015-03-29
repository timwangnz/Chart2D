//
//  Graph2DAxisStyle.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/19/12.
//

#import "Graph2DLineStyle.h"
#import "Graph2DTickStyle.h"

enum
{
    Graph2DLabelAlignmentLeft                        = 0,
    Graph2DLabelAlignmentRight                       = 2,
    Graph2DLabelAlignmentCenter                      = 1
};

typedef NSUInteger Graph2DLabelAlignment;

@interface Graph2DLabelStyle : NSObject
@property CGFloat offset;
@property (nonatomic, strong) UIFont * font;
@property BOOL hidden;
@property CGFloat angle;
@property Graph2DLabelAlignment aligment;
@property UIColor *color;
@property (nonatomic, strong) NSString *format;
@end;

@interface Graph2DAxisStyle : Graph2DLineStyle

@property (nonatomic, strong) Graph2DTickStyle *tickStyle;
@property (nonatomic, strong) Graph2DLabelStyle *labelStyle;
@property BOOL hidden;



+ (Graph2DAxisStyle *) defaultStyle;

@end
