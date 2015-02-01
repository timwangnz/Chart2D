//
//  SSGL2View.h
//  SixStreams
//
//  Created by Anping Wang on 3/18/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "SSGraph.h"
#import "SSDrawableDelegate.h"

@interface SSGL2View : UIView

@property (strong, nonatomic) id<SSDrawableDelegate> drawableDelegate;


//pen property
//this is state variable, once set, will remain the same till reset

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
//@property (nonatomic, strong) id <UserControlDelegate> userControlDelegate;
@property (nonatomic, weak) UIScreen *targetScreen;


@property BOOL readonly;

- (BOOL) isUndoable;
- (BOOL) isRedoable;

- (void) draw;
- (void) redraw;
//delete all the shapes,can not be undone
- (void) clearDrawing;

- (void)eraseBuffer;
- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@end
