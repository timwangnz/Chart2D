//
//  SSCommonVC.h
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJSONUtil.h"
#import "SixStreams.h"

#define ALERT_OK_TITLE @"Ok"
#define ALERT_CANCEL_TITLE @"Cancel"

typedef void (^OnAlertSelect)(NSString * selectedTitle);

@interface SSCommonVC : UIViewController

@property (nonatomic, strong) UIPopoverController *genericPickerPopover;
//name to be used in case more than one of these vc are used
@property (nonatomic) NSString *name;

- (BOOL) isIPad;
- (void) showPopup:(id)popupVC sender:(id) sender permittedArrowDirections:(UIPopoverArrowDirection) direction;
- (void) showPopup:(id)popupVC sender:(id) sender;
//child VC can override this

- (void) popupVC:(UIViewController *) popupVC;
- (void) popDownVC:(UIViewController *) popupVC;

- (void) popView:(UIView *) uiView;
- (void) dissmissView:(UIView *) uiView;


- (IBAction) hideKeyboard;
- (void) clearForm:(UIView *) uiView;

- (void) showAlert:(NSString *)alert withTitle:(NSString *)title;

- (void) showAlert:(NSString *)alert
         withTitle:(NSString *)title
       cancelTitle:(NSString *)cancelTitle
           okTitle:(NSString *)okTitle
          onSelect:(OnAlertSelect) onAlertSelect;

- (id) addBarItem: (UIBarButtonItem*) item to:(id) parent;

- (UITapGestureRecognizer *) addTapEvent:(UIView*) view onTap:(SEL) onTap;

@end

@interface UITextField(SSCommonVC)
- (BOOL) isEmpty;
@end
