//
//  SSOptionsEditor.h
//  SixStreams
//
//  Created by Anping Wang on 6/8/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSValueField.h"

@interface SSOptionsEditor : UISegmentedControl<SSFieldEditor>

@property (nonatomic, strong) NSString *attrName;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSString *displayValue;
@property (nonatomic, strong) NSString *valueType;
@property BOOL transient;
@property BOOL required;
@end
