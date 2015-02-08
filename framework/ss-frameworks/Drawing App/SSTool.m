//
//  SSTool.m
//  SixStreams
//
//  Created by Anping Wang on 2/7/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//
#import "SSGraph.h"
#import "SSTool.h"
#import "SSLine.h"
#import "SSRect.h"
#import "SSEllipse.h"
#import "SSGraphAction.h"
#import "SSTexture.h"
#import "SSSelection.h"

@interface SSTool()
{
    SSShape *selectedShape;
}

@property PaintTool toolType;

@property (nonatomic) SSShape *currentShape;
@end


@implementation SSTool

static NSString *shapeFormat = @"{type:%d,data:%@}";

+ (SSTool *) getTool:(PaintTool) paintTool
{
    SSTool *tool = [[SSTool alloc]init];
    tool.toolType = paintTool;
    return tool;
}

+ (SSShape *) fromDictionary:(id) dic
{
    PaintTool type = (PaintTool) [[dic objectForKey:@"type"]intValue];
    SSShape *shape = [self createShape:type];
    [shape fromDictionary:dic];
    return shape;
}

+ (id) toDictionary:(SSShape *) shape
{
    int type = 0;
    
    if ([shape isKindOfClass:[SSLine class]]) {
        type = 0;
    }
    
    if ([shape isKindOfClass:[SSLine class]]) {
        type = 1;
    }
    
    if ([shape isKindOfClass:[SSRect class]]) {
        type = 2;
    }
    
    if ([shape isKindOfClass:[SSEllipse class]]) {
        type = 3;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [dic setObject:[shape toDictionary] forKey:@"data"];
    return dic;
}

+ (SSShape *) createShape :(PaintTool) toolId
{
    SSShape *shape = nil;
    switch (toolId) {
        case scrible:
            shape = [[SSLine alloc]init];
            break;
        case line:
        {
            SSLine *line = [[SSLine alloc]init];
            line.straight = YES;
            shape = line;
            break;
        }
        case rect:
            shape = [[SSRect alloc]init];
            break;
        case circle:
            shape = [[SSEllipse alloc]init];
            break;
        case texture:
            shape = [[SSTexture alloc]init];
            break;
        case selector:
            shape = [[SSSelection alloc] init];
        default:
            break;
    }
    return shape;
}

- (SSShape *) startCreateShape:(CGPoint) loc forGroup:(SSGraph *) graph
{
    graph.start = loc;
    if (self.toolType == selector && graph.hasSelection)
    {
        selectedShape = [graph getSelectedShapeAt:loc];
        if (selectedShape) {
            return selectedShape;
        }
    }
    self.currentShape = [SSTool createShape:self.toolType];
    if (self.currentShape)
    {
        [graph addShape:self.currentShape];
        self.currentShape.start = loc;
        self.currentShape.color = self.penColor;
        self.currentShape.penWidth = self.penWidth;
    }
    return self.currentShape;
}

- (void) duringCreateShape:(CGPoint) loc forGroup:(SSGraph *) graph
{
    graph.current = loc;
    if (self.toolType == selector && selectedShape)
    {
        return;
    }
    
    if(self.currentShape)
    {
        self.currentShape.end = loc;
    }
}

- (void) endCreateShape:(CGPoint) loc forGroup:(SSGraph *) graph
{
    //this will finalized all selected shapes
    graph.end = loc;
    
    if (self.toolType == selector && selectedShape)
    {
        return;
    }

    if(self.currentShape && graph.objectId != nil)
    {
        if (distance(graph.start, loc) < 4)
        {
            loc = CGPointMake(loc.x+4, loc.y+4);
        }
        
        self.currentShape.end = loc;
        if ([self.currentShape isKindOfClass:[SSSelection class]])
        {
            [graph selectShapesIn:self.currentShape.bounds];
            [graph removeShape:self.currentShape];
        }
        else
        {
            SSGraphAction *action = [[SSGraphAction alloc]init];
            action.objectId = self.currentShape.objectId;
            action.graph = self.currentShape.graph;
            action.shape = self.currentShape;
            action.action = @"a";
            [graph addAction:action];
        }
    }
}
@end
