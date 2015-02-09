//
//  SSReferenceTextField.h
//  SixStreams
//
//  Created by Anping Wang on 1/1/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSValueField.h"
#import "SSTableViewVC.h"


@interface SSReferenceTextField : SSValueField<SSListOfValueDelegate, SSTableViewVCDelegate>

@property (nonatomic, strong) NSString *objectType;
@property (nonatomic, strong) NSArray *predicates;

@end
