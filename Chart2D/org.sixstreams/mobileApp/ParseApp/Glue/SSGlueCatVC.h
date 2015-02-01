//
//  SSGlueCatVC.h
//  SixStreams
//
//  Created by Anping Wang on 1/20/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSEntityEditorVC.h"

@interface SSGlueCatVC : SSEntityEditorVC

@property (nonatomic, strong) NSArray *categories;

+ (NSDictionary *) categories;
+ (NSArray *) services;

@end
