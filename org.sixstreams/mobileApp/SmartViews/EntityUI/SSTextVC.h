//
//  SSTextVC.h
//  Mappuccino
//
//  Created by Anping Wang on 5/7/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSCommonUtilVC.h"
#import "SSAttrCell.h"

@interface SSTextVC : SSCommonUtilVC
- (void) cellEdtior : (SSAttrCell*) cellEditor selectValueFor :(NSString *) attrDef;

@end
