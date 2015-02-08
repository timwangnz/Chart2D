//
//  Rect.m
//  SixStreams
//
//  Created by Anping Wang on 2/7/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSRect.h"
#import "SSLine.h"
#import "SSTool.h"
#import "SSDrawableLayer.h"
#import "SSGraph.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>
#import "Vector.h"

@interface SSRect()
{
    SSLine *lineToDraw;
    GLuint texture;
}
@end

@implementation SSRect

- (id) init
{
    self = [super init];
    deltaY = deltaY =0.0;
    self.isResizable = YES;

    return self;
}

- (void) setEnd:(CGPoint)end
{
    [super setEnd:end];
    [self updateModel];
}

- (void) replay
{
    int steps = 50;
    float dx = (self.end.x - self.start.x)/steps;
    float dy = (self.end.y - self.start.y)/steps;
    
    
    for (int step = 0; step < steps; step++) {
        self.end = CGPointMake(self.start.x + step*dx, self.start.y + step*dy);
        [self draw];
        [self.graph.inView redraw];
    }
}

- (void) updateModel
{
    CGPoint firstPoint = CGPointMake(self.start.x + deltaX, self.start.y + deltaY);
    CGPoint lastPoint = CGPointMake(self.end.x + deltaX, self.end.y + deltaY);
    
    CGPoint secondPoint = CGPointMake(lastPoint.x, firstPoint.y);
    CGPoint thirdPoint = CGPointMake(lastPoint.x, lastPoint.y);
    CGPoint forthPoint = CGPointMake(firstPoint.x, lastPoint.y);
    CGPoint fifthPoint = firstPoint;
    
    lineToDraw = [[SSLine alloc]init];
    lineToDraw.penWidth = self.penWidth;
    lineToDraw.straight = YES;
    lineToDraw.graph = self.graph;
    lineToDraw.color = self.color;
    
    [lineToDraw addCGPoint:firstPoint];
    [lineToDraw addCGPoint:secondPoint];
    [lineToDraw addCGPoint:thirdPoint];
    [lineToDraw addCGPoint:forthPoint];
    [lineToDraw addCGPoint:fifthPoint];
}


- (id) toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject:[NSNumber numberWithInt:rect]  forKey:TYPE];
    NSMutableDictionary *selfData = [dic objectForKey:DATA];
    [selfData setObject:[NSNumber numberWithBool:self.fill] forKey:FILL];
    return dic;
}

- (void) fromDictionary:(id) dic
{
    [super fromDictionary:dic];
    NSDictionary *lineDic = [dic objectForKey:DATA];
    self.fill = [[lineDic objectForKey: FILL]boolValue];
    [self updateModel];
}

- (void) draw
{
    [super draw];
    [self updateModel];

    lineToDraw.isSelected = self.isSelected;
    [lineToDraw draw];
}

- (BOOL) isPointOn:(CGPoint)point
{
    return [lineToDraw isPointOn:point];
}


-(void) drawRect:(BOOL) filled
{
    static GLfloat *vertexBuffer = NULL;
	if(vertexBuffer == NULL)
	{
		vertexBuffer = malloc(2*5 * sizeof(GLfloat));//static memory, will be held forever
	}
     /*
    UIColor *color = self.isSelected ? [UIColor lightGrayColor] : self.color;
   
    size_t numComponents = CGColorGetNumberOfComponents([color CGColor]);
    const CGFloat *components = CGColorGetComponents([color CGColor]);
    
    if (numComponents == 4)
    {
        glColor4f(components[0], components[1], components[2], components[3]);
    }
    else if(numComponents == 2)
    {
        glColor4f(components[0], components[0], components[0], components[1]);
    }
    else
    {
        glColor4f(1.0, 1.0, 0.0, 1.0);
    }
    
    CGRect bounds = [self.graph.inView bounds];

    glLineWidth(self.penWidth);
    glPointSize(self.penWidth);
    
    int count = 0;
    for (SSLinePoint* pt in  [lineToDraw vertices]) {
        vertexBuffer[count++] = pt.pos.x;
        vertexBuffer[count++] = bounds.size.height - pt.pos.y;
    }
    glVertexPointer (2, GL_FLOAT , 0, vertexBuffer);
     */
    glDrawArrays ((filled) ? GL_TRIANGLE_FAN : GL_LINE_LOOP, 0, 5);
}


@end
