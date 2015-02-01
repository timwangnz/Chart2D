//
//  SSGraph.m
//  SixStreams
//
//  Created by Anping Wang on 2/7/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//
#import <Parse/Parse.h>

#import "SSGraph.h"
#import "SSShape.h"
#import "SSConnection.h"
#import "ParseStorageHeader.h"
#import "SSTool.h"
#import "SSProfileVC.h"
#import "SSDrawableView.h"
#import "SSGraphAction.h"
#import "SSStorageManager.h"
#import "SSLinePoint.h"
#import "SSEllipse.h"

@interface SSGraph ()
{
    NSMutableArray *undoSegments;
    NSMutableArray *shapes;
    NSMutableArray *selectedShapes;
    NSMutableArray *actions;
    BOOL isUpdating;
    BOOL isRefreshing;
    NSDate *refreshedAt;
    
    int trackIndex;
    int hIndex;
    CGPoint lastPos;
    BOOL _animating;
}

@property (nonatomic) SSShape * currentShape;

@end

@implementation SSGraph

#define SHAPE_KEY @"shapes"

- (void) save
{
    if (self.book.storageOption != localStorage)
    {
        //[action save]; we should save all the actions that are not saved yet
    }
    else{
        [self saveLocally];
    }
}

- (void) loadLocally
{
    NSDictionary *dic = [[SSStorageManager storageManager] read :self.objectId];
    if (dic == nil)
    {
        return;
    }
    
    NSDictionary *data = [dic objectForKey:@"head"];
    [self fromDictionary:data];
    NSArray *shapeData = [dic objectForKey:@"shapes"];
    [self removeAllShapes];
    for (id data in shapeData) {
        SSShape *shape = [SSTool fromDictionary:data];
        shape.graph = self;
        [self addShape:shape];
    }
}

- (void) saveLocally
{
    if (_animating)
    {
        return;
    }
    
    NSMutableDictionary *savedDic = [NSMutableDictionary dictionary];
    [savedDic setObject:[self toDictionary] forKey:@"head"];
    NSMutableArray *shapeData = [NSMutableArray array];
    
    for (SSShape *shape in shapes)
    {
        [shapeData addObject:[shape toDictionary]];
    }
    
    [savedDic setObject:shapeData forKey:@"shapes"];
    [[SSStorageManager storageManager] save:savedDic uri:self.objectId];
}

- (id) init
{
    self = [super init];
    if(self)
    {
        shapes = [NSMutableArray array];
        selectedShapes = [NSMutableArray array];
        _hasSelection = NO;
    }
    return self;
}

- (BOOL) undo
{
    if (![self isUndoable])
    {
        return NO;
    }
    id last = [self removeLastShape];
    if(!undoSegments)
    {
        undoSegments = [NSMutableArray array];
    }
    [undoSegments addObject:last];
    self.updated = YES;
    return YES;
}

- (BOOL) redo
{
    if ([undoSegments count] == 0)
    {
        return NO;
    }
    
    id last = [undoSegments lastObject];
    
    [self addShape:last];
    [undoSegments removeLastObject];
    self.updated = YES;
    return YES;
}

- (void) setCurrent:(CGPoint)current
{
    _current = current;
    if ([selectedShapes count] > 0) {
        for(SSShape *shape in selectedShapes)
        {
            [shape moveInX:_current.x - self.start.x andY:_current.y - self.start.y];
        }
    }
}

- (void) setEnd:(CGPoint)end
{
    _end = end;
    if ([selectedShapes count] > 0)
    {
        for(SSShape *shape in selectedShapes)
        {
            [shape moveToX:_end.x - self.start.x andY:_end.y - self.start.y];
        }
    }
}

- (void) setUpdated:(BOOL)updated
{
    _updated = updated;
    
    if (updated) {
        if (self.book.storageOption == localStorage)
        {
            [self saveLocally];
        }
    }
}

- (id) initWithData:(id) dic
{
    self = [self init];
    [self fromDictionary:dic];
    return self;
}

- (void) draw
{
    for(int j=0;j< [shapes count]; j++)
    {
        SSShape *shape = [shapes objectAtIndex:j];
        if (!shape.hidden)
            [shape draw];
    }
}

- (BOOL) isUndoable
{
    if (self.readonly) {
        return NO;
    }
    return [shapes count] > 0;
}

- (SSShape *) removeLastShape
{
    SSShape *last = [shapes lastObject];
    [shapes removeLastObject];
    return last;
}

- (NSArray *) selecedShapes
{
    return selectedShapes;
}

- (void) clearSelection
{
    for(SSShape *exist in selectedShapes)
    {
        exist.isSelected = NO;
    }
    _hasSelection = NO;
    [selectedShapes removeAllObjects];
}

- (void) selectShapesIn:(CGRect) rect
{
    [self clearSelection];
    for(SSShape *shape in shapes)
    {
        shape.isSelected = CGRectIntersectsRect(rect, shape.bounds);
        if(shape.isSelected)
        {
            [selectedShapes addObject:shape];
        }
    }
    _hasSelection = [selectedShapes count] > 0;
}

- (SSShape *) getSelectedShapeAt:(CGPoint) point
{
    SSShape *selected = nil;
    for(SSShape *shape in shapes)
    {
        BOOL isOn = [shape isPointOn:point];
        if (isOn && shape.isSelected) {
            selected = shape;
        }
    }
    return selected;
}

- (void) addAction:(SSGraphAction *) action
{
    
    [actions addObject:action];
    
    if (self.book.storageOption != localStorage)
    {
        [action save];
    }
    else{
     //   [self saveLocally];
    }
     
}

-(void) addShape:(SSShape *) shape
{
    if (shape == nil)
    {
        return;
    }
    [self clearSelection];
    for(SSShape *exist in shapes)
    {
        if([exist.objectId isEqualToString:shape.objectId])
        {
            shape.graph = self;
            self.currentShape = shape;
            [shapes replaceObjectAtIndex:[shapes indexOfObject:exist] withObject:shape];
            return;
        }
    }
    self.currentShape = shape;
    shape.graph = self;
    shape.sequence = [shapes count];
    [shapes addObject:shape];
}

- (void) removeShape:(SSShape *) shape
{
    [shapes removeObject:shape];
    [selectedShapes removeObject:shape];
    _hasSelection = [selectedShapes count] > 0;
}

- (SSShape *) lastShape
{
    return [shapes lastObject];
}

- (void) removeAllShapes
{
    [shapes removeAllObjects];
    //self.updated = YES;
}

- (void) fromDictionary:(NSDictionary *) dic
{
    [super fromDictionary:dic];
    if ([self.updatedAt isEqual:refreshedAt]) {
        return;
    }
    [shapes removeAllObjects];
    self.readonly = self.book.storageOption != localStorage && ![[dic objectForKey:AUTHOR] isEqualToString:[SSProfileVC profileId]];
    self.name = [dic objectForKey:NAME];
}

- (id) toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    [dic setValue:self.book.objectId forKey:BOOK];
    [dic setValue :self.name forKey:NAME];
    return dic;
}

- (NSString *) getEntityType
{
    return GRAPH_CLASS;
}

- (void) clear
{
    SSGraphAction *deleteAction = [[SSGraphAction alloc]init];
    deleteAction.graph = self;
    deleteAction.action = @"c";
    [self removeAllShapes];
    if (self.book.storageOption != localStorage)
    {
        [[SSConnection connector] deleteChildren:self.objectId forKey:@"graph"
                                          ofType:ACTION_CLASS
                                       onSuccess:^(id data) {
                                           [deleteAction save];
                                       } onFailure:^(NSError *error) {
                                           //
                                       }];
    }
    self.updated = YES;
}

- (void) replay
{
    NSArray *array = [NSArray arrayWithArray:shapes];
    [shapes removeAllObjects];
    for(SSShape *shape in array)
    {
        [shapes addObject:shape];
        [shape replay];
    }
}

- (void) deleteShapeById:(NSString *) shapeId
{
    if (self.book.storageOption != localStorage){
        [[SSConnection connector] deleteObjectById:shapeId ofType:ACTION_CLASS];
    }
    else{
        [self saveLocally];
    }
}

- (void) deleteSelection
{
    for (SSShape *shape in selectedShapes)
    {
        [shapes removeObject:shape];
        [self deleteShapeById:shape.objectId];
    }
    [selectedShapes removeAllObjects];
    _hasSelection = NO;
    [self.inView setNeedsLayout];
}

- (void) processNewItem:(NSArray *) shapesFromServer
{
    if ([shapesFromServer count] > 0)
    {
        for(id item in shapesFromServer)
        {
            NSString *action = [item objectForKey:@"action"];
            if ([action isEqualToString:@"a"])
            {
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[item objectForKey:@"data"]];
                [data setObject:[item objectForKey:REF_ID_NAME] forKey:REF_ID_NAME];
                SSShape *shape = [SSTool fromDictionary:data];
                shape.graph = self;
                [self addShape:shape];
            }
            else if ([action isEqualToString:@"c"])
            {
                [self removeAllShapes];
            }
        }
        [self.inView setNeedsLayout];
    }
}

- (void) deleteOnSuccess: (StorageCallback) callback
{
    if (self.book.storageOption == localStorage)
    {
        [[SSStorageManager storageManager] delete :self.objectId];
        callback(self, nil);
    }
    else
    {
        [self deleteOnSuccess:^(id data) {
            callback(data, nil);
        } onFailure:^(NSError *error) {
            callback(nil, error);
        }];
    }
}

- (void) getDetailsOnSuccess: (StorageCallback) callback
{
    if (self.book.storageOption == localStorage)
    {
        [self loadLocally];
        callback(shapes, nil);
    }
    else
    {
        NSDate *date = [NSDate date];
        [[SSConnection connector] getChildren:self.objectId forKey:GRAPH
                                       ofType:ACTION_CLASS
                                        since:nil
                                    onSuccess:^(id data) {
                                        actions = data;
                                        [self processNewItem:data];
                                        refreshedAt = date;
                                        isRefreshing = NO;
                                        callback(shapes, nil);
                                    } onFailure:^(NSError *error) {
                                        callback(nil, error);
                                        isRefreshing = NO;
                                    }];
    }
    
}

- (void) getShapes
{
    NSDate *date = [NSDate date];
    [[SSConnection connector] getChildren:self.objectId forKey:GRAPH
                                   ofType:ACTION_CLASS
                                    since:refreshedAt
                                onSuccess:^(id data) {
                                    [self processNewItem:data];
                                    refreshedAt = date;
                                    isRefreshing = NO;
                                } onFailure:^(NSError *error) {
                                    isRefreshing = NO;
                                }];
}

- (void) refreshFromServer
{
    if (isUpdating || isRefreshing)
    {
        return;
    }
    isRefreshing = YES;
    [self getShapes];
}


- (void) touchedAt:(CGPoint) pos
{
    for (SSShape *shape in shapes) {
        if ([shape isKindOfClass:[SSEllipse class]]) {
            shape.start = CGPointMake(shape.start.x, shape.start.y + 30);
            shape.end = CGPointMake(shape.end.x, shape.end.y + 30);
            [shape moveToX:0 andY:0];
        }
    }
    
}

//animation start
- (void) startAnimate
{
    for (SSShape *shape in shapes) {
        shape.hidden = NO;
    }
    _animating = YES;
    trackIndex = 0;
    hIndex = 0;
}
//end animation
- (void) endAnimate
{
    for (SSShape *shape in shapes) {
        if ([shape isKindOfClass:[SSEllipse class]]) {
            CGPoint oldP = shape.lastPos;
            [shape moveToX:oldP.x andY:oldP.y];
        }
    }
    _animating = NO;
    trackIndex = 0;
}

- (void) animateStep
{
    hIndex++;
    if ([self isCollide]) {
        return;
    }
    
    float ratio = .4;
    
    for (SSShape *shape in shapes) {
        if ([shape isKindOfClass:[SSEllipse class]]) {
            float vspeed = ratio*self.inView.bounds.size.height/(shape.bounds.size.height);
            CGPoint newP = CGPointMake(0, -vspeed);
            
            if (shape.end.y < 0) {
                newP = CGPointMake(newP.x, self.inView.bounds.size.height + shape.bounds.size.height);
            }
            [shape moveToX:newP.x andY:newP.y];
        }
        else if (![shape isKindOfClass:[SSEllipse class]]) {
            float hspeed = ratio*20;
            CGPoint newP = CGPointMake(-hspeed, 0);
            
            if (shape.bounds.origin.x + shape.bounds.size.width < 0) {
                newP = CGPointMake(self.inView.frame.size.width + shape.bounds.size.width + 20, 0);
            }
            [shape moveToX:newP.x andY:newP.y];
        }
    }
}


- (BOOL) isCollide
{
    SSEllipse *bird = nil;
    for (SSShape *shape in shapes) {
        if ([shape isKindOfClass:[SSEllipse class]]) {
            bird = (SSEllipse*)shape;
            break;
        }
    }
    
    for (SSShape *shape in shapes) {
        if (shape != bird) {
            if ([shape collideWith:bird]) {
                [self.inView stopAnimation];
            }
        }
    }
    return NO;
}

@end
