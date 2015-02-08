//
//  SSSurveyVC.h
//  SixStreams
//
//  Created by Anping Wang on 7/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSCommonVC.h"

@interface SSSurveyVC : SSCommonVC<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDictionary *items;
@property BOOL sectioned;
@end
