//
//  SSApplication.h
//  Medistory
//
//  Created by Anping Wang on 11/9/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SSApplication <NSObject>
@required
- (UIViewController *) createRootVC;
- (NSDictionary *) getLov : (NSString *) attrName ofType:(NSString *) objectType;

- (NSString *) displayNameOfType:(NSString *) objectType;
- (NSString *) displayName:(NSString *) attrName ofType:(NSString *) objectType;
- (NSString *) displayValue:(NSString *) attrValue forAttr: (NSString *) attrName ofType:(NSString *) objectType;

- (NSString *) format:(id)attrValue forAttr:(NSString *)attrName ofType:(NSString *)objectType;

- (NSString *) dateFormat;
- (NSString *) timeFormat;
- (NSString *) dateTimeFormat;

- (NSString *) appId;
- (NSString *) appKey;

@end
