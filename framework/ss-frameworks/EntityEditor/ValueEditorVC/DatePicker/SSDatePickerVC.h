//
//  SSDatePickerVC.h
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSValueEditorVC.h"

@interface SSDatePickerVC : SSValueEditorVC

@property (nonatomic, strong) IBOutlet UIDatePicker *dpDate;
@property (nonatomic) UIDatePickerMode mode;

@end
