//
//  SSGraph.h
//  SixStreams
//
//  Created by Anping Wang on 2/7/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSEntityObject.h"
#import "SSBook.h"

@class SSDrawableView;
@class SSShape;
@class SSGraphAction;

@interface SSGraph : SSEntityObject


@property (nonatomic) NSString *name;
@property (nonatomic) SSDrawableView * inView;
@property (nonatomic) SSBook* book;

@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint current;
@property (nonatomic) CGPoint end;
@property (nonatomic) BOOL updated;

@property (readonly) BOOL hasSelection;

@property int sequence;
@property BOOL readonly;

- (void) draw;
- (void) replay;

- (BOOL) undo;
- (BOOL) redo;

- (BOOL) isUndoable;

//add a shape to the graph
- (void) addShape:(SSShape *) shape;
- (void) removeShape:(SSShape *) shape;

//perform an action
- (void) addAction:(SSGraphAction *) action;

- (void) clear;
- (void) save;

//these are not server side actions
- (SSShape *) lastShape;
- (SSShape *) removeLastShape;
- (void) removeAllShapes;

- (id) initWithData:(id) dic;

- (SSShape *) getSelectedShapeAt:(CGPoint) point;
- (void) selectShapesIn:(CGRect) rect;
- (void) deleteSelection;
- (NSArray *) selecedShapes;
- (void) clearSelection;

- (void) getDetailsOnSuccess: (StorageCallback) callback;
- (void) deleteOnSuccess: (StorageCallback) callback;

- (void) startAnimate;
- (void) endAnimate;
- (void) animateStep;

- (void) touchedAt:(CGPoint) pos;

@end
