//
//  Graph2DTextStyle.h
//  Chart2D
//
//  Created by Anping Wang on 5/21/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Graph2DTextStyle : NSObject

@property (nonatomic, strong) UIColor * color;
@property (nonatomic, strong) UIFont * font;

@property CGFloat angle;
@property NSTextAlignment alignment;

@property int calculatedWidth;
@property int calculatedHeight;
@property int calculatedX;
@property int calculatedY;

@property NSString *text;

- (id) initWithText : (NSString *) text;
- (id) initWithText : (NSString *) text
              color : (UIColor *) color
               font : (UIFont *) font;

@end
