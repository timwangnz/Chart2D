//
//  SSDataVC.m
//  SixStreams
//
//  Created by Anping Wang on 1/17/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import "SSDataVC.h"
#import "HTTPConnector.h"



@interface SSDataVC ()
- (IBAction) testCookie :(id) sender;


@end

@implementation SSDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction) testCookie :(id) sender
{
    HTTPConnector *http = [[HTTPConnector alloc]init];
    [http get:@"http://tags.bluekai.com/site/2?phint=test=auto"
    onSuccess:^(NSData *data) {
        for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
        {
            NSLog(@"Cookie received %@ %@", cookie.name, cookie.value);
        }
    } onProgress:^(id data) {
        
    } onFailure:^(NSError *error) {
        
    }];
    
}

@end
