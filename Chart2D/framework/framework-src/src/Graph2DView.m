//
//  Graph2DView.m
//  Anping Wang
//
//  Created by Anping Wang on 11/16/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "Graph2DView.h"

#define LEFT_MARGIN 20
#define TOP_MARGIN 40

@interface Graph2DView()
{
    NSMutableArray *storedLocations;
    BOOL refreshed;
}

@end

@implementation Graph2DView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        refreshed = NO;
        [self initChart];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(orientationDidChange:)
                                                     name: UIApplicationDidChangeStatusBarOrientationNotification
                                                   object: nil];
    }
    return self;
}


- (void) initChart
{
    _drawBorder = YES;
    self.leftMargin = LEFT_MARGIN;
    self.rightMargin = LEFT_MARGIN;
    self.topMargin = TOP_MARGIN;
    self.bottomMargin = TOP_MARGIN;
    

}
- (void) awakeFromNib
{
    [super awakeFromNib];
    [self initChart];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(orientationDidChange:)
                                                 name: UIApplicationDidChangeStatusBarOrientationNotification
                                               object: nil];
}

- (void) refresh
{
    refreshed = YES;
    [self setNeedsDisplay];
}

- (void) orientationDidChange :(id) sender
{
    [self refresh];
}

- (NSArray *) dataFromDelegate
{
    NSMutableArray *data = [[NSMutableArray alloc]init];
    if (self.dataSource)
    {
        NSInteger graphs = [self.dataSource numberOfSeries:self];
        for (NSInteger i=0; i<graphs; i++)
        {
            NSMutableArray *items = [[NSMutableArray alloc]init];
            NSInteger numberOfItems = [self.dataSource numberOfItems:self forSeries:i];
            for(NSInteger j=0;j < numberOfItems; j++)
            {
                NSNumber *value = [self.dataSource graph2DView:self valueAtIndex:j forSeries:i];
                [items addObject:value];
            }
            [data addObject:items];
        }
    }
    return data;
}

- (void) setChartType:(Graph2DChartType)chartType
{
    if (_chartType != chartType)
    {
        _chartType = chartType;
        [self setNeedsDisplay];
    }
}

- (CGRect) getGraphBounds
{
    [self sizeChart];
    return gBounds;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (refreshed)
    {
        [self repaint];
    }
}

- (void) sizeChart
{
    //if content size is not set, we use frame size
    CGSize size = self.contentSize.width == 0 ? self.frame.size : self.contentSize;
    
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGFloat gGraphHeight = height - self.bottomMargin - self.topMargin - self.topPadding - self.bottomPadding;
    CGFloat gGraphWidth = width - self.leftMargin - self.rightMargin - self.leftPadding - self.rightPadding;
    
    gDrawingRect = CGRectMake(self.leftMargin + self.leftPadding, self.topMargin + self.topPadding, gGraphWidth, gGraphHeight);
    
    gBottomLeft = CGPointMake(gDrawingRect.origin.x, gDrawingRect.origin.y + gDrawingRect.size.height);
    
    gBounds = CGRectMake(self.leftMargin, self.topMargin, width - self.leftMargin - self.rightMargin, height - self.bottomMargin - self.topMargin);
}

- (void) repaint
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self paintBackground:context];
    
    [self sizeChart];
    
    [self drawCharts:[self dataFromDelegate] inContext:context];
    
    if (self.drawBorder)
    {
        [self drawBorder:context];
    }
    

}

//tobe overridden by subclasses
- (void) drawCharts:(NSArray*)data inContext : (CGContextRef) context
{
    // to be overriden
    
}

//private methods used in refresh
- (void) paintBackground:(CGContextRef) context
{
    if (self.fillStyle == nil)
    {
        return;
    }
    CGGradientRef gradient;
    CGColorSpaceRef colorspace;
    
    size_t num_locations = 2;
    CGFloat locations[2] = {0.0, 1.0};
    
    colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat newComponents[8] =
    {
        1.0, 0.5, 0.0, 0.2, // Start color
        1.0, 0.5, 0.0, 1.0 // End color
    };
    if (self.fillStyle.colorFrom)
    {
        CGColorRef color = [self.fillStyle.colorFrom CGColor];
        size_t numComponents = CGColorGetNumberOfComponents(color);
        const CGFloat *components = CGColorGetComponents(color);
        if (numComponents == 4)
        {
            
            newComponents[0] = components[0];
            newComponents[1] = components[1];
            newComponents[2] = components[2];
            newComponents[3] = components[3];
        }
        else{
            newComponents[0] = components[0];
            newComponents[1] = components[0];
            newComponents[2] = components[0];
            newComponents[3] = components[1];
        }
    }
    
    if (self.fillStyle.colorTo)
    {
        CGColorRef color = [self.fillStyle.colorTo CGColor];
        size_t numComponents = CGColorGetNumberOfComponents(color);
        const CGFloat *components = CGColorGetComponents(color);
        if (numComponents == 4)
        {
            newComponents[4] = components[0];
            newComponents[5] = components[1];
            newComponents[6] = components[2];
            newComponents[7] = components[3];
        }
        else{
            newComponents[4] = components[0];
            newComponents[5] = components[0];
            newComponents[6] = components[0];
            newComponents[7] = components[1];
        }
    }
    
    gradient = CGGradientCreateWithColorComponents(colorspace, newComponents, locations, num_locations);
    
    CGPoint startPoint, endPoint;
    if (self.fillStyle.direction == Graph2DFillBottomTop)
    {
        startPoint.x = 0;
        startPoint.y = 0;
        endPoint.x = 0;
        endPoint.y = self.frame.size.height;
    } else if (self.fillStyle.direction == Graph2DFillTopBottom)
    {
        startPoint.x = 0;
        startPoint.y = self.frame.size.height;
        endPoint.x = 0;
        endPoint.y = 0;
    }
    else if (self.fillStyle.direction == Graph2DFillLeftRight)
    {
        startPoint.x = 0;
        startPoint.y = 0;
        endPoint.x = self.frame.size.width;
        endPoint.y = 0;
    }
    else if (self.fillStyle.direction == Graph2DFillRightLeft)
    {
        startPoint.x = self.frame.size.width;
        startPoint.y = 0;
        endPoint.x = 0;
        endPoint.y = 0;
    }
    
    CGContextSaveGState(context);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);
}

- (void) drawBorder:(CGContextRef) context
{
    
    if (self.borderStyle == BorderStyleNone)
    {
        return;
    }
    
    CGContextBeginPath(context);
    CGContextSetShouldAntialias(context, NO);
   
    
    Graph2DLineStyle *lineStyle = [Graph2DLineStyle borderStyle];
    
    if (self.view2DDelegate && [self.view2DDelegate respondsToSelector:@selector(borderLineStyle:)])
    {
        lineStyle = [self.view2DDelegate borderLineStyle:self];
    }
    
    CGContextSetLineWidth(context, lineStyle.penWidth);
    
    CGContextSetStrokeColorWithColor(context, [lineStyle.color CGColor]);
    
    if (lineStyle.lineType == LineStyleDash)
    {
        CGFloat dash[] = {5.0, 5.0};
        CGContextSetLineDash(context, 0.0, dash, 2);
    }
    else if (lineStyle.lineType == LineStyleDotted)
    {
        CGFloat dash[] = {2.0, 2.0};
        CGContextSetLineDash(context, 0.0, dash, 2);
    }
    
    if (self.borderStyle == BorderStyleLeft || self.borderStyle == BorderStyle4Sides)
    {
        CGContextMoveToPoint(context, gBounds.origin.x , gBounds.origin.y);
        CGContextAddLineToPoint(context, gBounds.origin.x, gBounds.origin.y + gBounds.size.height);
    }
    
    if (self.borderStyle == BorderStyleBottom|| self.borderStyle == BorderStyle4Sides)
    {
        CGContextMoveToPoint(context, gBounds.origin.x, gBounds.origin.y + gBounds.size.height);
        CGContextAddLineToPoint(context, gBounds.origin.x + gBounds.size.width, gBounds.origin.y + gBounds.size.height);
    }
    
    if (self.borderStyle == BorderStyleRight|| self.borderStyle == BorderStyle4Sides)
    {
        CGContextMoveToPoint(context, gBounds.origin.x + gBounds.size.width, gBounds.origin.y + gBounds.size.height);
        CGContextAddLineToPoint(context, gBounds.origin.x + gBounds.size.width, gBounds.origin.y);
    }
    if (self.borderStyle == BorderStyleTop|| self.borderStyle == BorderStyle4Sides)
    {
        CGContextMoveToPoint(context, gBounds.origin.x + gBounds.size.width, gBounds.origin.y);
        CGContextAddLineToPoint(context, gBounds.origin.x, gBounds.origin.y);
    }
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetShouldAntialias(context, YES);
}

@end
