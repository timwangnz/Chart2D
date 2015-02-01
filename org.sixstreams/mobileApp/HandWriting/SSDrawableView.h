//
//  GLView.h
//  
//
//  Created by Anping Wang on 11/1/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "SSDrawableDelegate.h"
#import "SSLine.h"
#import "SSConnection.h"
#import "SSTool.h"

@class SSGraph;

@interface SSDrawableView : UIView
{

}

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

@end
