//
//  SSJobDetailsView.h
//  JobsExchange
//
//  Created by Anping Wang on 2/3/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "PageContainerView.h"

@interface SSEntityDetailsView : PageContainerView
{
     NSMutableArray *propertyVCs;
}

@property (nonatomic, strong) UIViewController * parentVC;
@property (nonatomic, strong) id entity;
@property (strong, nonatomic) NSString *objectType;
@property (strong, nonatomic) id definition;

- (void) configureUI;

@end
