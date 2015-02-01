//
//  SSClientDataVC.h
//  Mappuccino
//
//  Created by Anping Wang on 4/7/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSCommonUtilVC.h"
#import "SSCallbackEvent.h"
#import "DebugLogger.h"
#import "SSSearchCell.h"

#import "SSClient.h"
#define WILD_SEARCH_CHAR @"*"

#define USER_TYPE @"org.sixstreams.social.User"
#define PROFILE_TYPE @"org.jobs.model.Applicant"
#define SIX_STREAMS_COM @"sixstreams.com";

@interface SSClientDataVC : SSCommonUtilVC


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

- (NSDictionary *) getLov : (NSString *) name;

- (void) getObjects;
- (void) invalidateCache;

- (void) delete : (id) item ofType:(NSString *) type;
- (void) create:(id)object;
- (void) update:(id) item ofType:(NSString *) objectType;
- (void) create:(id) item ofType:(NSString *) objectType;

- (void) download:(NSString *) url;
- (void) upload: (NSData *)data icon:(NSData *) iconData withMetadata:(id) metadata;

- (void) handleError:(SSCallbackEvent *)event;
- (NSString *) getUserDisplayName :(id) item;


- (void) updateList:(SSCallbackEvent *) event;

@end
