//
//  SSValueField.h
//  Medistory
//
//  Created by Anping Wang on 11/9/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSValueField;
@class SSValueEditorVC;

@protocol SSValueFieldDelegate <NSObject>
@required
- (void) valueField : (SSValueField *) valueField valueChanged: (id) item;
@end

@protocol SSFieldEditor <NSObject>
@property (nonatomic, strong) NSString *attrName;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSString *displayValue;
@property (nonatomic, strong) NSString *valueType;
@property BOOL transient;
@property BOOL required;
@end


@interface SSValueField : UITextField<SSFieldEditor>

//value of this attribute
@property (nonatomic, strong) id value;
//formated value shown to the user, could be the same as value
@property (nonatomic, strong) id displayValue;
//entity type, object class name, e.g. org.sixstreams.Company, this is for foriegn key field
@property (nonatomic, strong) NSString *entityType;
//entity type, object class name, e.g. org.sixstreams.Company, this is for foriegn key field
@property (nonatomic, strong) id entity;
//name of the attribute stored in cloud
@property (nonatomic, strong) NSString *attrName;
//if set, text format might change, as well as keyboard type
@property (nonatomic, strong) NSString *metaType;
//if set, number, string
@property (nonatomic, strong) NSString *valueType;
//if it is true, when touched, the value will be
//set as a filter to find similar objects
@property (nonatomic) BOOL filterable;
//if it is ture, it's content will be added to keyword search
@property (nonatomic) BOOL searchable;
@property BOOL readonly;
//if its value is required
@property BOOL required;
@property BOOL transient;

@property (nonatomic) id<SSValueFieldDelegate> valueDelegate;

- (void) processValue:  (id)value;
- (void) preProcessValue:  (id)value;

- (SSValueEditorVC *) getCandidateVC;

@end
