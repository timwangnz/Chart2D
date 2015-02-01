//
//  SSViewWidardVC.h
// Appliatics
//
//  Created by Anping Wang on 7/14/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSEntityEditorVC.h"

@interface SSViewDefWidardVC : SSEntityEditorVC

@property (nonatomic, weak) id application;

+ (SSViewDefWidardVC *) viewWizard:(id) viewDef for:(id) application;

@end
