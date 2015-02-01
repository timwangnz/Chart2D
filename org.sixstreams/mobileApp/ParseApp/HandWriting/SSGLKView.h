//
//  SSGLKView.h
//  SixStreams
//
//  Created by Anping Wang on 11/15/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "SSDrawableLayer.h"
#import "SSGraph.h"

@interface SSGLKView : GLKView


@property (strong, nonatomic) GLKBaseEffect *effect;
@property (nonatomic) UIColor *gridColor;
@property (nonatomic) float gridWidth;
@property (nonatomic) float gridHeight;
@property (nonatomic) SSGraph *graph;

@property BOOL showGrid;

- (void) setupGL;
- (void) tearDownGL;

- (void) draw;

@end
