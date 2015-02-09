//
//  SSTableRowCell.h
//  SixStreams
//
//  Created by Anping Wang on 12/8/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCalendarCell.h"


@interface SSTableRowCell : UITableViewCell<SSCalendarCellDelegate>
{
    IBOutlet SSCalendarCell *vSunday;
    IBOutlet SSCalendarCell *vMonday;
    IBOutlet SSCalendarCell *vTuesday;
    IBOutlet SSCalendarCell *vWednsday;
    IBOutlet SSCalendarCell *vThursday;
    IBOutlet SSCalendarCell *vFriday;
    IBOutlet SSCalendarCell *vSaturday;
}

@property (nonatomic, retain) id<SSCalendarCellDelegate> delegate;
@property int week;
@property int month;
@property int year;

- (void) reloadData;

@end
