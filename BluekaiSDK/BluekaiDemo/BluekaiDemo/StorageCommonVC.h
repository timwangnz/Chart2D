//
//  StorageCommonVC.h
//  BluekaiDemo
//
//  Created by Anping Wang on 4/25/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StorageCommonVC : UIViewController
{
    IBOutlet UITableView *tableview;
    id dataReceived;
    NSMutableArray *objects;
    NSMutableArray *filteredObjects;
    NSNumberFormatter *formatter;

}
@property NSString * sql;
@property NSString *titleField;
@property NSString *detailField;
@property int limit;

- (void) getData;
- (void) didFinishLoading: (id)data;

- (NSString *) objectTitle : (id) object;
- (NSString *) objectDetail : (id) object;
- (NSString *) today;
- (void) updateModel;
@end
