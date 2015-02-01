//
//  GLPen.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/1/12.
//

#import "GLPen.h"
#import "SSLinePoint.h"


@implementation GLPen

- (void) draw:(SSLinePoint *) lineStart to:(SSLinePoint *) lineEnd
{
    [self draw:lineStart to:lineEnd withScale:self.scale inView:self.inView];
}

- (void) draw:(SSLinePoint *) previousPoint start:(SSLinePoint *) lineStart end:(SSLinePoint *)lineEnd
{
    [self draw:previousPoint start:lineStart end:lineEnd withScale:self.scale inView:self.inView];
}

- (void) draw:(SSLinePoint *) previousPoint start:(SSLinePoint *) lineStart end:(SSLinePoint *)lineEnd  withScale:(CGFloat) scale inView:(UIView *) view
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
       
        for (int i = 1; i < [smoothedPoints count]; i++)
        {
            [self draw: smoothedPoints[i - 1] to:smoothedPoints[i] withScale:scale inView:view];
        }
    }
    else
    {
        [self draw:lineStart to:lineEnd withScale:scale inView:view];
    }
}
#define kBrushPixelStep 1
enum {
	ATTRIB_VERTEX,
	NUM_ATTRIBS
};


- (void)drawLine:(CGPoint)start toPoint:(CGPoint)end
{
	static GLfloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0,
    count,
    i;
	
	// Convert locations from Points to Pixels
	CGFloat scale = 1;//self.contentScaleFactor;
	start.x *= scale;
	start.y *= scale;
	end.x *= scale;
	end.y *= scale;
	
	// Allocate vertex array buffer
	if(vertexBuffer == NULL)
		vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
	
	// Add points to the buffer so there are drawing points every X pixels
	count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
	for(i = 0; i < count; ++i) {
		if(vertexCount == vertexMax) {
			vertexMax = 2 * vertexMax;
			vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
		}
		
		vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
		vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
		vertexCount += 1;
	}
    GLuint vboId;
	glGenBuffers(1, &vboId);
    // Load data to the Vertex Buffer Object
	glBindBuffer(GL_ARRAY_BUFFER, vboId);
	glBufferData(GL_ARRAY_BUFFER, vertexCount*2*sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);
	
    //glEnableVertexAttribArray(ATTRIB_VERTEX);
    //glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
	
	// Draw
    //glUseProgram(self.programId);
	glDrawArrays(GL_POINTS, 0, vertexCount);
	
}


- (void) _draw:(SSLinePoint *) lineStart to:(SSLinePoint *) lineEnd  withScale:(CGFloat) scale inView:(UIView *) view
{
    [self drawLine:lineStart.pos toPoint:lineEnd.pos];
}

- (void) draw:(SSLinePoint *) lineStart to:(SSLinePoint *) lineEnd  withScale:(CGFloat) scale inView:(UIView *) view
{
    static GLfloat* vertexBuffer = NULL;
	if(vertexBuffer == NULL)
	{
		vertexBuffer = malloc(4 * sizeof(GLfloat));
	}
    
    CGPoint end = lineEnd.pos;
    CGPoint start = lineStart.pos;
    
	start.x *= scale;
	start.y *= scale;
	end.x *= scale;
	end.y *= scale;
    
    CGFloat dist = sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y));
    
    if(dist == 0)
    {
        end.x = end.x + 1;
        end.y = end.y + 1;
    }
    
    CGRect bounds = [view bounds];
    start.y = bounds.size.height - start.y;
    end.y = bounds.size.height - end.y;
    
    vertexBuffer[0] = start.x;
    vertexBuffer[1] = start.y;
	vertexBuffer[2] = end.x;
    vertexBuffer[3] = end.y;

    glEnable( GL_LINE_SMOOTH );
    //glClearColor(0.5f, 0.5f, 0.5f, 1.0f);

    glHint( GL_LINE_SMOOTH_HINT, GL_NICEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
    //2 verties
    glDrawArrays(GL_LINES, 0, 2);
    
}
//
//figure out how many points needed between two touch points using 2 points so far, at least 3 points
//need to be in the array
//
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

@end
