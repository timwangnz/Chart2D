//
//  SSInviteUserVC.m
//  SixStreams
//
//  Created by Anping Wang on 3/6/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSInviteUserVC.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "SSValueField.h"
#import "SSProfileVC.h"
#import "SSApp.h"

@interface SSInviteUserVC ()<ABPeoplePickerNavigationControllerDelegate>
{
    IBOutlet SSValueField *tfEmail;
}

@end

@implementation SSInviteUserVC

- (IBAction)testUrl:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"GLUE://user/invitation?id=9Ogfctq5xN"]];

}

- (BOOL) entityShouldSave:(id)object
{
    if (tfEmail.text == nil || [tfEmail.text length] == 0)
    {
        [self showAlert:@"Email is required for sending an invite" withTitle:@"Error"];
    }
    
    return YES;
}

- (void) entityDidSave:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Invite Friends";
        self.readonly = YES;
        self.itemType = INVITATION_CLASS;
    }
    return self;
}

- (void) entityWillSave:(id)entity
{
    [entity setValue:tfEmail.text forKey:EMAIL];
    [entity setValue:[SSProfileVC name] forKey: @"invitedBy"];
    [entity setValue:[SSApp instance].name forKey:@"appName"];
    
}

- (void) uiWillUpdate:(id)object
{
    tfEmail.attrName = EMAIL;
}

- (IBAction)pickFromAB:(id)sender {
    ABPeoplePickerNavigationController * picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)getContact:(ABRecordRef)person
{
    
    NSMutableDictionary *contact  = [NSMutableDictionary dictionary];
    
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    [contact setValue:firstName forKey:FIRST_NAME];
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    [contact setValue:lastName forKey:LAST_NAME];
    
    
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSString *email;
    if (ABMultiValueGetCount(emails) > 0) {
        
        email = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(emails, 0);
        
    } else {
        
        email = @"";
        
    }

    [contact setValue:email forKey:EMAIL];
    CFRelease(emails);

    NSString* phone = nil;
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        
        phone = (__bridge_transfer NSString*)
        
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        
    } else {
        
        phone = @"";
        
    }
    
    [contact setValue:phone forKey:PHONE];
    
    CFRelease(phoneNumbers);
    return contact;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    DebugLog(@"Picked %@", [self getContact:person]);
    tfEmail.text = [[self getContact:person] objectForKey:EMAIL];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property
                              identifier: (ABMultiValueIdentifier)identifier
{
        [self dismissViewControllerAnimated:YES completion:nil];

    return NO;
}

@end
