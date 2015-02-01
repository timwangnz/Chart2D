//
//  SSScrollView.h
//  Mappuccino
//
//  Created by Anping Wang on 4/21/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SSCallbackEvent.h"
#import "ConfigurationManager.h"
#import "DebugLogger.h"
#import "SSClient.h"

@class SSScrollView;

@protocol SSScrollViewDelegate <NSObject>
@optional
- (void) scrollView: (SSScrollView *) ssClient didSelectView:(id) view;
@end

typedef void (^SSScrollViewCallback)(id ssScrollView, NSArray *objects);

@interface SSScrollView : UIScrollView

@property int mode;
@property (nonatomic, strong) NSString *objectType;

@property (strong, nonatomic) NSString *queryString;
@property (strong, nonatomic) NSString *fieldFilters;
@property (strong, nonatomic) id definition;
@property (strong, nonatomic) NSString *distanceFilter;
@property (strong, nonatomic) NSString *orderBy;
@property (strong, nonatomic) id<SSScrollViewDelegate> scrollViewDelegate;

@property int pageSize;
@property int offset;
@property int total;

- (void) clearAll;
- (void) getObjects;

- (void) delete : (id) item ofType:(NSString *) type;

- (void) handleError:(SSCallbackEvent *)event;

- (void) addChildView:(UIView *) view;

- (NSUInteger) numberOfChildViews;

- (void) refreshViewOnSuccess:(SSScrollViewCallback) callback;

@end
