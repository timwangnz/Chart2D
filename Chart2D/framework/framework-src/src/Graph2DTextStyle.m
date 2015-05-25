//
//  Graph2DTextStyle.m
//  Chart2D
//
//  Created by Anping Wang on 5/21/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "Graph2DTextStyle.h"

@implementation Graph2DTextStyle

- (id) init
{
    self = [super init];
    if (self)
    {
        _alignment = NSTextAlignmentLeft;
        _font =  [UIFont systemFontOfSize:12];
        _angle = 0;
        _color = [UIColor whiteColor];
    }
    return self;
}


- (id) initWithText:(NSString *) text
{
    self = [super init];
    if (self)
    {
        _alignment = NSTextAlignmentLeft;
        _font =  [UIFont systemFontOfSize:12];
        _text = text;
        _angle = 0;
        _color = [UIColor whiteColor];
    }
    return self;
}

- (id) initWithText :(NSString *) text
              color :(UIColor *) color
               font :(UIFont *) font
{
    self = [super init];
    if (self)
    {
        _alignment = NSTextAlignmentLeft;
        _angle = 0;
        _font =  font;
        _text = text;
        _color = color;
    }
    return self;
}
@end
