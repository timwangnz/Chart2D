//
//  SSNavMenuVC.h
//  SixStreams
//
//  Created by Anping Wang on 12/18/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"


@protocol SSNavMenuDelegate <NSObject>
@required
- (void) navMenu:(id) menu itemSelected:(id) item;
@optional
- (void) navMenu:(id) menu itemAdded:(id) item;
@end


@interface SSNavMenuVC : SSTableViewVC
@property (retain, nonatomic) id<SSNavMenuDelegate> delegate;
@property int width;

@end
