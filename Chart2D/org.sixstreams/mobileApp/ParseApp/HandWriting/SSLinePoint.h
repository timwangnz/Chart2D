//
//  LinePoint.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/1/12.
//

#import <Foundation/Foundation.h>
@interface SSLinePoint : NSObject

@property(nonatomic, assign) CGPoint pos;
@property(nonatomic, strong) NSArray *calculatedPoints;

- (id)initWithPoint:(CGPoint) point;


- (SSLinePoint *) add:(SSLinePoint *) point;
- (SSLinePoint *) mult:(CGFloat) scalor;
- (CGFloat) distFrom:(CGPoint) point;

- (NSString *) toJson;
- (id) initWithDictionary:(NSDictionary *) dic;
- (id) initWithXnY:(NSArray *) array;

float area(CGPoint p1, CGPoint p2, CGPoint p3);
float distance(CGPoint p1, CGPoint p2);
float nearBy(CGPoint p1, CGPoint p2, CGPoint p3);

- (SSLinePoint *) clone;

@end
