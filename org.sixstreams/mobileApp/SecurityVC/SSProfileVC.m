//
//  WCProfileVC.m
//  Mappuccino
//
//  Created by Anping Wang on 4/9/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSProfileVC.h"
#import "SSLoginVC.h"
#import "SSJSONUtil.h"
#import "ObjectTypeUtil.h"


@interface SSProfileVC ()
{
    BOOL changed;
}
@end

@implementation SSProfileVC

- (BOOL) isGroupEditable:(NSString *) groupName
{
    return self.editable;
}

- (void) logout
{
    [SSLoginVC signoff:self];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) removeAccount
{
    [SSLoginVC removeAccount:self];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.profile)
    {
        self.profile = [SSLoginVC getProfile];
    }
    self.objectType = PROFILE_TYPE;
    self.entity = self.profile;
    SSAttrDefGroup *nameGroup = [self addAttrGroup:@"Name" ofType:self.objectType forObject:self.entity];
    
    [nameGroup addAttrDef:@"jobTitle" ofType:SSStringType];
    [nameGroup addAttrDef:@"firstName" ofType:SSStringType];
    [nameGroup addAttrDef:@"lastName" ofType:SSStringType];
    [nameGroup addAttrDef:@"email" ofType:SSStringType andMetaType:SSEmail];
    [nameGroup addAttrDef:@"phone" ofType:SSStringType andMetaType:SSPhone];
    
    SSAttrDefGroup *addressGroup = [self addAttrGroup:@"Address" ofType:self.objectType forObject:self.entity];
    
    addressGroup.isAddress = YES;
    [addressGroup addAttrDef:@"street1" ofType:SSStringType];
    [addressGroup addAttrDef:@"city" ofType:SSStringType];
    SSAttrDef *state = [addressGroup addAttrDef:@"state" ofType:SSStringType];
    state.lov = [ObjectTypeUtil listOfValues:@"state" ofType: PROFILE_TYPE];
    [addressGroup addAttrDef:@"country" ofType:SSStringType];
    
    
    self.title = @"Profile";
    [super edit: self.entity];
    if(self.editable)
    {
        SSAttrDefGroup *actionGroup = [self addAttrGroup:@"Logout" ofType:self.objectType forObject:self.entity];
        actionGroup.hideHeader = YES;
        [actionGroup addAttrDef:@"Logout" ofType:SSActionType].onAction = ^(id attrDef)
        {
            [self logout];
        };
        
        actionGroup = [self addAttrGroup:@"Remove" ofType:self.objectType forObject:self.entity];
        actionGroup.hideHeader = YES;
        
        SSAttrDef *attrDef = [actionGroup addAttrDef:@"Remove Account" ofType:SSActionType];
        attrDef.onAction = ^(id attrDef)
        {
            [self removeAccount];
        };
        
        attrDef.backgroundColor = [UIColor redColor];
    }
}

@end
