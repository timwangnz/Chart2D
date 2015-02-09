//
//  SSTool.h
//  SixStreams
//
//  Created by Anping Wang on 2/7/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSShape.h"

typedef enum
{
    scrible = 0,
    line,
    rect,
    circle,
    texture,
    selector
}
PaintTool;

@class SSGraph;

@interface SSTool : NSObject


@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIColor *penColor;
@property (nonatomic) float penWidth;

+ (SSTool *) getTool:(PaintTool) paintTool;
+ (SSShape *) fromDictionary:(id) data;
+ (id) toDictionary:(SSShape *) shape;

//
- (SSShape *) startCreateShape:(CGPoint) loc forGroup:(SSGraph *) graph;
- (void) duringCreateShape:(CGPoint) loc forGroup:(SSGraph *) graph;
- (void) endCreateShape:(CGPoint) loc forGroup:(SSGraph *) graph;

@end
