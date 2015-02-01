//
//  SSEntityVCFactory.h
//  JobsExchange
//
//  Created by Anping Wang on 2/8/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSEntityVC.h"
#import "SSEntityDetailsView.h"

@interface SSEntityVCFactory : NSObject

+ (SSEntityDetailsView*) getEntityView:(NSString *) objectType;
+ (SSEntityVC*) getCreateVC:(NSString *) objectType;

@end
