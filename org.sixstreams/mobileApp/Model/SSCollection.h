//
//  SSCollection.h
//  SixStreams
//
//  Created by Anping Wang on 5/24/13.
//  Copyright (c) 2013 SixStreams. All rights reserved.
//

#import <Foundation/Foundation.h>




@class SSCollection;

@protocol SSCollectionDelegate <NSObject>
@optional
- (void) collection: (SSCollection *) collection onEvent:(id) event;
@end

@interface SSCollection : UIView
@property (strong, nonatomic) NSString *objectType;
@property (strong, nonatomic) NSString *queryString;
@property (strong, atomic) NSMutableDictionary *filters;
@property (strong, nonatomic) id definition;
@property (strong, nonatomic) NSString *distanceFilter;
@property (strong, nonatomic) NSString *orderBy;
@property (strong, nonatomic) NSString *facetNames;

@property (strong, nonatomic) NSMutableArray *dataObjects;
@property (strong, nonatomic) NSDictionary *result;
@property (strong, nonatomic) NSMutableArray *facets;


@property int pageSize;
@property int offset;
@property int total;

- (void) updateUI;

- (void) getObjects;

@end
