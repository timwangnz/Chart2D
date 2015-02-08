//
//  SSAppSetupVC.m
//  SixStreams
//
//  Created by Anping Wang on 12/25/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSAppSetupVC.h"
#import "SSValueField.h"
#import "SSImageView.h"

@interface SSAppSetupVC ()
{
    IBOutlet SSImageView *imView;
    IBOutlet UISegmentedControl *sgcSecurity;
    IBOutlet SSValueField *tfDomain;
    IBOutlet SSValueField *tfOrg;
    IBOutlet SSValueField *tfClientKey;
    IBOutlet SSValueField *tfAppId;
}

@end

@implementation SSAppSetupVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.itemType = NETWORK_CLASS;
        self.tabBarItem.image = [UIImage imageNamed:@"111-user.png"];
        self.readonly = NO;
        self.title = @"Create Network";
    }
    return self;
}

- (void) hideMe
{
    if (!self.navigationController)
    {
        [UIView animateWithDuration:2 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            self.view.hidden = YES;
        }];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)cancel
{
    [self hideMe];
}

- (void) entityDidSave:(id)object
{
    [self hideMe];
}

- (BOOL) entityShouldSave:(id)object
{
    if ([tfOrg.text length]==0)
    {
        [self showAlert:@"Network Name is required" withTitle:@"Error"];
        return NO;
    }
    return YES;
    
}
- (void) uiWillUpdate:(id)object
{
    tfOrg.attrName = NAME;
    tfClientKey.attrName = APPLICATION_KEY;
    tfAppId.attrName = APPLICATION_ID;
    tfDomain.attrName = DOMAIN_NAME;
}

- (void) entityWillSave:(id)entity
{
    //[entity setObject:tfOrg.text forKey:NAME];
    //[entity setObject:tfDomain.text forKey:DOMAIN_NAME];
    [entity setValue:[NSNumber numberWithInt : (int) sgcSecurity.selectedSegmentIndex] forKey:PRIVACY];
    //[entity setObject:tfAppId.text forKey:APPLICATION_ID];
    //[entity setObject:tfClientKey.text forKey:APPLICATION_KEY];
    
}


@end
