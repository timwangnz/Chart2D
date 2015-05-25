//
//  SSvalueLabel.h
//  SixStreams
//
//  Created by Anping Wang on 5/24/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSRoundLabel.h"

@interface SSValueLabel : SSRoundLabel

@property (nonatomic, strong) NSString *attrName;
@property (nonatomic, strong) NSString *defaultValue;
@property (nonatomic, strong) NSString *metaType;
@property float rate;
@end
