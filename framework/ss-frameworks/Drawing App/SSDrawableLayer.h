//
//  GLView.h
//  
//
//  Created by Anping Wang on 11/1/12.
//  Copyright (c) 2012 s. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "SSDrawableDelegate.h"
#import "SSLine.h"
#import "SSConnection.h"
#import "SSTool.h"


@class SSGraph;

@interface SSDrawableLayer : UIView
{

}

@property (strong, nonatomic) id<SSDrawableDelegate> drawableDelegate;


@property (nonatomic) UIColor *gridColor;
@property (nonatomic) float gridWidth;
@property (nonatomic) float gridHeight;
@property BOOL showGrid;

@property (nonatomic, strong) NSString *name;

@property (nonatomic) UIColor *selectedColor;
@property (nonatomic) float selectedWidth;

@property (nonatomic) SSGraph *graph;

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

@property (nonatomic, weak) UIScreen *targetScreen;


@property BOOL readonly;
@property PaintTool tool;

- (BOOL) isUndoable;
- (BOOL) isRedoable;

- (void) draw;
- (void) redraw;
//delete all the shapes,can not be undone
- (void) clearDrawing;


- (void)startAnimation;
- (void)stopAnimation;


- (void)captureToPhotoAlbum;
- (UIImage *) glToUIImage;
- (void) addImage:(UIImage *) image at:(CGPoint *) point;
- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
@end
