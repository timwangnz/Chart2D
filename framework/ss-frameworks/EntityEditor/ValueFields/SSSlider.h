//
//  SSSlider.h
//  SixStreams
//
//  Created by Anping Wang on 6/22/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSValueField.h"

@interface SSSlider : UISlider

@property (nonatomic, strong) NSString *attrName;
//number of digits to preserve
@property int precision;

@end
