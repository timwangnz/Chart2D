//
//  SSFilter.h
//  Medistory
//
//  Created by Anping Wang on 11/6/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EQ @"eq"
#define PREFIX @"PREFIX"
#define NE @"ne"
#define LESS @"lt"
#define GREATER @"gt"
#define CONTAINS @"containedIn"
#define OR_OP @"or"
#define AND_OP @"and"

#define NEAR_BY @"nearBy"

@interface SSFilter : NSObject

@property (nonatomic, readonly) NSString *attrName;
@property (nonatomic, readonly) NSString *op;
@property (nonatomic, readonly) id value;
@property (nonatomic, readonly) NSArray *filters;

+ (id) on:(NSString *) name op:(NSString *) oper value:(id) value;

+ (id) filter:(SSFilter *) fitler1 or : (SSFilter *) filter2;

@end
