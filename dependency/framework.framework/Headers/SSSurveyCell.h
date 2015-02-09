//
//  SSSurveyCell.h
//  SixStreams
//
//  Created by Anping Wang on 7/28/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSSurveyCell : UITableViewCell

@property id item;

@property UITableView *tableview;

-(void) updateCell:(id) item;
@end
