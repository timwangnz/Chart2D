//
//  Graph2DArea.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/25/12.
//

#import <UIKit/UIKit.h>

@interface Graph2DArea : NSObject


-(id)initWithRect:(CGRect) aRect;

-(id)initWithRadius:(CGFloat) radius startAngle:(CGFloat) startAngle endAngle:(CGFloat) endAngle center:(CGPoint) center;

- (BOOL) isInArea:(CGPoint )point;

@end
