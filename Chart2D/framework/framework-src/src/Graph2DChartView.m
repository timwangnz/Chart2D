//
//  Graph2DChartView.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/25/12.
//

#import "Graph2DChartView.h"
#import "Graph2DArea.h"

#define kTicks 10
#define kCircleRadius 6
#define HIGH_VALUE_KEY @"highValue"
#define LOW_VALUE_KEY @"lowValue"

@interface Graph2DChartView()
{
    CGFloat xTicks, yTicks;
    
    int numberOfBars;
    
    int numberOfLines;
    
    NSUInteger maxItems;
    
    CGFloat gradienceLocations[3];
    
    CGPoint touchPointStartedAt;
    CGPoint touchPointEndAt;
    CGPoint touchPointCurrent;
    BOOL touchStarted;
    
    NSMutableArray *storedLocations;
    CGFloat xZoomFactor;
    CGFloat yZoomFactor;
}

@end

@implementation Graph2DChartView

- (void) initChart
{
    [super initChart];
    self.barGap = 2;
    yZoomFactor = xZoomFactor = 1.0;
    storedLocations = [[NSMutableArray alloc]init];
    self.autoScale = YES;
}

- (void) dealloc
{
    storedLocations = nil;
}

- (NSArray *) dataFromDelegate
{
    NSMutableArray *data = [[NSMutableArray alloc]init];
    [storedLocations removeAllObjects];
    
    float yMax = -9000000000000;
    float yMin =  9000000000000;
    
    if (self.dataSource)
    {
        NSInteger graphs = [self.dataSource numberOfSeries:self];
        
        numberOfBars = 0;
        numberOfLines = 0;
        
        for (int i = 0; i < graphs; i++)
        {
            NSMutableArray *items = [[NSMutableArray alloc]init];
            //add place hodler for rects
            Graph2DSeriesStyle *seriesStyle = [Graph2DSeriesStyle defaultStyle:self.chartType];
            [storedLocations addObject:[[NSMutableArray alloc]init]];
            
            NSInteger numberOfItems = [self.dataSource numberOfItems:self forSeries:i];
            if (self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(graph2DView:styleForSeries:)])
            {
                seriesStyle = [self.chartDelegate graph2DView:self styleForSeries:i];
                
                if (seriesStyle && seriesStyle.chartType == Graph2DLineChart)
                {
                    numberOfLines ++;
                }
                else if (seriesStyle && seriesStyle.chartType == Graph2DBarChart)
                {
                    numberOfBars ++;
                }
                else if(self.chartType == Graph2DBarChart)
                {
                    numberOfBars ++;
                }
                else if(self.chartType == Graph2DLineChart)
                {
                    numberOfLines ++;
                }
            }
            
            for(int j = 0; j < numberOfItems; j++)
            {
                NSNumber *value = [self.dataSource graph2DView:self valueAtIndex : j forSeries:i];
                NSNumber *lowValue = [NSNumber numberWithInt:0];
                
                if ([self.dataSource respondsToSelector:@selector(graph2DView:lowValueAtIndex:forSeries:)] && seriesStyle.isRangeChart)
                {
                    lowValue = [self.dataSource graph2DView:self lowValueAtIndex : j forSeries:i];
                }
                
                if ([value floatValue] > yMax)
                {
                    yMax = [value floatValue];
                }
                
                if ([value floatValue] < yMin)
                {
                    yMin = [value floatValue] ;
                }
                
                NSMutableDictionary *valueDic = [NSMutableDictionary dictionary];
                if (value)
                {
                    [valueDic setObject:value forKey : HIGH_VALUE_KEY];
                    [valueDic setObject:lowValue forKey : LOW_VALUE_KEY];
                    [items addObject:valueDic];
                }
            }
            
            [data addObject:items];
        }
        
        
        if (self.autoScale)
        {
            self.yMax = yMax;
            self.yMin = yMin;
        }
    }
    
    maxItems = 0;

    for (int j = 0 ; j < [data count]; j++)
    {
        NSArray * series = [data objectAtIndex:j];
        if (maxItems < [series count])
        {
            maxItems = [series count];
        }
    }
    
    if(self.barChartStyle == BarStyleStack)
    {
        NSMutableArray *stackHeight = [[NSMutableArray alloc]initWithCapacity:maxItems];
        
        for (int j = 0 ; j < maxItems; j++)
        {
            [stackHeight addObject:[NSNumber numberWithFloat:0.0]];
        }
        
        for (int i = 0; i < [data count]; i++)
        {
            NSMutableArray *items = [data objectAtIndex:i];
            
            for(int j=0; j<[items count];j++)
            {
                NSNumber *value = [items[j] objectForKey:HIGH_VALUE_KEY];
                NSNumber *accumulated = [stackHeight objectAtIndex:j];
                [stackHeight replaceObjectAtIndex:j withObject: [NSNumber numberWithFloat:[value floatValue] + [accumulated floatValue]]];
            }
        }
        
        for (int i = 0 ; i < [stackHeight count]; i++)
        {
            if (self.yMax < [[stackHeight objectAtIndex:i] floatValue])
            {
                self.yMax = [[stackHeight objectAtIndex:i] floatValue];
            }
        }
    }
    
    if (self.autoScale)
    {
        CGFloat delta = self.yMax - self.yMin;
        self.yMax = self.yMax + delta / 10;
        self.yMin = self.yMin - delta/ 10;
    }

    
    CGFloat ySpan = 1.0 / (self.yMax - self.yMin);
    
    for (int i = 0; i < [data count]; i++)
    {
        NSMutableArray *items = [data objectAtIndex:i];
        for(int j = 0; j < [items count]; j++)
        {
            NSNumber *value = [items[j] objectForKey:HIGH_VALUE_KEY];
            value = [NSNumber numberWithFloat : ([value floatValue] - self.yMin)*ySpan];
            [items[j] setObject:value forKey:HIGH_VALUE_KEY];
            
            value = [items[j] objectForKey:LOW_VALUE_KEY];
            value = [NSNumber numberWithFloat : ([value floatValue] - self.yMin)*ySpan];
            [items[j] setObject:value forKey:LOW_VALUE_KEY];
        }
    }
     
    return data;
}


- (void) drawCharts:(NSArray*)data inContext : (CGContextRef) context
{
    xTicks = kTicks;
    yTicks = kTicks;
    Graph2DAxisStyle *xAxisStyle = nil, *yAxisStyle = nil;
    
    if(self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(xAxisStyle:)])
    {
        xAxisStyle = [self.chartDelegate xAxisStyle:self];
        xTicks = xAxisStyle.tickStyle.majorTicks;
    }
    
    if(self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(yAxisStyle:)])
    {
        yAxisStyle = [self.chartDelegate yAxisStyle:self];
        yTicks = yAxisStyle.tickStyle.majorTicks;
    }
    
    [self drawGrid:context];
    
    
    if (self.chartType == Graph2DBarChart)
    {
        [self drawBarChart : data inContext:context];
        [self drawLineChart : data inContext:context];
    }
    else if(self.chartType == Graph2DHorizontalBarChart)
    {
        [self drawHBarChart:data inContext:context];
    }
    else if (self.chartType == Graph2DLineChart)
    {
        [self drawLineChart : data inContext:context];
        [self drawBarChart : data inContext:context];
    }
    
    CGContextSetShouldAntialias(context, NO);
    if (touchStarted && self.cursorType == Graph2DCursorRect)
    {
        [self drawSelectedRect:context];
    }
    else if (touchStarted && self.cursorType == Graph2DCursorCross)
    {
        
        [self drawCoordinate:context];
    }
    
    if(xAxisStyle && !xAxisStyle.hidden)
    {
        [self drawXAxis :context withStyle:xAxisStyle];
    }
    
    if(yAxisStyle && !yAxisStyle.hidden)
    {
        [self drawYAxis :context withStyle:yAxisStyle];
    }
    
    CGContextSetShouldAntialias(context, YES);
}

- (void) drawBarChart : (NSArray *)data inContext:(CGContextRef) context
{
    //
    float barWidth = gBounds.size.width / maxItems;
    
    NSMutableArray *stackHeight = [[NSMutableArray alloc]initWithCapacity:maxItems];
    
    for (int j =0 ; j < maxItems; j++)
    {
        [stackHeight addObject:[NSNumber numberWithFloat:0.0]];
    }
    
    for (int j =0 ; j < [data count]; j++)
    {
        Graph2DSeriesStyle *style = [Graph2DSeriesStyle defaultStyle:self.chartType];
        
        if(self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(graph2DView:styleForSeries:)])
        {
            style = [self.chartDelegate graph2DView:self styleForSeries : j];
        }
        
        if (style.chartType != Graph2DBarChart)
        {
            continue;
        }
        
        NSArray * series = [data objectAtIndex:j];
        
        for (int i = 0; i < [series count] ; i++)
        {
            float floatValue = [[series[i] objectForKey:HIGH_VALUE_KEY] floatValue];
            
            float lowFloatValue = [[series[i] objectForKey:LOW_VALUE_KEY] floatValue];
            
            float barY = gBottomLeft.y - gDrawingRect.size.height * floatValue;
            
            if (self.barChartStyle == BarStyleStack)
            {
                NSNumber *acumlatedHeight = [stackHeight objectAtIndex:i];
                acumlatedHeight = [NSNumber numberWithFloat: [acumlatedHeight floatValue] + floatValue];
                [stackHeight replaceObjectAtIndex:i withObject:acumlatedHeight];
                barY = gBottomLeft.y - gDrawingRect.size.height *  [acumlatedHeight floatValue];
            }
            
            float barHeight = gDrawingRect.size.height * (floatValue - lowFloatValue);
            
            float barX = gBottomLeft.x + i * barWidth;
            CGRect barRect = CGRectMake(barX + self.barGap, barY, barWidth - 2 * self.barGap, barHeight);
            [self drawBar:barRect context:context forSeries:j atIndex:i];
        }
    }
}

- (void) drawHBarChart : (NSArray *)data inContext:(CGContextRef) context
{
    float maxBarWidth = gDrawingRect.size.width;
    float barHeight = gDrawingRect.size.height / maxItems;
    
    for (int j =0 ; j< [data count]; j++)
    {
        NSArray * series = [data objectAtIndex:j];
        Graph2DSeriesStyle *style = [Graph2DSeriesStyle defaultStyle:self.chartType];
        
        if(self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(graph2DView:styleForSeries:)])
        {
            style = [self.chartDelegate graph2DView:self styleForSeries :j];
            
        }
        
        if (style.chartType != Graph2DHorizontalBarChart)
        {
            continue;
        }
        
        for (int i = 0; i < [series count]; i++)
        {
            float floatValue = [[series[i] objectForKey:HIGH_VALUE_KEY] floatValue];
            float lowFloatValue = [[series[i] objectForKey:LOW_VALUE_KEY] floatValue];
            
            float barX = gBottomLeft.x + maxBarWidth * lowFloatValue;
            float barY = gBottomLeft.y - i * barHeight;
            
            float barWidth = maxBarWidth * (floatValue - lowFloatValue);
            CGRect barRect = CGRectMake(barX, barY  + self.barGap - barHeight, barWidth, barHeight- 2 * self.barGap);
            [self drawBar:barRect context:context forSeries:j atIndex:i];
        }
    }
}

- (void)drawLineChart: (NSArray *)data inContext:(CGContextRef) context
{
    [self drawGrid:context];
    
    for (int j =0 ; j< [data count]; j++)
    {
        Graph2DSeriesStyle *style = [Graph2DSeriesStyle defaultStyle:self.chartType];
        
        if(self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(graph2DView:styleForSeries:)])
        {
            style = [self.chartDelegate graph2DView:self styleForSeries :j];
            
        }
        if (style.chartType != Graph2DLineChart)
        {
            continue;
        }
        
        [self drawLine:[data objectAtIndex:j] inContext:context forSeries:j];
    }
}

- (void) fillLineChartArea: (NSArray *)data inContext:(CGContextRef) context forSeries:(int) series
{
    if ([data count] ==0)
    {
        return;
    }
    
    int maxGraphHeight = gDrawingRect.size.height;
    
    CGContextBeginPath(context);
    
    Graph2DSeriesStyle *seriesStyle = [Graph2DSeriesStyle defaultStyle:self.chartType];
    
    if (self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(graph2DView:styleForSeries:)])
    {
        seriesStyle = [self.chartDelegate graph2DView:self styleForSeries:series];
        CGContextSetLineWidth(context, seriesStyle ? seriesStyle.lineStyle.penWidth : 1);
        CGContextSetStrokeColorWithColor(context, [seriesStyle.color CGColor]);
    }
    
    float offset = seriesStyle.xAlign;
    float deltaX = gBounds.size.width / (maxItems - (1 -  offset));
    
    CGContextMoveToPoint(context, gBottomLeft.x + offset * deltaX/2, gBottomLeft.y - maxGraphHeight * [[data[0] objectForKey:LOW_VALUE_KEY] floatValue]);
    CGContextAddLineToPoint(context, gBottomLeft.x + offset * deltaX/2, gBottomLeft.y - maxGraphHeight * [[data[0] objectForKey:HIGH_VALUE_KEY] floatValue]);
    NSUInteger count = [data count];
    for (int i = 1; i < count; i++)
    {
        float floatValue = [[data[i] objectForKey:HIGH_VALUE_KEY] floatValue];
        CGContextAddLineToPoint(context, gBottomLeft.x + i * deltaX + offset * deltaX/2, gBottomLeft.y - maxGraphHeight * floatValue);
    }
    
    for (int i = 1; i < count; i++)
    {
        float floatValue = [[data[count - i] objectForKey:LOW_VALUE_KEY] floatValue];
        CGContextAddLineToPoint(context, gBottomLeft.x + (count - i) * deltaX + offset * deltaX/2, gBottomLeft.y - maxGraphHeight * floatValue);
    }
    
    CGContextClosePath(context);
    
    CGGradientRef gradient;
    CGColorSpaceRef colorspace;
    
    size_t num_locations = 2;
    CGFloat locations[2] = {0.0, 1.0};
    
    colorspace = CGColorSpaceCreateDeviceRGB();
    
    if (self.chartDelegate)
    {
        CGFloat newComponents[8] =
        {
            1.0, 0.5, 0.0, 0.2, // Start color
            1.0, 0.5, 0.0, 1.0 // End color
        };
        
        CGColorRef color = [seriesStyle.fillStyle.color CGColor];
        
        if (seriesStyle.fillStyle.colorFrom)
        {
            color = [seriesStyle.fillStyle.colorFrom CGColor];
        }
        
        NSUInteger numComponents = CGColorGetNumberOfComponents(color);
        if (numComponents == 4)
        {
            const CGFloat *components = CGColorGetComponents(color);
            newComponents[0] = components[0];
            newComponents[1] = components[1];
            newComponents[2] = components[2];
            newComponents[3] = components[3];
        }
        else if(numComponents == 2)
        {
            const CGFloat *components = CGColorGetComponents(color);
            newComponents[0] = components[0];
            newComponents[1] = components[0];
            newComponents[2] = components[0];
            newComponents[3] = components[1];
        }
        
        if (seriesStyle.fillStyle.colorTo)
        {
            color = [seriesStyle.fillStyle.colorTo CGColor];
        }
        
        numComponents = CGColorGetNumberOfComponents(color);
        if (numComponents == 4)
        {
            const CGFloat *components = CGColorGetComponents(color);
            newComponents[4] = components[0];
            newComponents[5] = components[1];
            newComponents[6] = components[2];
            newComponents[7] = components[3];
        }
        else if(numComponents == 2)
        {
            const CGFloat *components = CGColorGetComponents(color);
            newComponents[4] = components[0];
            newComponents[5] = components[0];
            newComponents[6] = components[0];
            newComponents[7] = components[1];
        }
        gradient = CGGradientCreateWithColorComponents(colorspace, newComponents, locations, num_locations);
    }
    
    else
    {
        //default
        CGFloat components[8] =
        {1.0, 0.5, 0.0, 0.2, // Start color
            1.0, 0.5, 0.0, 1.0}; // End color
        gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
        
    }
    
    CGContextSaveGState(context);
    CGPoint startPoint, endPoint;
    startPoint.x = gBottomLeft.x;
    startPoint.y = gBottomLeft.y;
    endPoint.x = gBounds.origin.x;
    endPoint.y = gBounds.origin.y;
    CGContextClip(context);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);
}

- (void) drawLine: (NSArray *)data inContext:(CGContextRef) context forSeries:(int) series
{
    if (!data || [data count] == 0)
    {
        return;
    }
    
    Graph2DSeriesStyle *seriesStyle = [Graph2DSeriesStyle defaultStyle:self.chartType];
    
    if (self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(graph2DView:styleForSeries:)])
    {
        seriesStyle = [self.chartDelegate graph2DView:self styleForSeries:series];
        CGContextSetLineWidth(context, seriesStyle ? seriesStyle.lineStyle.penWidth : 1);
        CGContextSetStrokeColorWithColor(context, [seriesStyle.color CGColor]);
    }
    
    if(seriesStyle.gradient)
    {
        [self fillLineChartArea:data inContext:context forSeries:series];
    }
    
    int maxGraphHeight = gDrawingRect.size.height;
    
    NSMutableArray *rects = [storedLocations objectAtIndex:series];
    
    CGContextBeginPath(context);
    float offset = seriesStyle.xAlign;
    float deltaX = gBounds.size.width / (maxItems - (1 -  offset));
    
    CGContextMoveToPoint(context, gBottomLeft.x + offset * deltaX/2, gBottomLeft.y - maxGraphHeight * [[data[0] objectForKey:HIGH_VALUE_KEY] floatValue]);
    
    for (int i = 1; i < [data count]; i++)
    {
        CGFloat x = gBottomLeft.x + i * deltaX  + offset * deltaX/2;
        float floatValue  = [[data[i] objectForKey:HIGH_VALUE_KEY] floatValue];
        CGFloat y = gBottomLeft.y - maxGraphHeight * floatValue;
        CGContextAddLineToPoint(context, x, y);
        CGRect newRect = CGRectMake(x, y, 10, 10);
        [rects addObject:[[Graph2DArea alloc]initWithRect:newRect]];
    }
    
    CGContextMoveToPoint(context, gBottomLeft.x, gBottomLeft.y);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    if(seriesStyle.showMarker)
    {
        
        for (int i = 0; i < [data count]; i++)
        {
            float x = gBottomLeft.x + i * deltaX + offset * deltaX/2;
            float floatValue  = [[data[i] objectForKey:HIGH_VALUE_KEY] floatValue];
            float y = gBottomLeft.y - maxGraphHeight * floatValue;
            
            Graph2DMarkerStyle *markerStyle = nil;
            
            if ([self.chartDelegate respondsToSelector:@selector(graph2DSeries:markerAtIndex:)]) {
                 markerStyle = [self.chartDelegate graph2DSeries:series markerAtIndex:i];
            }
            CGContextBeginPath(context);
            if (!markerStyle)
            {
                CGRect rect = CGRectMake(x - kCircleRadius, y - kCircleRadius, 2 * kCircleRadius, 2 * kCircleRadius);
                CGContextAddEllipseInRect(context, rect);
            }
            else
            {
                //we can also control color and shape later
                CGRect rect = CGRectMake(x - markerStyle.size , y - markerStyle.size, 2 * markerStyle.size, 2 * markerStyle.size);
                CGContextSetStrokeColorWithColor(context, [markerStyle.color CGColor]);
                CGContextAddEllipseInRect(context, rect);
            }
            CGContextClosePath(context);
            CGContextDrawPath(context, kCGPathStroke);
        }
        
    }
    
    
}

- (void) drawYAxis: (CGContextRef) context withStyle:(Graph2DAxisStyle *)yAxisStyle
{
    Graph2DAxisStyle *axisStyle = yAxisStyle ? yAxisStyle : [Graph2DAxisStyle defaultStyle];
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
   
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [axisStyle.color CGColor]);
    
    UIColor *tickcolor = [UIColor blueColor];
    
    if (axisStyle.tickStyle && axisStyle.tickStyle.color)
    {
        tickcolor = axisStyle.tickStyle.color;
    }
    else if (axisStyle.color)
    {
        tickcolor = axisStyle.color;
        
    }
    UIColor *labelcolor = [UIColor blueColor];
    
    if (axisStyle.labelStyle && axisStyle.labelStyle.color)
    {
        labelcolor = axisStyle.labelStyle.color;
    }
    else if (axisStyle.color)
    {
        labelcolor = axisStyle.color;
        
    }
    
    int ticks = axisStyle.tickStyle.majorTicks == 0 ? 2 : axisStyle.tickStyle.majorTicks;
    
    int minorTicks = axisStyle.tickStyle.minorTicks;
    
    float deltaY = gBounds.size.height / (ticks - 1);
    
    CGFloat yValueDelta = (self.yMax - self.yMin)/(ticks  - 1);
    
    for (int i = 0; i < ticks; i++)
    {
        CGFloat y = gBottomLeft.y - i * deltaY + axisStyle.tickStyle.penWidth/2;
        if (axisStyle && !axisStyle.labelStyle.hidden)
        {
            UIFont *font = axisStyle.labelStyle.font;
            CGFloat angle = axisStyle.labelStyle.angle;
            
            NSString *theText = [NSString stringWithFormat: (axisStyle.labelStyle.format ? axisStyle.labelStyle.format: @"%0.2f"), i*yValueDelta + self.yMin];
            
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(graph2DView:yLabelAt:)])
            {
                theText = [self.chartDelegate graph2DView:self yLabelAt:i];
            }
            
            NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName :  labelcolor};
            CGSize size = [theText sizeWithAttributes:attributes];
            
            [self textAtPoint: theText
                           at: CGPointMake(gBounds.origin.x - size.width - axisStyle.tickStyle.majorLength - axisStyle.labelStyle.offset, y - size.height/2)
                     andAngle: angle
                      andFont: font
                     andColor: labelcolor];
        }
        
        CGContextSetStrokeColorWithColor(context, [tickcolor CGColor]);
        if(axisStyle.tickStyle.showMajorTicks)
        {
            CGContextSetShouldAntialias(context, NO);
            CGContextMoveToPoint(context, gBottomLeft.x - axisStyle.tickStyle.majorLength, y );
            CGContextAddLineToPoint(context, gBottomLeft.x, y );
            CGContextSetShouldAntialias(context, YES);
        }
        
        
        if (axisStyle.tickStyle.showMinorTicks && axisStyle.tickStyle.minorTicks > 0 && i < ticks - 1)
        {
            float minorDelta = deltaY/(minorTicks + 1);
            float y = gBottomLeft.y - i * deltaY;
            for(int j=1;j < minorTicks + 1;j++)
            {
                CGContextSetShouldAntialias(context, NO);
                CGContextMoveToPoint(context, gBottomLeft.x, y - j * minorDelta);
                CGContextAddLineToPoint(context, gBottomLeft.x - axisStyle.tickStyle.minorLength, y - j * minorDelta);
                CGContextSetShouldAntialias(context, YES);
            }
        }
        
    }
    
    if (axisStyle.width > 0)
    {
        if (axisStyle.color)
        {
            CGContextSetStrokeColorWithColor(context, [axisStyle.color CGColor]);
        }
        CGContextSetShouldAntialias(context, NO);
        CGContextMoveToPoint(context, gBottomLeft.x, gBottomLeft.y - gBounds.size.height );
        CGContextAddLineToPoint(context, gBottomLeft.x, gBottomLeft.y );
        CGContextSetShouldAntialias(context, YES);
    }
    
    CGContextDrawPath(context, kCGPathStroke);
}

-(void) textAtPoint:(NSString *)text
                  at:(CGPoint) basePoint
            andAngle:(CGFloat) angle
             andFont:(UIFont *) font
            andColor:(UIColor *) color
{
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : font}];

    CGFloat x = basePoint.x + (sinf(angle) > 0 ? size.height*sinf(angle) / 2.0 : -size.width *cosf(angle));
    
    if (sinf(angle) == 0)
    {
        x = basePoint.x - size.width / 2.0;
    }
    
    CGFloat y = basePoint.y + (sinf(angle) > 0 ? 0 :(-size.width*sinf(angle)));
    
    CGContextRef    context =   UIGraphicsGetCurrentContext();
    CGAffineTransform   t   =   CGAffineTransformMakeTranslation(x, y);
    CGAffineTransform   r   =   CGAffineTransformMakeRotation(angle);
    CGContextConcatCTM(context, t);
    CGContextConcatCTM(context, r);
    
    [text drawAtPoint:CGPointMake(0,0) withAttributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName :  color}];
    
    CGContextConcatCTM(context, CGAffineTransformInvert(r));
    CGContextConcatCTM(context, CGAffineTransformInvert(t));
}

- (void) drawXAxis: (CGContextRef) context withStyle:(Graph2DAxisStyle *)xAxisStyle
{
    Graph2DAxisStyle *axisStyle = xAxisStyle ? xAxisStyle : [Graph2DAxisStyle defaultStyle];
    

    int ticks = axisStyle.tickStyle.majorTicks == 0 ? 2 : axisStyle.tickStyle.majorTicks;
    int minorTicks = axisStyle.tickStyle.minorTicks;
    
    float deltaX = gDrawingRect.size.width / (ticks - 1);
    
    for (int i = 0; i < ticks; i++)
    {
        if (!axisStyle.hidden && !axisStyle.labelStyle.hidden)
        {
            UIFont *font = axisStyle.labelStyle.font;
            
            CGFloat angle = axisStyle.labelStyle.angle;
            CGFloat xValue = (self.xTo - self.xFrom) * i / (ticks - 1);
            
            NSString *theText = [NSString stringWithFormat: (axisStyle.labelStyle.format ? axisStyle.labelStyle.format: @"%0.2f"), xValue];
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(graph2DView:xLabelAt:)])
            {
                theText = [self.chartDelegate graph2DView:self xLabelAt:i];
            }
            
            CGFloat x = 0;
            CGFloat y = 0;
            
            x = gBottomLeft.x + i * deltaX;
            y = gBottomLeft.y + font.pointSize + axisStyle.labelStyle.offset;
            
            if (axisStyle.labelStyle.aligment == Graph2DLabelAlignmentCenter)
            {
                x = x + deltaX / 2;
            }
            
            if (axisStyle.labelStyle.aligment == Graph2DLabelAlignmentRight)
            {
                x = x + deltaX;
            }
            
            if (self.chartType != Graph2DBarChart || (self.chartType == Graph2DBarChart && i < xTicks))
            {
                [self textAtPoint:theText at:CGPointMake(x, y) andAngle: angle andFont:font andColor: axisStyle.labelStyle.color];
            }
        }
        
        UIColor *color = [UIColor blueColor];
        
        if (axisStyle.tickStyle && axisStyle.tickStyle.color)
        {
            color = axisStyle.tickStyle.color;
        }
        else if (axisStyle.color)
        {
            color = axisStyle.color;
            
        }
        
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        if (axisStyle.tickStyle.showMajorTicks)
        {
            CGContextSetShouldAntialias(context, NO);
            CGContextMoveToPoint(context, gBottomLeft.x + i * deltaX, gBottomLeft.y);
            CGContextAddLineToPoint(context, gBottomLeft.x + i * deltaX, gBottomLeft.y + axisStyle.tickStyle.majorLength);
            CGContextSetShouldAntialias(context, YES);
        }
        
        if (axisStyle.tickStyle.showMinorTicks && axisStyle.tickStyle.minorTicks > 0 && i < xTicks - 1)
        {
            float minorDelta = deltaX/(minorTicks + 1);
            
            float x = gBottomLeft.x + i * deltaX;
            
            for(int j=1; j < minorTicks + 1; j++)
            {
                CGContextSetShouldAntialias(context, NO);
                CGContextMoveToPoint(context, x + j * minorDelta, gBottomLeft.y);
                CGContextAddLineToPoint(context, x + j * minorDelta, gBottomLeft.y + axisStyle.tickStyle.minorLength);
                CGContextSetShouldAntialias(context, YES);
            }
        }
    }
    
    if(axisStyle.width > 0)
    {
        if (axisStyle.color)
        {
            CGContextSetStrokeColorWithColor(context, [axisStyle.color CGColor]);
        }
        CGContextSetShouldAntialias(context, NO);
        CGContextMoveToPoint(context, gBottomLeft.x, gBottomLeft.y + 1 );
        CGContextAddLineToPoint(context, gBottomLeft.x + gBounds.size.width, gBottomLeft.y + 1 );
        CGContextSetShouldAntialias(context, YES);
    }
    
    CGContextDrawPath(context, kCGPathStroke);
    
}

- (void) drawGrid : (CGContextRef) context
{
    if (!self.drawXGrids && !self.drawYGrids)
    {
        return;
    }
    CGContextSetShouldAntialias(context, NO);
    float deltaX = gDrawingRect.size.width / xTicks;
    
    if (self.drawXGrids)
    {
        CGFloat yFrom = gBounds.origin.y;
        CGFloat yTo = gBounds.origin.y + gBounds.size.height;
        for (int i = 1; i <= xTicks; i++)
        {
            CGFloat x = gDrawingRect.origin.x + i * deltaX;
            if (x > gBounds.origin.x && x < gBounds.origin.x + gBounds.size.width)
            {
                CGContextMoveToPoint(context, x, yFrom);
                CGContextAddLineToPoint(context, x, yTo);
            }
        }
    }
    
    if(self.drawYGrids)
    {
        float deltaY = gBounds.size.height / yTicks;
        
        CGFloat bottom = gDrawingRect.origin.y + gDrawingRect.size.height;
        CGFloat xFrom = gBounds.origin.x, xTo = gBounds.origin.x + gBounds.size.width;
        for (int i = 0; i <= yTicks; i++)
        {
            CGFloat y = bottom - i * deltaY;
            if (y > gBounds.origin.y && y < gBounds.origin.y + gBounds.size.height)
            {
                CGContextMoveToPoint(context, xFrom, y);
                CGContextAddLineToPoint(context, xTo, y);
            }
        }
    }
    
    if(self.gridStyle)
    {
        if(self.gridStyle.lineType == LineStyleDash)
        {
            CGFloat dash[] = {2.0, 2.0};
            CGContextSetLineDash(context, 0.0, dash, 2);
        } else if(self.gridStyle.lineType == LineStyleDotted)
        {
            CGFloat dash[] = {1.0, 1.0};
            CGContextSetLineDash(context, 0.0, dash, 2);
        }
        else
        {
            CGContextSetLineDash(context, 0, NULL, 0);
        }
        CGContextSetLineWidth(context, self.gridStyle.penWidth);
        CGContextSetStrokeColorWithColor(context, [self.gridStyle.color CGColor]);
    }
    else
    {
        CGFloat dash[] = {2.0, 2.0};
        CGContextSetLineDash(context, 0.0, dash, 2);
    }
    CGContextStrokePath(context);
    CGContextSetLineDash(context, 0, NULL, 0); // Remove the dash
    CGContextSetShouldAntialias(context, YES);
}

- (void)drawBar:(CGRect)rect context:(CGContextRef)context forSeries:(int) series atIndex:(int)index
{
    
    CGRect newRect = rect;
    Graph2DSeriesStyle *seriesStyle = [Graph2DSeriesStyle defaultStyle:self.chartType];
    
    if (self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(graph2DView:styleForSeries:atIndex:)])
    {
        seriesStyle = [self.chartDelegate graph2DView:self styleForSeries:series atIndex:index];
    }
    else if (self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(graph2DView:styleForSeries:)])
    {
        seriesStyle = [ self.chartDelegate graph2DView:self styleForSeries:series];
    }
    
    if (numberOfBars > 1 && self.barChartStyle != BarStyleStack)
    {
        if(self.chartType == Graph2DBarChart)
        {
            CGFloat minWidth = rect.size.width/numberOfBars;
            newRect = CGRectMake(rect.origin.x + series*minWidth + seriesStyle.barGap, rect.origin.y, minWidth, rect.size.height);
        }
        else if(self.chartType == Graph2DHorizontalBarChart)
        {
            CGFloat minHeight = rect.size.width/numberOfBars;
            newRect = CGRectMake(rect.origin.x , rect.origin.y + series*minHeight + seriesStyle.barGap, rect.size.width, minHeight);
        }
    }
    
    CGPoint startPoint = newRect.origin;
    
    CGPoint endPoint = CGPointMake(newRect.origin.x + newRect.size.width, newRect.origin.y);
    
    if (self.chartType == Graph2DHorizontalBarChart)
    {
        endPoint = CGPointMake(newRect.origin.x, newRect.origin.y + newRect.size.height);
    }
    
    
    CGContextBeginPath(context);
    
    [self drawRect:newRect withRadius: 1 inContext:context];
    
    NSMutableArray *rects = [storedLocations objectAtIndex:series];
    
    [rects addObject:[[Graph2DArea alloc]initWithRect:newRect]];
    
    CGContextClosePath(context);
    
    
    // Create and apply the clipping path
    
    //if seriesStyle is not set, by default, we will fill the bar
    //if set, and its gradient returns false, then we would not fill with gradience
    if(seriesStyle == nil || seriesStyle.gradient)
    {
        
        //we need an algorithm to draw gradience with one color tintColor
        // Prepare the resources
        CGFloat components[12] =
        {
            0.2314, 0.5686, 0.4, 1.0,// Start color
            0.4727, 0.7, 0.5157, 1.0, // Second color
            0.2392, 0.5686, 0.4118, 1.0
        }; // End color
        
        //weight averages used to tint the bar
        if (seriesStyle!=nil)
        {
            //user style color
            CGColorRef color1 = [seriesStyle.color CGColor];
            CGColorRef color2 = color1;
            CGColorRef color3 = color2;
            //if fill style is set, use its color
            if (seriesStyle.fillStyle && seriesStyle.fillStyle.color)
            {
                color2 = [seriesStyle.fillStyle.color CGColor];
            }
            //if fillstyle.colorTo is set, use it as third
            //else use color2 we have so far
            if (seriesStyle.fillStyle && seriesStyle.fillStyle.colorTo)
            {
                color3 = [seriesStyle.fillStyle.colorTo CGColor];
            }
            else{
                color3 = color2;
            }
            //
            //if fillstyle.colorFrom is set, use it as first color
            //else use the color2
            if (seriesStyle.fillStyle && seriesStyle.fillStyle.colorFrom)
            {
                color1 = [seriesStyle.fillStyle.colorFrom CGColor];
            }
            else{
                color1 = color2;
            }
            
            
            NSUInteger numComponents = CGColorGetNumberOfComponents(color1);
            
            const CGFloat *newComponents = CGColorGetComponents(color1);
            if (numComponents == 4)
            {
                
                components[0] = newComponents[0];
                components[1] = newComponents[1];
                components[2] = newComponents[2];
                components[3] = newComponents[3];
            }
            else if (numComponents == 2)
            {
                components[0] = newComponents[0];
                components[1] = newComponents[0];
                components[2] = newComponents[0];
                components[3] = newComponents[1];
            }
            
            numComponents = CGColorGetNumberOfComponents(color2);
            
            if (numComponents == 4)
            {
                newComponents = CGColorGetComponents(color2);
                components[4] = newComponents[0];
                components[5] = newComponents[1];
                components[6] = newComponents[2];
                components[7] = newComponents[3];
            }
            else if (numComponents == 2)
            {
                newComponents = CGColorGetComponents(color2);
                components[4] = newComponents[0];
                components[5] = newComponents[0];
                components[6] = newComponents[0];
                components[7] = newComponents[1];
            }
            
            numComponents = CGColorGetNumberOfComponents(color3);
            
            if (numComponents == 4)
            {
                newComponents = CGColorGetComponents(color3);
                components[8] = newComponents[0];
                components[9] = newComponents[1];
                components[10] = newComponents[2];
                components[11] = newComponents[3];
            }
            else if (numComponents == 2)
            {
                newComponents = CGColorGetComponents(color3);
                components[8] = newComponents[0];
                components[9] = newComponents[0];
                components[10] = newComponents[0];
                components[11] = newComponents[1];
                
            }
            
        }
        CGFloat locations[3] = {0.0, 0.33, 1.0};
        
        size_t num_locations = 3;
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
        
        CGContextSaveGState(context);
        CGContextClip(context);
        // Draw the gradient
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(context);
        // Release the resources
        CGColorSpaceRelease(colorspace);
        CGGradientRelease(gradient);
    }
    else if(seriesStyle != nil)
    {
        CGColorRef color = [seriesStyle.fillStyle.color CGColor];
        CGContextSetFillColorWithColor(context, color);
        CGContextDrawPath(context, kCGPathFill);
    }
}

- (void) drawRect:(CGRect)rrect withRadius:(CGFloat) radius inContext: (CGContextRef) context
{
    // NOTE: At this point you may want to verify that your radius is no more than half
    // the width and height of your rectangle, as this technique degenerates for those cases.
    
    // In order to draw a rounded rectangle, we will take advantage of the fact that
    // CGContextAddArcToPoint will draw straight lines past the start and end of the arc
    // in order to create the path from the current position and the destination position.
    
    // In order to create the 4 arcs correctly, we need to know the min, mid and max positions
    // on the x and y lengths of the given rectangle.
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    // Next, we will go around the rectangle in the order given by the figure below.
    //       minx    midx    maxx
    // miny    2       3       4
    // midy   1 9              5
    // maxy    8       7       6
    // Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
    // form a closed path, so we still need to close the path to connect the ends correctly.
    // Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
    // You could use a similar tecgnique to create any shape with rounded corners.
    
    // Start at 1
    CGContextMoveToPoint(context, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
}

- (void) drawSelectedRect:(CGContextRef) context;
{
    CGContextSetLineWidth(context,1);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0.4 green:0.8 blue:0.4 alpha:1.0] CGColor]);
    CGContextMoveToPoint(context, touchPointStartedAt.x, touchPointStartedAt.y);
    CGContextAddLineToPoint(context, touchPointStartedAt.x, touchPointCurrent.y);
    CGContextAddLineToPoint(context, touchPointCurrent.x, touchPointCurrent.y);
    CGContextAddLineToPoint(context, touchPointCurrent.x, touchPointStartedAt.y);
    CGContextAddLineToPoint(context, touchPointStartedAt.x, touchPointStartedAt.y);
    
    CGContextStrokePath(context);
}

- (void) drawCoordinate:(CGContextRef) context;
{
    CGContextSetLineWidth(context,1);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0.4 green:0.8 blue:0.4 alpha:1.0] CGColor]);
    
    
    CGContextMoveToPoint(context, touchPointCurrent.x, gBounds.origin.y);
    CGContextAddLineToPoint(context, touchPointCurrent.x, gBounds.origin.y + gBounds.size.height);
    
    CGContextMoveToPoint(context, gBounds.origin.x, touchPointCurrent.y);
    CGContextAddLineToPoint(context, gBounds.origin.x + gBounds.size.width, touchPointCurrent.y);
    CGContextStrokePath(context);
}

//touch interface

- (void) updateOntouch:(UITouch *)touch
{
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.touchEnabled)
    {
        return;
    }
    touchPointStartedAt = [[touches anyObject] locationInView:self];
    touchPointCurrent = touchPointStartedAt;
    touchStarted = YES;
    [self updateOntouch:[touches anyObject]];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.touchEnabled)
    {
        return;
    }
    touchPointCurrent = [[touches anyObject] locationInView:self];
    [self updateOntouch:[touches anyObject]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!self.touchEnabled)
    {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    touchPointEndAt = [touch locationInView:self];
    touchStarted = NO;
    int i = 0, j = 0;
    if (self.chartDelegate && [self.chartDelegate respondsToSelector:@selector(graph2DView:didSelectSeries:atIndex:)])
    {
        BOOL selected = NO;
        for(NSMutableArray *list in storedLocations)
        {
            j = 0;
            for(Graph2DArea *area in list)
            {
                if ([area isInArea:touchPointEndAt])
                {
                    selected = YES;
                    [self.chartDelegate graph2DView:self didSelectSeries:i atIndex:j];
                    break;
                }
                j ++;
            }
            i++;
        }
        if (!selected)
        {
            [self.chartDelegate graph2DView:self didSelectSeries:-1 atIndex:-1];

        }
    }
    else
    {
        [self updateOntouch:[touches anyObject]];
    }
}
@end
