//
//  WCProductListVC.m
//  Mappuccino
//
//  Created by Anping Wang on 10/28/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCProductListVC.h"

@interface WCProductListVC ()

@end

@implementation WCProductListVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            self.objectType = @"org.sixstreams.mappuccino.Product";
    
    }
    return self;
}
@end
