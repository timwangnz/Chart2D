//
//  SSMyGlueProfileVC.m
//  SixStreams
//
//  Created by Anping Wang on 5/31/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSMyGlueProfileVC.h"
#import "SSProfileVC.h"

@interface SSMyGlueProfileVC ()

@end

@implementation SSMyGlueProfileVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:@"SSGlueProfileVC" bundle:nibBundleOrNil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.readonly = YES;
	[self updateEntity:[SSProfileVC profile] OfType:self.itemType];
    
}

@end
