//
// AppliaticsObjectTypeVC.m
// Appliatics
//
//  Created by Anping Wang on 9/30/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSObjectTypeVC.h"
#import "SSObjectTypeEditorVC.h"
#import "AttributeValue.h"
#import "IconsLayoutView.h"
#import "SSConnection.h"

@interface SSObjectTypeVC ()<SSEntityEditorDelegate>
{
    IBOutlet SSTableViewVC *tfObjectFields;
    IBOutlet IconsLayoutView *ilvObjects;
}

@end

@implementation SSObjectTypeVC


+ (id) getObjectTypes
{
    SSConnection *syncher = [SSConnection connector];
    return [syncher getObjects:nil
                           ofType:OBJECT_TYPE
                          orderBy:SEQUENCE
                        ascending:YES
                           offset:0
                            limit:2000
            timeout:1000
            ];
    
}

+ (id) getObjectType:(NSString *) objectTypeName
{
    SSConnection *syncher = [SSConnection connector];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", objectTypeName];
    
    NSArray *items = [syncher getObjects:predicate
                              ofType:OBJECT_TYPE
                             orderBy:SEQUENCE
                           ascending:YES
                              offset:0
                                     limit:200 timeout:1000];

    if ([items count] ==1)
    {
        id objectType = [items objectAtIndex:0];
        predicate = [NSPredicate predicateWithFormat:@"objectTypeId=%@", [objectType objectForKey:REF_ID_NAME]];
        NSArray *fields = [syncher getObjects:predicate
                                      ofType:OBJECT_FIELD
                                     orderBy:SEQUENCE
                                   ascending:YES
                                      offset:0
                                       limit:1000 timeout:1000];
        [objectType setObject:fields forKey:@"fields"];
        return objectType;
    }
    else
    {
        return nil;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.objectType = OBJECT_TYPE;
        self.title = @"Select Object Type";
        self.addable = YES;
        self.cancellable = YES;
    }
    return self;
}

- (SSEntityEditorVC *) createEditorFor:(id) item
{
    SSObjectTypeEditorVC *editor = [[SSObjectTypeEditorVC alloc]init];
    editor.entityEditorDelegate = self;
    editor.item2Edit = item;
    editor.itemType = self.objectType;
    return editor;
}

- (void) entityEditor:(id)editor didSave:(id)entity
{
    [self forceRefresh];
}

- (void) cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void) setItems
{
    if (self.objects)
    {
        NSMutableArray *iconData = [NSMutableArray array];
        for (id object in self.objects)
        {
            AttributeValue *attributeValue = [[AttributeValue alloc]init];
            attributeValue.displayName = [object objectForKey:NAME];
            attributeValue.iconImg = @"Accounts";
            
            attributeValue.name = [object objectForKey:NAME];
            
            [iconData addObject:attributeValue];
        }
        [ilvObjects setItems:iconData];
    }
    
}

- (NSString *) getCellText:(id) item atCol:(int) col
{
    return [item objectForKey:NAME];
}


@end
