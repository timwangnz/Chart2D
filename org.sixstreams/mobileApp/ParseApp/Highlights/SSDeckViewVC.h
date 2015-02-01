//
//  SSHightlightsVC.h
//  SixStreams
//
//  Created by Anping Wang on 5/14/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"

@class SSMenuVC;

@protocol SSDeckViewVCDelegate <NSObject>
@optional
- (UIView *) deckViewVC:(id) vc viewFor:(id) item;
- (NSString *) textForVote:(BOOL) vote;
@end

@interface SSDeckViewVC : SSTableViewVC

@property SSMenuVC *menuViewControl;
@property (nonatomic) id <SSDeckViewVCDelegate> delegate;

- (NSArray *) getItemViews;

@end
