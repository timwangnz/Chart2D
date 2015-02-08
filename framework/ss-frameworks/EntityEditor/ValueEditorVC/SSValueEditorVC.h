//
//  SSValueEditorVCViewController.h
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSCommonVC.h"
#import "SSValueField.h"


@interface SSValueEditorVC : SSCommonVC
{
    
}

@property (nonatomic, strong) id contextObject;
@property (nonatomic, strong) SSValueField *field;
@property (nonatomic, strong) SSCommonVC *parentVC;


- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

- (id) initWithValueField:(SSValueField *) valueField;

@end
