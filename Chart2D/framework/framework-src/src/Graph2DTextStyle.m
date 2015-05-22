//
//  Graph2DTextStyle.m
//  Chart2D
//
//  Created by Anping Wang on 5/21/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "Graph2DTextStyle.h"

@implementation Graph2DTextStyle

- (id) initWithText:(NSString *) text
{
    self = [super init];
    if (self)
    {
        _font =  [UIFont systemFontOfSize:12];
        _text = text;
        _color = [UIColor redColor];
    }
    return self;
}

@end
