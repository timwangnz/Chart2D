//
//  SSCallbackEvent.m
//  Mappuccino
//
//  Created by Anping Wang on 4/9/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSCallbackEvent.h"
@implementation SSCallbackEvent

- (NSString *) description
{
    return [NSString stringWithFormat:@"status:%d\nurl:%@\ncontext:%@", self.callingStatus, self.uri, self.callerContext];
}
@end