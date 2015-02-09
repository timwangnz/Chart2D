//
//  SSReferenceEditorVC.m
//  SixStreams
//
//  Created by Anping Wang on 1/1/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSReferenceEditorVC.h"
#import "SSTableViewVC.h"
#import "SSReferenceTextField.h"

@interface SSReferenceEditorVC ()
{
    
}

@end

@implementation SSReferenceEditorVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.objectVC.objectType = self.fieldEditor.objectType;
    
    self.objectVC.listOfValueDelegate = self.fieldEditor;
    self.objectVC.tableViewDelegate = self.fieldEditor;
    
    [self.objectVC forceRefresh];
}

@end
