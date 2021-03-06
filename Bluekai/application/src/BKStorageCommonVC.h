//
//  StorageCommonVC.h
//  BluekaiDemo
//
//  Created by Anping Wang on 4/25/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SqlGraphView.h"

@interface BKStorageCommonVC : UIViewController
{
    IBOutlet UITableView *tableview;
    id dataReceived;
    NSMutableArray *objects;
    NSMutableArray *filteredObjects;
    NSNumberFormatter *formatter;
    NSDateFormatter *dateFormatter;
    IBOutlet SqlGraphView *trend;

}
@property NSString * sql;
@property NSString *titleField;
@property NSString *detailField;
@property int limit;
@property UITableViewCellStyle cellStyle;
@property int cacheTTL;

- (void) getData;
- (void) didFinishLoading: (id)data;

- (NSString *) objectTitle : (id) object;
- (NSString *) objectDetail : (id) object;
- (NSString *) today;
- (void) updateModel;

- (NSString *) formatValue:(id) value;

- (void) invalidateCache;

@end
