//
//  SSQuery.h
//  SixStreams
//
//  Created by Anping Wang on 5/24/13.
//  Copyright (c) 2013 SixStreams. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WILD_SEARCH_CHAR @"*"

@interface SSQuery : NSObject


- (int) limit;
- (int) offset;
- (NSDictionary *) filters;
- (NSString *) orderBy;

- (SSQuery *) setLimit: (int) newLimit;

- (SSQuery *) addFilter: (NSString *) name
                  value: (id) value;

- (SSQuery *) setOrderBy: (NSString *) newOrderBy;
- (SSQuery *) setOffset: (int) newOffset;

- (SSQuery *) setQuery: (NSString *) newQuery;

- (SSQuery *) setDistanceFilter: (NSString *) distanceFilter;

- (SSQuery *) setFacetNames: (NSString *) queryFacetNames;
- (SSQuery *) addFilters:(NSDictionary *) newFilters;

- (NSString *) toUrlQuery;

@end
