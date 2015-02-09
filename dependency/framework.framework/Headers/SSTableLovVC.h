//
//  TableLovVC.h
//  JobsExchange
//
//  Created by Anping Wang on 3/4/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSValueEditorVC.h"
#import "SSConnection.h"

@class SSTableLovVC;
@class SSSearchVC;

@protocol SSTableLovDelegate <NSObject>
@required
- (void) tableLov : (SSTableLovVC *) tableLov didSelect: (id) item;
@optional
- (UITableViewCell *) tableLov: (SSTableLovVC *) tableLov getCellFor :(id) item;
@end

@interface SSTableLovVC : SSValueEditorVC<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) id<SSTableLovDelegate> tableLovDelegate;
@property (nonatomic, strong) NSDictionary *items;
@property (nonatomic, strong) SSSearchVC *searchVC;
@property (nonatomic, strong) NSString *attrId;

@property BOOL addable;

- (void) loadDataOnSuccess:(SuccessCallback) callback;


@end
