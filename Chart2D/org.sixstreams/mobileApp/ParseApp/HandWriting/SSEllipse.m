//
//  Ellipse.m
//  SixStreams
//
//  Created by Anping Wang on 2/7/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSEllipse.h"
#import "SSGraph.h"
#import "SSDrawableLayer.h"
#import "SSTool.h"

@interface SSEllipse()
{
    NSMutableArray *points;
    int numberOfSegments;
}
@end

@implementation SSEllipse

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

- (void) setEnd:(CGPoint)end
{
    [super setEnd:end];
    [self updateModel];
}

- (void) updateModel
{
    if (numberOfSegments == 0)
    {
        numberOfSegments = 50;
    }
    
    CGPoint firstPoint = CGPointMake(self.start.x + deltaX, self.start.y + deltaY);
    CGPoint lastPoint = CGPointMake(self.end.x + deltaX, self.end.y + deltaY);
    
    CGRect bounds = [((SSGraph *) self.graph).inView bounds];
    firstPoint.y = bounds.size.height - firstPoint.y;
    lastPoint.y = bounds.size.height - lastPoint.y;
    
    CGPoint center = CGPointMake((lastPoint.x + firstPoint.x)/2, (firstPoint.y + lastPoint.y)/2);
    CGFloat width = fabs(lastPoint.x - firstPoint.x)/2.;
    CGFloat height = fabs(firstPoint.y - lastPoint.y)/2.;
    points = [NSMutableArray array];
    float angle = 0;
    
    float deleta = 360.0f/numberOfSegments;
    
    for (int i = 0; i< numberOfSegments; i++)
    {
        CGPoint pt = CGPointMake(center.x + (cos(DEGREES_RADIANS(angle))*width), center.y + (sin(DEGREES_RADIANS(angle))*height));
        [points addObject :[[SSLinePoint alloc]initWithPoint:pt]];
        angle += deleta;
    }
}

- (void) draw
{
    [super draw];
    [self updateModel];
    [self drawEllipse:YES];
    self.status = drawn;
}

- (BOOL) isPointOn:(CGPoint)point
{
    CGRect bounds = [((SSGraph *) self.graph).inView bounds];
    point.y = bounds.size.height - point.y;
    for (int i = 0; i< numberOfSegments - 1; i++) {
        SSLinePoint *first = [points objectAtIndex:i];
        SSLinePoint *second = [points objectAtIndex:i+1];
        if(nearBy(first.pos, second.pos, point))
        {
            return YES;
        }
    }
    return NO;
}

- (void) fromDictionary:(NSDictionary *)dic
{
    [super fromDictionary:dic];
    [self updateModel];
}

- (id) toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject:[NSNumber numberWithInt:circle]  forKey:TYPE];
    return dic;
}

-(void) drawEllipse:(BOOL) filled
{
    static GLfloat *vertexBuffer = NULL;
	if(vertexBuffer == NULL)
	{
		vertexBuffer = malloc(2*1000 * sizeof(GLfloat));//static memory, will be held forever
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
    glLineWidth(self.penWidth);
    glPointSize(self.penWidth);
    */
    int count = 0;
    for (int i = 0; i< numberOfSegments; i++) {
        SSLinePoint *pt = [points objectAtIndex:i];
        vertexBuffer[count++] = pt.pos.x;
        vertexBuffer[count++] = pt.pos.y;
    }
    //glVertexPointer (2, GL_FLOAT , 0, vertexBuffer);
    glDrawArrays ((filled) ? GL_TRIANGLE_FAN : GL_LINE_LOOP, 0, numberOfSegments);
}

@end
