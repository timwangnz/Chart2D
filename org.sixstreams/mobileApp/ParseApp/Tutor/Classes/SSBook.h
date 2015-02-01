//
//  SSBook.h
//  SixStreams
//
//  Created by Anping Wang on 2/15/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSEntityObject.h"
#define BOOK_CLASS @"org.sixstreams.tutor.Book"

@class SSGraph;

@interface SSBook : SSEntityObject

@property (nonatomic) NSString *category;
@property (nonatomic) NSString *name;

@property BOOL isOnline;

@property StorageOption storageOption;

- (id) initWithData:(id) dic;

- (void) addPage:(SSGraph *) graph;

- (SSGraph *) getFirstPage;
- (SSGraph *) getPageAtIndex:(NSInteger) index;
- (NSInteger) pages;

- (void) getDetailsOnSucess: (StorageCallback) callback;
- (void) createPageOnSucess: (StorageCallback) callback;
- (void) deletePage:(id) graph OnSuccess: (StorageCallback) callback;

@end
