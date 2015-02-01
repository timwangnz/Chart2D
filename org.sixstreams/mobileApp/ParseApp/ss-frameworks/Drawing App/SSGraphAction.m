//
//  SSGraphAction.m
//  SixStreams
//
//  Created by Anping Wang on 2/13/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSGraphAction.h"
#import "SixStreams.h"

@implementation SSGraphAction

- (NSString *) getEntityType
{
    return ACTION_CLASS;
}

- (id) toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject:self.graph.objectId forKey:@"graph"];
    [dic setObject:self.action forKey:@"action"];
    [dic setObject:[NSNumber numberWithInt:(int)self.sequence] forKey:SEQUENCE];
    if (self.graph.book)
    {
        [dic setObject:self.graph.book.objectId forKey:@"book"];
    }
    
    if(self.shape)
    {
        [dic setObject:[self.shape toDictionary] forKey:@"data"];
    }
    
    return dic;
}

- (void) onSaved:(id)data
{
    if(self.shape)
    {
        self.shape.objectId = [data objectForKey:REF_ID_NAME];
        self.shape.authorId = [data objectForKey:AUTHOR];
    }
}

@end
