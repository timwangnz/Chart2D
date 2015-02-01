//
//  SSQuery.m
//  SixStreams
//
//  Created by Anping Wang on 5/24/13.
//  Copyright (c) 2013 SixStreams. All rights reserved.
//

#import "SSQuery.h"
#import "SSJSONUtil.h"

@interface SSQuery() 
{
    NSString *query;
    int limit;
    int offset;
    NSString *orderBy;
    NSMutableDictionary *filters;
    NSString *distance;
    NSString *facetNames;
}

@end

@implementation SSQuery

#define URL_FITLER_KEY @"&filters="
#define URL_FITLER_VALUE_FMT @"%@:\"%@\""
#define URL_ORDERBY_FMT @"&orderBy=%@"
#define URL_FACETS_FMT @"&facets=%@"
#define URL_DISTANCE_FMT @"&%@"
#define URL_QUERY_FMT @"q=%@&limit=%d&offset=%d"
#define URL_FILTER_NAME_KEY @"name"
#define URL_FILTER_VALUE_KEY @"value"


- (NSDictionary *) filters
{
    return [NSDictionary dictionaryWithDictionary:filters];
}

- (int) limit
{
    return limit;
}

- (int) offset
{
    return offset;
}

- (NSString *) orderBy
{
    return orderBy;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        limit = 20;
        offset = 0;
        query = WILD_SEARCH_CHAR;
        filters = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *) toUrlQuery
{
    NSMutableString *stringFilter = [[NSMutableString alloc]init];
    [stringFilter appendFormat: URL_QUERY_FMT, [query urlEncoded], limit, offset];
    if ([filters count]>0)
    {
        [stringFilter appendString:URL_FITLER_KEY];
        int count = 1;
        for (NSString *key in [filters allKeys])
        {
            [stringFilter appendFormat:URL_FITLER_VALUE_FMT, key, [[filters objectForKey:key] urlEncoded]];
            if  (count < [filters count])
            {
                [stringFilter appendFormat:@";"];
            }
            count ++;
        }
    }
    
    if (orderBy)
    {
        [stringFilter appendFormat:URL_ORDERBY_FMT, orderBy];
    }
    if (distance)
    {
        [stringFilter appendFormat:URL_DISTANCE_FMT, distance];
    }
    if (facetNames)
    {
        [stringFilter appendFormat:URL_FACETS_FMT, facetNames];
    }
    
    return stringFilter;
}

- (SSQuery *) setFacetNames: (NSString *) queryFacetNames
{
    facetNames = queryFacetNames;
    return self;
}

- (SSQuery *) setDistanceFilter: (NSString *) distanceFilter
{
    distance = distanceFilter;
    return self;
}

- (SSQuery *) setLimit:(int) newLimit
{
    limit = newLimit;
    return self;
}

- (SSQuery *) addFilters:(NSDictionary *) newFilters
{
    [filters addEntriesFromDictionary:newFilters];
    return self;
}

- (SSQuery *) addFilter:(NSString *) name
                  value:(id) value
{
    [filters setValue:value forKey:name];
    return self;
}

- (SSQuery *) setOrderBy:(NSString *) newOrderBy
{
    orderBy = newOrderBy;
    return self;
}

- (SSQuery *) setOffset:(int) newOffset
{
    offset = newOffset;
    return self;
}

- (SSQuery *) setQuery:(NSString *) newQuery
{
    query = newQuery;
    return self;
}

@end
