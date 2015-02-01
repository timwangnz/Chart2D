//
//  CoreLovVCViewController.h
//  CoreCrm
//
//  Created by Anping Wang on 11/11/12.
//  Copyright (c) 2012 Anping Wang. All rights reserved.
//

#import "CommonPopupVC.h"
#import "SSAttrCell.h"

@interface SSLovVC : CommonPopupVC

@property (strong, nonatomic) id listOfValues;

- (void) cellEdtior : (SSAttrCell*) cellEditor selectValueFor :(NSString *) lovAttrName;

@end
