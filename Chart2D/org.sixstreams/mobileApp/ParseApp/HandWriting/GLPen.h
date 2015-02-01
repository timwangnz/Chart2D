//
//  GLPen.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/1/12.
//

#import <Foundation/Foundation.h>
#import "SSDrawableLayer.h"
#import "SSLinePoint.h"

@interface GLPen : NSObject


@property (strong) UIColor *color;
@property float width;
@property (nonatomic) id inView;
@property CGFloat scale;

@property GLuint programId;

- (void) draw:(SSLinePoint *) lineStart to:(SSLinePoint *) lineEnd;
- (void) draw:(SSLinePoint *) previousPoint start:(SSLinePoint *) lineStart end:(SSLinePoint *)lineEnd;

- (void) draw:(SSLinePoint *) lineStart to:(SSLinePoint *) lineEnd  withScale:(CGFloat) scale inView:(UIView *) view;
- (void) draw:(SSLinePoint *) previousPoint start:(SSLinePoint *) lineStart end:(SSLinePoint *)lineEnd  withScale:(CGFloat) scale inView:(UIView *) view;

@end
