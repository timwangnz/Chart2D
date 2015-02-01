//
//  SSGraphAction.h
//  SixStreams
//
//  Created by Anping Wang on 2/13/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSEntityObject.h"
#import "SSShape.h"
#import "SSGraph.h"

@interface SSGraphAction : SSEntityObject

@property (nonatomic) SSShape* shape;
@property (nonatomic) NSString *action;
@property (nonatomic) SSGraph *graph;

@end
