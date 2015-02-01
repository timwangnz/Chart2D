//
// AppliaticsProperty.m
// Appliatics
//
//  Created by Anping Wang on 9/30/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSProperty.h"

@interface SSProperty ()
{
    
}

@end

@implementation SSProperty

- (id) initWithName:(NSString *) name andType:(NSString *) type
{
    self = [super init];
    if (self)
    {
        _name = name;
        _type = type;
    }
    return self;
}

- (NSString *) description
{
    NSMutableString *desc = [[NSMutableString alloc]init];
    [desc appendFormat:@"%@ : %@", _name, _type];
    return desc;
}

@end
