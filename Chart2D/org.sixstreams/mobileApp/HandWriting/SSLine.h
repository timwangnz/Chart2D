//
//  Line.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/1/12.
//

#import <Foundation/Foundation.h>
#import "SSLinePoint.h"
#import "SSShape.h"


@class GLPen;

@interface SSLine : SSShape


@property BOOL straight;

- (NSUInteger) count;

- (SSLinePoint *) lastPoint;
- (SSLinePoint *) firstPoint;

- (void) addPoint:(SSLinePoint *) linePoint;
- (void) addCGPoint:(CGPoint) pt;

- (void) replacePointAt:(int) i withPoint :(SSLinePoint *) point;

- (SSLinePoint *) pointAtIndex:(NSUInteger) index;
- (void) removeAllPoints;

- (NSArray *) distribution:(CGFloat) rows;


- (CGFloat) similarTo:(SSLine *) line;
- (CGFloat) aspectRatio;

- (void) drawWithPen:(GLPen *) selectedPen;

- (void) draw;


- (id) initWithData:(id) data;
- (NSArray *) vertices;

@end
