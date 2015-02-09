//
//  SSBook.m
//  SixStreams
//
//  Created by Anping Wang on 2/15/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSBook.h"
#import "SSGraph.h"
#import "SixStreams.h"
#import "SSStorageManager.h"

@interface SSBook()
{
    NSMutableArray *graphs;
    NSDate *refreshedAt;
    BOOL isRefreshing;
    int pages;
}
@end

@implementation SSBook

- (void) loadLocally
{
    [graphs removeAllObjects];
    NSDictionary *dic = [[SSStorageManager storageManager] read :self.objectId];
    if (dic == nil)
    {
        return;
    }
    NSDictionary *data = [dic objectForKey:@"head"];
    [self fromDictionary:data];
    NSArray *graphData = [dic objectForKey:@"graphs"];
    
    for (id data in graphData) {
        SSGraph *graph = [[SSGraph alloc]initWithData:data];
        graph.book = self;
        [graphs addObject:graph];
        [graph getDetailsOnSuccess:^(id data, NSError *error) {
            //
        }];
    }
}

- (void) saveLocally
{
    NSMutableDictionary *savedDic = [NSMutableDictionary dictionary];
    [savedDic setObject:[self toDictionary] forKey:@"head"];
    NSMutableArray *graphData = [NSMutableArray array];
    
    for (SSGraph *graph in graphs)
    {
        [graphData addObject:[graph toDictionary]];
    }
    [savedDic setObject:graphData forKey:@"graphs"];
    [[SSStorageManager storageManager] save:savedDic uri:self.objectId];
}

- (NSString *) getEntityType
{
    return BOOK_CLASS;
}

- (id) initWithData:(id) dic
{
    self = [self init];
    graphs = [NSMutableArray array];
    [self fromDictionary:dic];
    return self;
}

- (void) fromDictionary:(NSDictionary *) dic
{
    [super fromDictionary:dic];
    pages = [[dic objectForKey:@"pages"] intValue];
    self.storageOption = (StorageOption) [[dic objectForKey:STORAGE] intValue];
    self.name = [dic objectForKey:NAME];
    self.category = [dic objectForKey:CATEGORY];
}

- (id) toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject:[NSNumber numberWithInt:(int) [self pages]] forKey:@"pages"];
    [dic setObject:[NSNumber numberWithInt: self.storageOption] forKey:STORAGE];
    [dic setObject:self.name forKey:NAME];
    [dic setObject:self.category forKey:CATEGORY];
    
    return dic;
}

- (NSInteger) pages
{
    return [graphs count];
}

- (SSGraph *) getPageAtIndex:(NSInteger) index
{
    if (index < [graphs count])
    {
        return [graphs objectAtIndex:index];
    }
    return nil;
}

- (SSGraph *) getFirstPage
{
    return [self getPageAtIndex:0];
}

- (void) addPage:(SSGraph *) graph
{
    if ([graph.book isEqual:self])
    {
        return;
    }
    graph.book = self;
    NSInteger max = 0;
    for (SSGraph *g in graphs) {
        if (g.sequence > max) {
            max = g.sequence;
        }
    }
    graph.sequence = max + 1;
    [graphs addObject:graph];
}

- (void) createPageOnSucess: (StorageCallback) callback
{
    SSGraph *graph = [[SSGraph alloc] init];
    [self addPage:graph];
    if (self.storageOption == localStorage)
    {
        graph.objectId = [NSString stringWithFormat:@"book:%@:graph:local:%d",self.objectId, (int)graph.sequence];
        [self saveLocally];
        callback(graph, nil);
    }
    else
    {
        [[SSConnection connector] createObject:[graph toDictionary]
                                        ofType:GRAPH_CLASS
                                     onSuccess:^(id data) {
                                         [graph fromDictionary:data];
                                         callback(graph, nil);
                                     } onFailure:^(NSError *error) {
                                         callback(graph, error);
                                     }
         ];
    }
}

- (void) deletePage:(SSGraph *) graph OnSuccess: (StorageCallback) callback
{
    [graphs removeObject:graph];
    if (self.storageOption == localStorage)
    {
        [graph deleteOnSuccess:^(id data, NSError *error)
         {
             [self saveLocally];
             callback(self, nil);

         }];
    }
    else
    {
        [[SSConnection connector] deleteObjectById:graph.objectId
                                            ofType:GRAPH_CLASS
                                         onSuccess:^(id data) {
                                             callback(data, nil);
                                         } onFailure:^(NSError *error) {
                                             callback(graph, error);
                                         }
         ];
    }
}

- (void) getDetailsOnSucess: (StorageCallback) callback
{
    if (self.storageOption == localStorage)
    {
        [self loadLocally];
        callback(graphs, nil);
    }
    else
    {
        isRefreshing = true;
        NSDate *date = [NSDate date];
        [graphs removeAllObjects];
        
        [[SSConnection connector] getChildren:self.objectId forKey:BOOK
                                       ofType:GRAPH_CLASS
                                        since:nil
                                    onSuccess:^(id data) {
                                        NSArray *graphsFromServer = (NSArray *) data;
                                        for(id graphData in graphsFromServer)
                                        {
                                            [self addPage:[[SSGraph alloc]initWithData:graphData]];
                                        }
                                        refreshedAt = date;
                                        isRefreshing = NO;
                                        callback(graphs, nil);
                                    } onFailure:^(NSError *error) {
                                        callback(nil, error);
                                        isRefreshing = NO;
                                    }];
    }
}

@end
