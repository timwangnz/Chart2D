//
//  LovTextField.h
//
//  Created by Anping Wang on 11/10/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTableLovVC.h"
#import "SSValueField.h"
#import "SSSearchVC.h"

@class SSLovTextField;

@protocol SSLovTextFieldDelegate <NSObject>
@required
- (NSDictionary *) listOfValuesFor : (SSLovTextField *) lovField;
@end

@interface SSLovTextField : SSValueField<SSListOfValueDelegate>

//used to get display name in the list
@property (nonatomic, strong) NSString *titleKey;
@property (nonatomic, strong) NSString *predicate;

//if set, its value will be used to pull the reference id, otherwise, refid is used
@property (nonatomic, strong) NSString *attrId;

//Static list of values to pick from
@property (nonatomic, strong) NSDictionary *listOfValues;

//whether multiple value is allowed for this field, stored as an array
@property (nonatomic) BOOL allowMultiValues;
//
//whether user can add values to the list
//only applicable if the list is from server
//
@property (nonatomic) BOOL canAddToLov;

@property (nonatomic, strong) id<SSLovTextFieldDelegate> lovDelegate;

@end
