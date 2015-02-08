//
//  RoundTextView.h
//  Medistory
//
//  Created by Anping Wang on 11/12/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSValueField.h"

@interface SSRoundTextView : UITextView<SSFieldEditor>

@property (nonatomic) float cornerRadius;
@property (nonatomic, strong) NSString *attrName;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSString *displayValue;
@property (nonatomic, strong) NSString *valueType;
@property BOOL transient;
@property BOOL required;
- (void) autofit;
@end
