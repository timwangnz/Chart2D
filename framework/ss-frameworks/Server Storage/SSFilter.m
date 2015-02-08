//
//  SSFilter.m
//  Medistory
//
//  Created by Anping Wang on 11/6/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSFilter.h"

@interface SSFilter()
{
    NSMutableArray *filters;
}
@end


@implementation SSFilter
@synthesize filters;

- (id) initWithName:(NSString *) name op:(NSString *) operation value:(id) value
{
    self = [super init];
    if (self)
    {
        _value = value;
        _op = operation;
        _attrName = name;
        filters = [NSMutableArray array];
    }
    return self;
}

+ (id) on:(NSString *) name op:(NSString *) oper value:(id) value
{
    return [[SSFilter alloc]initWithName:name op:oper value:value];
}

+ (id) filter:(SSFilter *) filter1 or : (SSFilter *) filter2
{
    SSFilter *filter = [[SSFilter alloc]initWithName:@"boolean" op:OR_OP value:nil];
    [filter addFilter:filter1];
    [filter addFilter:filter2];
    return filter;
}

+ (id) filter:(SSFilter *) filter1 AND : (SSFilter *) filter2
{
    SSFilter *filter = [[SSFilter alloc]initWithName:@"boolean" op:AND_OP value:nil];
    [filter addFilter:filter1];
    [filter addFilter:filter2];
    return filter;
}

- (void) addFilter :(SSFilter *) filter
{
    [filters addObject:filter];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.attrName, self.op, self.value ? self.value : self.filters];
}

@end
