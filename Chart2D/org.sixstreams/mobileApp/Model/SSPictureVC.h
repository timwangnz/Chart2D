//
//  WCPictureVC.h
//  Mappuccino
//
//  Created by Anping Wang on 3/23/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSClientTableVC.h"

@interface SSPictureVC : SSClientTableVC

@property (nonatomic, retain) NSString *parentId;
@property (nonatomic, retain) NSString *parentType;

- (void) setCurrentIndex:(int) index;

@end
