//
//  Shape.h
//  SixStreams
//
//  Created by Anping Wang on 2/7/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> 
#import <CoreGraphics/CoreGraphics.h>

#import "SSEntityObject.h"
#import "SSJSONUtil.h"


#define DATA @"data"
#define TYPE @"type"
#define FILL @"f"

@class SSGraph;

typedef enum
{
    cleared = 0,
    drawing,
    drawn
}
DrawingStatus;


@interface SSShape : SSEntityObject
{
    float deltaX;
    float deltaY;
}

@property(nonatomic, assign) float penWidth;
@property (strong, nonatomic) UIColor *color;
@property (nonatomic) SSGraph* graph;

@property BOOL isSelected;

@property CGPoint start;
@property CGPoint end;

@property CGPoint lastPos;

@property BOOL isResizable;
@property BOOL hidden;

- (void) draw;

- (void) replay;

//serialize color
- (UIColor *) stringToColor:(NSString *) colorStr;
- (NSString *) colorToString:(UIColor *) color;

- (void) reset;
- (BOOL) isIdenticalTo:(SSShape *)object;
- (BOOL) isPointOn:(CGPoint)point;
//move but not change original
- (void) moveInX :(float) x andY:(float) y;
//move and change original, and save is necessary
- (void) moveToX :(float) x andY:(float) y;

- (BOOL) collideWith:(SSShape *)shape;

- (CGRect) bounds;

@end
