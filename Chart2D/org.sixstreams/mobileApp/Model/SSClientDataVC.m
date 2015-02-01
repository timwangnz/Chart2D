//
//  SSClientDataVC.m
//  Mappuccino
//
//  Created by Anping Wang on 4/7/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSClientDataVC.h"
#import "ConfigurationManager.h"
#import "DebugLogger.h"
#import "SSClient.h"
#import "SSQuery.h"

@interface SSClientDataVC ()

@end

@implementation SSClientDataVC


- (NSString *) getUserDisplayName :(id) item
{
   
    if ([item objectForKey:@"firstName"])
    {
        return [NSString stringWithFormat:@"%@ %@", [item objectForKey : @"firstName" ], [item objectForKey : @"lastName" ]];
    }
    else{
        return [item objectForKey:@"username"];
    }
}

- (SSClient *) getClient
{
    return [SSClient getClient];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.offset = 0;
        self.pageSize = 20;
        self.queryString = WILD_SEARCH_CHAR;
    }
    return self;
}

- (NSDictionary *) getLov : (NSString *) name
{
    NSArray *attrs =    [self.definition objectForKey:@"attributes"];
    for (NSDictionary *attr in attrs)
    {
        NSString *attrName = [attr objectForKey:@"name"];
        if ([attrName isEqualToString:name])
        {
            return [attr objectForKey:@"listOfValues"];
            
        }
    }
    return nil;
}


- (void) downloaded: (SSCallbackEvent *)event
{
    [self getObjects];
}

- (void) updated: (SSCallbackEvent *)event
{
    
}

- (void) created: (SSCallbackEvent *)event
{
    
}

- (void) uploaded: (SSCallbackEvent *)event
{
    [self getObjects];
}

- (void) inprogress:(SSCallbackEvent *)event
{
    
}

- (void) upload: (NSData *)data icon:(NSData *) iconData withMetadata:(id) metadata
{
    [[self getClient] upload:@"org.sixstreams.social.Resource"
                        data:data
                    iconData:iconData
                withMetaData:metadata
                  onCallback:^(SSCallbackEvent *event) {
                    if (event.error)
                    {
                         [self handleError:event];
                    }
                    else if(event.callingStatus == SSEVENT_IN_PROGRESS)
                    {
                        [self inprogress:event];
                    }
                    else if(event.callingStatus == SSEVENT_SUCCESS)
                    {
                        [self uploaded:event];
                    }
                }
     ];
}


- (void) download: (NSString *)uri
{
    [self blockView];
    [[self getClient] download: uri
                    onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error)
         {
              [self handleError:event];
         }
         else if(event.callingStatus == SSEVENT_IN_PROGRESS)
         {
             [self inprogress:event];
         }
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             [self unblockView];
             [self downloaded:event];
         }
     }
     ];
}

- (void) update:(id) item ofType:(NSString *) objectType
{
    DebugLog(@"update %@", item);
    [[self getClient] updateObject: item
                            ofType: objectType
                        onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error)
         {
              [self handleError:event];
         }
         else if(event.callingStatus == SSEVENT_IN_PROGRESS)
         {
             [self inprogress:event];
         }
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             [self invalidateCache];
             [self updated: event];
         }
     }
     ];
}

- (void) handleError:(SSCallbackEvent *)event
{
    [self unblockView];
    DebugLog(@"%@\n%@", event, event.error.userInfo);
}

- (void) delete : (id) item ofType:(NSString *) type
{
    [[self getClient] deleteObject: [item objectForKey:@"id"]
                            ofType: type
                        onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error)
         {
             [self handleError:event];
         }
         
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             [self invalidateCache];
             [self getObjects];
         }
     }
     ];
}

- (void) delete:(id) item
{
    [self delete:item ofType:self.objectType];
}

- (void) create:(id) item ofType:(NSString *) objectType
{
    
    [[self getClient] createObject:item
                            ofType:objectType
                        onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error)
         {
             [self handleError:event];
         }
         else if(event.callingStatus == SSEVENT_IN_PROGRESS)
         {
             [self inprogress:event];
         }
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             [self created : event];
         }
     }
     ];
}

- (void) create:(id) item
{
    [[self getClient] createObject:item
                            ofType: self.objectType
                        onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error)
         {
              [self handleError:event];
         }
         else if(event.callingStatus == SSEVENT_IN_PROGRESS)
         {
             [self inprogress:event];
         }
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             [self invalidateCache];
             [self getObjects];
         }
     }
     ];
}

- (void) updateUI
{
    //does nothing here
}

- (void) getDefinition
{
    SSQuery *query = [[SSQuery alloc]init];
    
    SSCallbackEvent *event = [[self getClient] query: query
                     ofType: self.objectType
                 onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error)
         {
             if(event.error.code == 1002)
             {
                  [self handleError:event];
             }
         }
         else if(event.callingStatus == SSEVENT_IN_PROGRESS)
         {
             [self inprogress:event];
         }
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             self.definition = event.data;
             [self updateUI];
         }
     }
     ];
    
    if (event.data)
    {
        self.definition = event.data;
        [self updateUI];
    }
}


- (SSQuery *) getQuery
{
    SSQuery *query = [[SSQuery alloc]init];
    
    [[[[[[[query setLimit:self.pageSize]
                setOffset:self.offset]
                setQuery:self.queryString]
                addFilters:self.filters]
                setOrderBy:self.orderBy]
                setDistanceFilter:self.distanceFilter]
                setFacetNames:self.facetNames];
    return query;
}

- (void) invalidateCache
{
    self.dataObjects = [NSMutableArray array];
    self.offset = 0;
    [self getObjects];
}

- (void) loadMoreObjects
{
    self.offset = self.offset + self.pageSize;
}

- (void) getObjects
{
    SSClient *client = [self getClient];
    [client invalidateCache : [self getQuery] ofType: self.objectType];
    SSCallbackEvent * cachedEvent = 
    [client query: [self getQuery]
           ofType: self.objectType
       onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error)
         {
            [self handleError:event];
         }
         else if(event.callingStatus == SSEVENT_IN_PROGRESS)
         {
             [self inprogress:event];
         }
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             [self updateList:event];
         }
     }
     ];
    
    if (cachedEvent)
    {
        [self updateList:cachedEvent];
    }
}

- (void) updateList:(SSCallbackEvent *) event
{
    self.result = event.data;
    
    NSArray *items = event.data;
    NSMutableSet *set = [NSMutableSet setWithArray:self.dataObjects];
    [set addObjectsFromArray:items];
    
    self.dataObjects = [NSMutableArray arrayWithArray:[set allObjects]];
    self.facets = [event.data objectForKey:@"facets"];
    self.total = [[event.data objectForKey:@"total"] intValue];
    [self updateUI];
}

@end
