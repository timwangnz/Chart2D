//
//  SSMasterDetailsVC.h
// Appliatics
//
//  Created by Anping Wang on 10/7/13.
//  Copyright (c) 2013 Oracle. All rights reserved.
//

#import "SSEntityEditorVC.h"

@class SSTableViewVC;

@interface SSMasterDetailsVC : SSEntityEditorVC
{
    IBOutlet SSTableViewVC *tvDetails;
    IBOutlet UIView *vDetails;
}

@end
