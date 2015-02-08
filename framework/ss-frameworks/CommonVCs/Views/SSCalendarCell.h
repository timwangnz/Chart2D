//
//  SSCalendarCell.h
//  SixStreams
//
//  Created by Anping Wang on 12/9/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSCalendarCell;

@protocol SSCalendarCellDelegate <NSObject>
- (void) callendarCell:(SSCalendarCell *) tableView didSelect : (id) entity;
- (NSArray *) getEvents:(SSCalendarCell *) tableView;
@end

@interface SSCalendarCell : UIView

@property (nonatomic, retain) NSString *header;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) id<SSCalendarCellDelegate> delegate;

@property BOOL inMonth;
@property BOOL isHeader;

@property (nonatomic, retain) id data;


- (void) reloadData;

@end
