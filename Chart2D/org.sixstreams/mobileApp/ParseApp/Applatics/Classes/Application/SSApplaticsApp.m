//
//  SSApplaticsApp.m
//  SixStreams
//
//  Created by Anping Wang on 11/12/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSApplaticsApp.h"

#import "SSContainerVC.h"
#import "SSMyViewsVC.h"

@interface SSApplaticsApp ()
{
}
@end

@implementation SSApplaticsApp

- (NSString *) appId
{
    return @"rqPdMlAa4WEeiItB4gwLNfU4k3mG1JnQkgDs3lEc";
}
- (NSString *) appKey
{
    return @"7DIXrcPQxyxsQslc4km7iZRfjcU4qQbwI77qzmou";
}

- (UIViewController *) createRootVC
{
    SSContainerVC *containerVC = [[SSContainerVC alloc]init];

    
    self.displayName = @"Mars";
    return containerVC;
}
- (SSLayoutVC *) getLayoutVC
{
    return [[SSMyViewsVC alloc]init];
}

- (id) init
{
    self = [super init];
    if (self)
    {
               
        NSDictionary *categories = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Customers", @"1",
                                   @"Social Apps", @"2",
                                   @"Games", @"3",
                                   @"Jobs", @"4",
                                   @"Personal Finance", @"5",
                                   @"Eduation", @"6",
                                    nil];
        
        
        NSDictionary *dataTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Date",@"2",
                                   @"Datetime",@"4",
                                   @"Time",@"5",
                                   @"String",@"0",
                                   @"Number", @"1",
                                   @"Object", @"3",
                                   nil];
        
        NSDictionary *metaTypes  = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"None",@"none",
                                    @"Email",@"email",
                                   @"Currency",@"currency",
                                   @"Phone", @"phone",
                                   @"Address", @"address",
                                   @"Reference", @"reference",
                                   @"Catgegory", @"category", nil];
        
        
        NSDictionary *uiTypes  = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"TextField",@"TextField",
                                 @"TextView",@"TextView",
                                 @"TableView",@"TableView",
                                 @"Slider", @"Slider",
                                 @"Map",@"Map",
                                 @"Segment", @"Segment",
                                 @"ProgressBar",@"ProgressBar", nil];
        
        [lovs setObject:categories forKey:CATEGORY];
        [lovs setObject:dataTypes forKey:DATA_TYPE];
        [lovs setObject:metaTypes forKey:META_TYPE];
        [lovs setObject:uiTypes forKey:@"uiType"];
        
    }
    return self;
}


@end
