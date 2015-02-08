//
//  TweetAdapter.h
//  JobsExchange
//
//  Created by Anping Wang on 3/6/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSTweetAdapter : NSObject
+ (void)tweet:(NSString *) tweet;
+ (BOOL) canSendTweet;
@end
