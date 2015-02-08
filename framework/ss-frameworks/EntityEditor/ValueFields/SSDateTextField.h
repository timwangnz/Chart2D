//
//  DateTextField.h
//  MyPacCoach
//
//  Created by Anping Wang on 11/7/11.
//  Copyright (c) 2011 s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSValueField.h"


@interface SSDateTextField : SSValueField;

@property UIDatePickerMode mode;
@property (nonatomic) NSString *dateInit;

@end
