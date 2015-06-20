//
//  CategoryVC.h
//  BluekaiDemo
//
//  Created by Anping Wang on 4/25/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKStorageCommonVC.h"

@interface BKCategoriesVC : BKStorageCommonVC
@property int parentId;
@property int siteId;
@property BOOL isParentPrivate;

@end
