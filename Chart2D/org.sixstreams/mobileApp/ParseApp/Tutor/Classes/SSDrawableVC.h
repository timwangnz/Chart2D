//
//  GLViewVC.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/1/12.
//  Copyright (c) 2012 Oracle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSDrawableLayer.h"
#import "SSBook.h"


#import "SSCommonVC.h"

@protocol GLViewVCDelegate <NSObject>
- (void) graphView:(id) graphView didPerform : (NSString *) cmd;
@end

@interface SSDrawableVC : SSCommonVC<SSDrawableDelegate, UISplitViewControllerDelegate>

@property (nonatomic, retain) id<GLViewVCDelegate> delegate;
@property (weak, nonatomic) UISplitViewController *svc;

@property (weak, nonatomic) SSGraph *graph;
@property (weak, nonatomic) SSBook *book;

- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (IBAction)clear:(id)sender;

- (IBAction)save:(id)sender;
- (IBAction)exportToAlbum:(id)sender;

- (void) changeGraph:(id) object;
- (void) graphWillChange;


@end
