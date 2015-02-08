//
//  SSMasterDetailsVC.m
// Appliatics
//
//  Created by Anping Wang on 10/7/13.
//  Copyright (c) 2013 Oracle. All rights reserved.
//

#import "SSMasterDetailsVC.h"
#import "SSTableViewVC.h"

@interface SSMasterDetailsVC ()<SSTableViewVCDelegate, SSEntityEditorDelegate>

@end

@implementation SSMasterDetailsVC

- (void) entityDidSave:(id) object
{
  vDetails.hidden = ![self.item2Edit objectForKey:REF_ID_NAME];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self setupDetailsVC];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    vDetails.hidden = ![self.item2Edit objectForKey:REF_ID_NAME];
}

- (void) setupDetailsVC
{
    tvDetails.tableViewDelegate = self;
    tvDetails.alterRowBackground = YES;
}

- (void) tableViewVC:(id)tableViewVC showEditor:(SSEntityEditorVC *)editor
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:editor animated:YES];
    
}


- (void) entityEditor:(id)editor didSave:(id)entity
{
    [tvDetails forceRefresh];
    if (self.entityEditorDelegate)
    {
        [self.entityEditorDelegate entityEditor:editor didSave:entity];
    }
}

- (void) tableViewVC:(id) tableViewVC didDelete : (id) entity
{
    [tvDetails forceRefresh];
    if (self.entityEditorDelegate)
    {
        [self.entityEditorDelegate entityEditor:tableViewVC didSave:entity];
    }
}

@end
