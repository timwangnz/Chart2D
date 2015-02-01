//
//  SSGraphsVC.h
//  SixStreams
//
//  Created by Anping Wang on 2/1/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"
#import "SSDrawableVC.h"

@interface SSBooksVC : SSTableViewVC<GLViewVCDelegate>

@property (nonatomic, retain) SSDrawableVC *detailVC;

@end
