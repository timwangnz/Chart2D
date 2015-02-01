//
//  SSEntityVCFactory.m
//  JobsExchange
//
//  Created by Anping Wang on 2/8/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSEntityVCFactory.h"


@implementation SSEntityVCFactory

+ (SSEntityDetailsView*) getEntityView:(NSString *) objectType
{
    return (SSEntityDetailsView*) [[NSClassFromString(objectType) alloc] init];
}

+ (SSEntityVC*) getCreateVC:(NSString *) objectType
{
    return (SSEntityVC*) [[NSClassFromString(objectType) alloc] init];
}

@end
