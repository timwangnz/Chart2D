//
//  SSApp.h
//  Medistory
//
//  Created by Anping Wang on 11/12/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSApplication.h"
#import "SSTableViewVC.h"

@class SSEntityEditorVC;
@class SSProfileEditorVC;
@class SSLayoutVC;

CGAffineTransform makeTransform(CGFloat xScale, CGFloat yScale,
                                CGFloat theta, CGFloat tx, CGFloat ty);

@interface SSApp : NSObject<SSApplication, SSTableViewVCDelegate>
{
    NSMutableDictionary *lovs;
}

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * welcomeMessage;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * className;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * loginAgent;

@property BOOL isPublic;

@property BOOL createNetwork;

+ (SSApp *) instance;

- (void) initializeOnSuccess:(SuccessCallback) callback;
- (UIView *) backgroundView;
- (BOOL) invitationOnly;

//Customer Controller
- (UIViewController *) createWelcomeVC;
- (UIViewController *) createRootVC;

//activity stream
- (UIViewController *) createVCForActivity:(id) activity;
- (id) contextForActiviy:(id) activity onSubject:(NSString *) subject;
- (BOOL) showPastEvents;

//Editor controller for a given object type
- (SSEntityEditorVC *) entityVCFor :(NSString *) type;
- (NSString *) editorClassFor:(NSString *) objectType;

//Layout controller
- (SSLayoutVC *) getLayoutVC;

//profile
- (BOOL) enableResume;
- (void) customizeProfileEditor:(id) profileEditor;
- (BOOL) enableSocialProfile;

//attribute values
- (id) value:(id) item forKey:(NSString *) attrName;
- (id) value:(id) item forKey:(NSString *) attrName defaultValue:(id) defaultValue;
- (NSDictionary *) lookupsFor:(NSString*) type;

//
- (id) contextualObject:(id) item ofType:(NSString *) type;

//UI overrides
- (UIImage *) defaultImage:(id) item ofType:(NSString *) type;
- (NSString *) getAppIconName;
- (BOOL) isIPad;
- (void) customizeAppearance;

//highlights page, or frontpage
- (NSString*) highlightTitle: (id) item forCategory: (NSInteger) currentPage;
- (NSString*) highlightSubtitle: (id) item forCategory: (NSInteger) currentPage;

- (UIView *) spotlightView: (id) entity ofType:(NSString *) entityType;

- (void) updateHighlightItem:(id) item ofType:(NSString *) itemType inView:(UIView *) view;

- (void) addView:(id) item inView:(UIView *) view withAttr:(NSString *) attrName at: (NSInteger) order;

//expression evaluator, should moved to the location
- (NSString *) evaluate : (NSString *) expression on:(id) item;
//should be moved
- (void) readFile:(id) info url:(NSURL *) url;

@end
