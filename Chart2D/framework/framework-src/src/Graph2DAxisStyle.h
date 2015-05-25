//
//  Graph2DAxisStyle.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/19/12.
//

#import "Graph2DLineStyle.h"
#import "Graph2DTickStyle.h"
#import "Graph2DTextStyle.h"

@interface Graph2DLabelStyle : Graph2DTextStyle
@property CGFloat offset;
@property BOOL hidden;

@property (nonatomic, strong) NSString *format;

@end;

@interface Graph2DAxisStyle : Graph2DLineStyle

@property (nonatomic, strong) Graph2DTickStyle *tickStyle;
@property (nonatomic, strong) Graph2DLabelStyle *labelStyle;
@property BOOL hidden;



+ (Graph2DAxisStyle *) defaultStyle;

@end
