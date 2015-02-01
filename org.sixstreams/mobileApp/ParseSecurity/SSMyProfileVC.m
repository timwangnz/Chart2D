//
//  SSMyProfileVC.m
//  SixStreams
//
//  Created by Anping Wang on 3/2/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSMyProfileVC.h"
#import "SSProfileVC.h"

@interface SSMyProfileVC ()

@end

@implementation SSMyProfileVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:@"SSProfileEditorVC" bundle:nibBundleOrNil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.readonly = YES;
	[self updateEntity:[SSProfileVC profile] OfType:self.itemType];
    
}

@end
