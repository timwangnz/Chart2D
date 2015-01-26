//
//  Graph2DPieChartView.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/25/12.
//

#import "Graph2DPieChartView.h"
#import "Graph2DArea.h"


@interface Graph2DPieChartView()
{
    NSMutableArray *storedLocations;
}
@end
@implementation Graph2DPieChartView

@synthesize pieChartDelegate =_pieChartDelegate;
@synthesize startAngle = _startAngle;

- (void) awakeFromNib
{
    [super awakeFromNib];
    storedLocations = [[NSMutableArray alloc]init];
}

- (void)drawArcFrom:(CGFloat ) fromAngle to: (CGFloat) toAngle withRadius :(CGFloat) radius inContext:(CGContextRef) context withColor :(CGColorRef) color
{
    CGContextBeginPath(context);
    CGContextSetFillColorWithColor(context, color);
    CGPoint center = CGPointMake(gDrawingRect.origin.x + gDrawingRect.size.width/ 2, gDrawingRect.origin.y + gDrawingRect.size.height / 2);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x,  center.y, radius, fromAngle, toAngle, 0);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    [storedLocations addObject: [[Graph2DArea alloc]initWithRadius:radius startAngle:fromAngle endAngle:toAngle center:center]];
}

- (void) setStartAngle:(CGFloat)startAngle
{
    if (startAngle > M_PI *2)
    {
        _startAngle = startAngle - M_PI *2;
    }
    else
    {
        _startAngle = startAngle;
    }
}
- (void) drawCharts:(NSArray *)data inContext:(CGContextRef) context
{ 
    [self drawPieChart : data inContext:context];
}

- (void)drawPieChart: (NSArray *)data inContext:(CGContextRef) context
{
    Graph2DAxisStyle *style = nil;
    //
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0));
    
    UIFont *font = [UIFont fontWithName:DEFAULT_FONT size:12];
    
    CGFloat labelOffset = 10;
    BOOL showLabel = false;
    if(self.pieChartDelegate)
    {
        style = [self.pieChartDelegate labelStyle : self];
        labelOffset = style.labelOffset;
        showLabel = style.showLabel;
        CGContextSetFillColorWithColor(context, [style.color CGColor]);
        font = style.labelFont == nil ? font : style.labelFont;
    }
    
    [storedLocations removeAllObjects];
     
    if (self.pieChartDelegate)
    {
        self.startAngle = [self.pieChartDelegate startAngle:self];
    }
    
    for (int j =0 ; j< [data count]; j++)
    {
        NSArray * series = [data objectAtIndex:j];
        float total = 0;
        
        for (int i = 0; i < [series count]; i++)
        {
            total+=[series[i] floatValue];
        }
        
        
        CGFloat startAngle = self.startAngle;

        
        CGFloat radius = MIN(gDrawingRect.size.width, gDrawingRect.size.height) / 2;
        
        CGFloat textAtRadius = labelOffset + radius;
        
        for (int i = 0; i < [series count]; i++)
        {
            CGFloat endAngle = startAngle + 2 * M_PI * [series[i] floatValue]/total;
            CGFloat cDelta = i * 1.0 /[series count];
            CGColorRef color = nil;
            
            if (self.pieChartDelegate)
            {
                color = [[self.pieChartDelegate graph2DView:self colorForValue: [series[i] floatValue] atIndex: i ] CGColor];
            }
            else
            {
                color  = [[UIColor colorWithRed:  cDelta * 0.7 green: 0.4* cDelta blue:(0.2 * cDelta) alpha:0.8] CGColor];
            }
            
            [self drawArcFrom:startAngle to:endAngle withRadius:radius inContext:context withColor:color];
            
            if(showLabel)
            {
                CGPoint textLocation;
                
                textLocation.x = gBounds.origin.x + gBounds.size.width/ 2 + textAtRadius * cos((startAngle + endAngle)/2);
                textLocation.y = gBounds.origin.y + gBounds.size.height/ 2 +textAtRadius * sin((startAngle + endAngle)/2);
                
                NSString *theText = [NSString stringWithFormat:@"L %d", i];
                
                if (self.dataSource && [self.pieChartDelegate respondsToSelector:@selector(graph2DView:labelAt:)])
                {
                    theText = [self.pieChartDelegate graph2DView:self labelAt : i];
                }
                
                //CGSize stringSize = [theText sizeWithFont:font];
                
                CGSize stringSize = [theText boundingRectWithSize:CGSizeMake(100, 2000.0)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : font}
                                                          context:nil].size;

                [theText drawAtPoint:CGPointMake(textLocation.x - stringSize.width/2, textLocation.y + stringSize.height / 2.)
                      withAttributes:@{NSFontAttributeName : font}];
              
            }
            startAngle = endAngle ;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if(!self.touchEnabled)
    {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPointEndAt = [touch locationInView:self];
    int i = 0;
    for(Graph2DArea *area in storedLocations)
    {
        if ([area isInArea:touchPointEndAt])
        {
            if (self.pieChartDelegate && [self.pieChartDelegate respondsToSelector:@selector(graph2DView:didSelectIndex:)])
            {
                [self.pieChartDelegate graph2DView:self didSelectIndex:i];
            }
            else{
            NSLog(@"Selected %d", i);
            }
        }
        
        i++;
    }
}


@end
