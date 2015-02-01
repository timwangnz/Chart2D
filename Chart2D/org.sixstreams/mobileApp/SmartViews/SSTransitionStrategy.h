//
//  SSTransitionStrategy.h
//  SixStreams
//
//  Created by Anping Wang on 5/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSTransitionStrategy : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic) bool reverse;

@end
