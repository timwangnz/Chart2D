//
//  SSReferenceEditorVC.h
//  SixStreams
//
//  Created by Anping Wang on 1/1/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSValueEditorVC.h"

#import "SSTableViewVC.h"

@class SSReferenceTextField;

@interface SSReferenceEditorVC : SSValueEditorVC

@property (nonatomic, strong) IBOutlet SSTableViewVC *objectVC;
@property (nonatomic, strong) SSReferenceTextField * fieldEditor;

@end
