//
//  SSDateTimeView.h
//  SixStreams
//
//  Created by Anping Wang on 8/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSDateTimeView : UIView

@property (nonatomic, retain) NSDate *datetime;

@property IBOutlet UILabel *day;
@property IBOutlet UILabel *date;
@property IBOutlet UILabel *time;


@end
