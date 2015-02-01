//
//  CoreDateLov.h
//  CoreCrm
//
//  Created by Anping Wang on 11/14/12.
//  Copyright (c) 2012 Anping Wang. All rights reserved.
//

#import "CommonPopupVC.h"
#import "SSAttrCell.h"
#import "SSAttrDef.h"

@interface SSDateLovVC : CommonPopupVC

@property UIDatePickerMode datePickerMode;

- (IBAction)onDatePicked:(id)sender;
- (void) cellEdtior : (SSAttrCell*) cellEditor selectValueFor :(NSString *) attrName;

@end
