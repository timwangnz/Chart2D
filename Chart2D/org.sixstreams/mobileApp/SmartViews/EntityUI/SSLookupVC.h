//
//  SSLookupVC.h
//  Mappuccino
//
//  Created by Anping Wang on 5/9/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSClientTableVC.h"
#import "SSAttrDef.h"
#import "SSAttrCell.h"

@interface SSLookupVC : SSClientTableVC

@property (strong, nonatomic) SSAttrDef *attrDef;
@property (strong, nonatomic) SSAttrCell *cellEditor;

@end
