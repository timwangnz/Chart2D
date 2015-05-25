//
//  PixelServer.m
//  Bluekai
//
//  Created by Anping Wang on 1/17/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "PixelServer.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>


#define PIXEL_SERVER_TAG_URL @"http://tags.bluekai.com/site/%@%@"

static NSString *HTTP_METHOD_GET = @"GET";

@interface PixelServer()
{
    NSMutableData *receivedData;
    SuccessBlock onSuccess;
    ProgressBlock onProgress;
    ErrorBlock onError;
}

@property NSString *siteId;
@property BOOL idfaEnabled;

@end;

@implementation PixelServer

static PixelServer *singleton;
+ (void) optOut
{
    //TODO
}

+ (NSString *) getBluekaiUUID
{
    NSString *bkuuid = nil;
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        NSLog(@"Cookie in the jar %@ %@", cookie.name, cookie.value);
        if ([cookie.name isEqual:@"bku"])
        {
            bkuuid = cookie.value;
        }
    }
    return bkuuid;
}

+ (void)clearCookies
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) tagUser: (NSDictionary *) data
       onSuccess: (SuccessBlock) callback
      onProgress: (ProgressBlock) progress
       onFailure: (ErrorBlock) errorCallback
{
    if(singleton)
    {
        [singleton tagUser:data onSuccess:callback onProgress:progress onFailure:errorCallback];
    }
    else
    {
        @throw [NSException
                exceptionWithName:@"NOT_INITIALED"
                reason:@"Pixel Server not initialied properly. Please call PixelServer forSite first"
                userInfo:nil];;
    }
}

+ (void) tagUser: (NSDictionary *) data
{
    [self tagUser:data onSuccess:nil onProgress:nil onFailure:nil];
}

+ (PixelServer *) forSite : (NSString *) siteId
{
    if(singleton == nil)
    {
        singleton = [[PixelServer alloc]init];
        singleton.idfaEnabled = YES;
    }
    singleton.siteId = siteId;
    return singleton;
}

- (PixelServer *) enableIdfa:(BOOL) enableIdfa
{
    self.idfaEnabled = enableIdfa;
    return self;
}

- (void) tagUser:(NSDictionary *) data
       onSuccess: (SuccessBlock) callback
      onProgress: (ProgressBlock) progress
       onFailure: (ErrorBlock) errorCallback
{
    onSuccess = callback;
    onProgress = progress;
    onError = errorCallback;
    [self tagUser:data];
}

- (NSString *) urlFrom:(NSDictionary *) data
{
    
    NSMutableString *query  = [NSMutableString stringWithString:@""];
    int i = 0;
    if([data count] != 0)
    {
        query = [NSMutableString stringWithString:@"?"];
        
        for (NSString *key in [data allKeys]) {
            [query appendFormat:(i++ == 0) ? @"phint=%@=%@" : @"&phint=%@=%@", key, (NSString*)[data objectForKey:key]];
        }
    }
    
    if (self.idfaEnabled)
    {
        [query appendFormat:(i++ == 0) ? @"phint=idfa=%@" : @"&phint=idfa=%@", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    }
    
    return [NSMutableString stringWithFormat:PIXEL_SERVER_TAG_URL, self.siteId, query];
}

- (void) tagUser:(NSDictionary *) data
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    NSString *url = [self urlFrom:data];
    
    
    [urlRequest setURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [urlRequest setHTTPMethod:HTTP_METHOD_GET];
    

    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    NSLog(@"Request to pixel server %@\n%@\n%@", data, url, secretAgent);
    
    [urlRequest setValue:secretAgent forHTTPHeaderField:@"User-Agent"];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if (theConnection)
    {
        receivedData = [NSMutableData data];
    }
    else
    {
        receivedData = nil;
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

//using a delegate might be better here
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
    if (onProgress)
    {
        onProgress(receivedData);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (onError)
    {
        onError(error);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (onSuccess)
    {
        onSuccess(receivedData);
    }
}


@end

