//
//  Line.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/1/12.
//

#import "SSLine.h"
#import "SSLinePoint.h"
#import "Vector.h"
#import "SSGraph.h"

#import "GLPen.h"


#define GRID_ROWS 20

@interface SSLine ()
{
    NSMutableArray *linePoints;
    CGFloat minx, maxx, miny, maxy;
    CGFloat aspectRatio;
}

@property (nonatomic, retain) NSString *saved;

@end

@implementation SSLine

- (id) init
{
    self = [super init];
    if (self)
    {
        linePoints = [[NSMutableArray alloc]init];
        maxx = maxy = -10000000000;
        minx = miny = 10000000000;
        aspectRatio = 1;
        self.straight = NO;
    }
    return self;
}

- (id) initWithData:(id) data
{
    return [self init];
}

- (CGRect) bounds
{
    return CGRectMake(minx, miny, maxx - minx, maxy - miny);
}

- (void) moveToX :(float) x andY:(float) y
{
    deltaX = 0;
    deltaY = 0;
    
    minx = minx + x;
    miny = miny + y;
    maxx = maxx +x;
    maxy = maxy + y;
    
    
    for(int i = 0; i< [linePoints count]; i++)
    {
        SSLinePoint* cp = [linePoints objectAtIndex:i];
        cp.pos = CGPointMake(cp.pos.x + x, cp.pos.y + y);
        cp.calculatedPoints = nil;
    }
    self.graph.updated = YES;
}

- (BOOL) isPointOn:(CGPoint)point
{
    for(int i = 0; i< [linePoints count] - 1; i++)
    {
        SSLinePoint* first = [linePoints objectAtIndex:i];
        SSLinePoint* second = [linePoints objectAtIndex:i+1];
        if(nearBy(first.pos, second.pos, point))
        {
            return YES;
        }
    }
    return NO;
}

- (id) toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject:[NSNumber numberWithInt:line]  forKey:TYPE];
    
    NSMutableDictionary *selfData = [dic objectForKey:DATA];
    NSMutableString *linePointsJson = [[NSMutableString alloc]init];
    for (SSLinePoint *lp in linePoints)
    {
        [linePointsJson appendFormat:@"%@", [lp toJson]];
        if (![lp isEqual:linePoints.lastObject])
        {
            [linePointsJson appendString:@";"];
        }
    }
    [selfData setObject:[NSNumber numberWithBool:self.straight] forKey:FILL];
    [selfData setObject:linePointsJson forKey:@"ps"];
    return dic;
}

- (void) fromDictionary:(id) dic
{
    [self reset];
    [super fromDictionary:dic];
    NSDictionary *lineDic = [dic objectForKey:DATA];
    NSArray *linePointsInDic = [[lineDic objectForKey:@"ps"] componentsSeparatedByString:@";"];
    self.straight = [[lineDic objectForKey:FILL]boolValue];
    for(NSString * linePoint in linePointsInDic)
    {
        SSLinePoint *point = [[SSLinePoint alloc]initWithXnY: [linePoint componentsSeparatedByString:@","]];
        [self addPoint:point];
    }
}

- (void) setStart:(CGPoint)start
{
    [super setStart:start];
    [linePoints removeAllObjects];
    [linePoints addObject:[[SSLinePoint alloc] initWithPoint:start]];
}

- (void) setEnd:(CGPoint)end
{
    [super setEnd:end];
    if(self.straight)
    {
        if([linePoints count] == 1)
        {
            [self addPoint:[[SSLinePoint alloc] initWithPoint:end]];
        }
        else
        {
            SSLinePoint *endpoint = [linePoints objectAtIndex:1];
            endpoint.pos=end;
        }
    }else
    {
        [self addPoint:[[SSLinePoint alloc] initWithPoint:end]];
    }
}

- (void) reset
{
    [self removeAllPoints];
}

- (BOOL) isEqual:(id)object
{
    if (![object isKindOfClass:[SSLine class]]) {
        return NO;
    }
    SSLine *otherLine = (SSLine*) object;
    return [self.saved isEqualToString:otherLine.saved];
}

- (CGFloat) aspectRatio
{
    return aspectRatio;
}

- (CGFloat) similarTo :(SSLine *) line
{
    NSArray * myVector = [self distribution:GRID_ROWS];
    NSArray * lineVector = [line distribution:GRID_ROWS];
    CGFloat diff = 0;
    BOOL tried = NO;
    for (int i = 0; i < [lineVector count] && i < [myVector count] ; i++)
    {
        diff = diff + [[myVector objectAtIndex: i] getSimilarity:[lineVector objectAtIndex:i]];
        tried = YES;
    }
    if (diff == 0 && tried)
    {
        return 100;
    }
    diff = sqrtf(diff)/[myVector count];
    return diff;
}


-(NSUInteger) count
{
    return [linePoints count];
}

-(SSLinePoint *) pointAtIndex:(NSUInteger) index
{
    return [linePoints objectAtIndex:index];
}


- (void) replacePointAt:(int) i withPoint :(SSLinePoint *) point
{
    [linePoints replaceObjectAtIndex:i withObject:point];
}

- (void) addCGPoint:(CGPoint) pt
{
    [self addPoint:[[SSLinePoint alloc]initWithPoint:pt]];
}

- (void) addPoint:(SSLinePoint *) linePoint
{
    if (maxx < linePoint.pos.x)
    {
        maxx = linePoint.pos.x;
    }
    
    if (minx > linePoint.pos.x)
    {
        minx = linePoint.pos.x;
    }
    
    if (maxy < linePoint.pos.y)
    {
        maxy = linePoint.pos.y;
    }
    
    if (miny > linePoint.pos.y)
    {
        miny = linePoint.pos.y;
    }
    
    aspectRatio = (maxx - minx)/(maxy - miny);
    [linePoints addObject:linePoint];
    
}

- (SSLinePoint *) firstPoint
{
    return [linePoints objectAtIndex:0];
}

- (SSLinePoint *) lastPoint
{
    return [linePoints lastObject];
}

- (void) removeAllPoints
{
    [linePoints removeAllObjects];
}

- (NSArray *) distribution:(CGFloat) rows
{
    NSMutableArray *points = [NSMutableArray array];
    for (SSLinePoint *linePoint in linePoints)
    {
        [points addObject : linePoint];
        if (linePoint.calculatedPoints != nil && [linePoint.calculatedPoints count] != 0)
        {
            [points addObjectsFromArray:linePoint.calculatedPoints];
        }
    }
    
    int segments = [points count] / rows;
    
    NSMutableArray * distribution = [NSMutableArray array];
    
    size_t lastPoint = 0;
    
    CGFloat dx = 1.0/(maxx - minx);
    CGFloat dy = 1.0/(maxy - miny);
    
    for (int i = 1;i < rows && i < [points count];i++)
    {
        SSLinePoint *from = points[lastPoint];
        lastPoint = lastPoint + segments;
        if (lastPoint > points.count - 1)
        {
            lastPoint = points.count - 1;
        }
        SSLinePoint *to = points[lastPoint];
        
        Vector *vector = [[Vector alloc]init];
        
        vector.x = (to.pos.x - from.pos.x)*dx;
        vector.y = (to.pos.y - from.pos.y)*dy;
        
        vector.start = CGPointMake((from.pos.x - minx)*dx, (from.pos.y - miny)*dy);
        
        [distribution addObject:vector];
    }
    return [[NSArray alloc]initWithArray:distribution];
}

//algorithm for preparing points
- (void) preparePoints
{
    if ([linePoints count] < 2)
    {
        return;
    }
    SSLinePoint *lastPoint = [self pointAtIndex:0];
    SSLinePoint *previousPoint = nil;
    for (int i = 1; i < [self count]; i++)
    {
        SSLinePoint *currentPoint = [self pointAtIndex:i];
        [self prepareDrawing:previousPoint start:lastPoint end:currentPoint];
        previousPoint = lastPoint;
        lastPoint = currentPoint;
    }
}

- (void) prepareDrawing:(SSLinePoint *) previousPoint start:(SSLinePoint *) lineStart end:(SSLinePoint *)lineEnd
{
    if (previousPoint)
    {
        NSArray *smoothedPoints = lineStart.calculatedPoints;
        if (smoothedPoints == nil)
        {
            NSArray *points = [NSArray arrayWithObjects:previousPoint, lineStart, lineEnd, nil];
            smoothedPoints = [self calculateSmoothLinePoints:points];
            lineStart.calculatedPoints = smoothedPoints;
        }
    }
}

- (NSMutableArray *)calculateSmoothLinePoints:(NSArray*) points
{
    if ([points count] > 2)
    {
        int segmentDistance = 4;
        NSMutableArray *smoothedPoints = [NSMutableArray array];
        for (unsigned int i = 2; i < [points count]; ++i) {
            SSLinePoint *prev2 = [points objectAtIndex:i - 2];
            SSLinePoint *prev1 = [points objectAtIndex:i - 1];
            SSLinePoint *cur = [points objectAtIndex:i];
            
            SSLinePoint *midPoint1 = [[prev1 add:prev2] mult:0.5];
            SSLinePoint *midPoint2 = [[cur add:prev1] mult:0.5];
            
            float distance =  [midPoint1 distFrom:midPoint2.pos];
            
            
            int numberOfSegments = MIN(100, MAX(floorf(distance / segmentDistance), 2));
            
            float t = 0.0f;
            
            float step = 1.0f / numberOfSegments;
            
            for (NSUInteger j = 0; j < numberOfSegments; j++)
            {
                SSLinePoint *newPoint = [[SSLinePoint alloc] init];
                
                newPoint = [[[midPoint1 mult: powf(1 - t, 2)] add: [prev1 mult: 2.0f * (1 - t) * t]] add : [midPoint2 mult: t * t]];
                
                
                [smoothedPoints addObject:newPoint];
                t += step;
            }
            SSLinePoint *finalPoint = [[SSLinePoint alloc] init];
            finalPoint.pos = midPoint2.pos;
            [smoothedPoints addObject:finalPoint];
        }
        return smoothedPoints;
    }
    else
    {
        return nil;
    }
}
- (NSArray *) vertices
{
    return linePoints;
}

- (void) replay
{
    NSArray *oldArray = [NSArray arrayWithArray:linePoints];
    [linePoints removeAllObjects];
    for (SSLinePoint *lp in oldArray)
    {
        [linePoints addObject:lp];
        [self.graph.inView redraw];
    }
}

- (void) erase
{
    GLPen *pen = [[GLPen alloc]init];
    pen.color = self.isSelected ? [UIColor lightGrayColor] : self.color;
    pen.width = self.penWidth;
    pen.inView = ((SSGraph *)self.graph).inView;
    pen.scale = ((SSGraph *)self.graph).inView.contentScaleFactor;
    if(pen.scale == 0)
    {
        pen.scale = 1;
    }
    [self drawWithPen:pen];
}

- (void) draw
{
    [super draw];
    GLPen *pen = [[GLPen alloc]init];
    pen.color = self.isSelected ? [UIColor lightGrayColor] : self.color;
    pen.width = self.penWidth;
    pen.inView = ((SSGraph *)self.graph).inView;
    pen.scale = ((SSGraph *)self.graph).inView.contentScaleFactor;
    if(pen.scale == 0)
    {
        pen.scale = 1;
    }
    

    size_t numComponents = CGColorGetNumberOfComponents([pen.color CGColor]);
    const CGFloat *components = CGColorGetComponents([pen.color CGColor]);
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
    
    glLineWidth(self.penWidth == 0 ? 1 : self.penWidth);
    glPointSize(self.penWidth == 0 ? 1 : self.penWidth);
    
    [self drawWithPen:pen];
}

- (void) drawWithPen:(GLPen *) selectedPen
{
    if([self count] < 2)
    {
        return;
    }
    SSLinePoint *lastPoint = [self pointAtIndex:0];
    
    SSLinePoint *startP = [[SSLinePoint alloc]initWithPoint:CGPointMake(lastPoint.pos.x + deltaX, lastPoint.pos.y + deltaY)];
    startP.calculatedPoints = lastPoint.calculatedPoints;
    
    SSLinePoint *previousPoint = nil;
    
    for (NSUInteger i = 1; i < [self count]; i++)
    {
        SSLinePoint *cp = [self pointAtIndex:i];
        
        SSLinePoint *endP = [[SSLinePoint alloc]initWithPoint:CGPointMake(cp.pos.x + deltaX, cp.pos.y + deltaY)];
        endP.calculatedPoints = cp.calculatedPoints;
        if (self.isSelected) {
            startP.calculatedPoints = nil;
        }
        [selectedPen draw:previousPoint start:startP end:endP];
        lastPoint.calculatedPoints = startP.calculatedPoints;
        lastPoint = cp;
        previousPoint = self.straight ?  nil : startP;
        startP = endP;
    }
}

@end
