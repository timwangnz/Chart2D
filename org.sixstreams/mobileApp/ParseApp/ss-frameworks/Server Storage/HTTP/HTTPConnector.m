#import "HTTPConnector.h"
#import "DebugLogger.h"
#import "SSReachability.h"

@interface HTTPConnector()
{
    SuccessDownload onSuccess;
    ProgressCallback onProgress;
    ErrorCallback onError;
}
@end;

@implementation HTTPConnector


static NSString *HTTP_METHOD_POST = @"POST";
static NSString *HTTP_METHOD_PUT = @"PUT";
static NSString *HTTP_METHOD_DELETE = @"DELETE";
static NSString *HTTP_METHOD_GET = @"GET";

static int DEFAULT_TIME_OUT_IN_SEC = 60;

- (NSString *)urlEncodeValue:(NSString *)str
{
    NSString *result = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8));
    return result;
}

static SSReachability *hostReach;

- (void) reachabilityChanged: (NSNotification* )note
{
	//Reachability* curReach = [note object];
	//NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	//[self updateInterfaceWithReachability: curReach];
}

+ (void) reachabilityChanged: (NSNotification* )note
{
    SSReachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [SSReachability class]]);
}

+ (BOOL) isHostReachable : (NSString *) host
{
    if (!hostReach)
    {
        hostReach = [SSReachability reachabilityWithHostName: host];
        [hostReach startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	}
    
    NetworkStatus netStatus = [hostReach currentReachabilityStatus];
    return netStatus != NotReachable;
}

- (NSMutableURLRequest *) requestForGet : (NSDictionary*) header
{    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
 
    [urlRequest setURL:[NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    [urlRequest setHTTPMethod:HTTP_METHOD_GET];
    if(header && [header count] > 0)
    {
        [urlRequest setAllHTTPHeaderFields:header];
    }
    
    urlRequest.timeoutInterval = DEFAULT_TIME_OUT_IN_SEC;
    return urlRequest;
}

- (NSMutableURLRequest *) requestForDelete : (NSDictionary*) header
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [urlRequest setHTTPMethod:HTTP_METHOD_DELETE];
    if(header && [header count] > 0)
    {
        [urlRequest setAllHTTPHeaderFields:header];
    }
    urlRequest.timeoutInterval = DEFAULT_TIME_OUT_IN_SEC;
    DebugLog(@"Request to %@ with header %@ by method %@", urlRequest.URL, header, urlRequest.HTTPMethod);
    return urlRequest;
}

- (NSMutableURLRequest *) requestForPut:(NSData *) data withHeader:(NSDictionary*) header
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [urlRequest setHTTPMethod:HTTP_METHOD_PUT];
   
    [urlRequest setHTTPBody:data];
    
    if(header && [header count] > 0)
    {
        [urlRequest setAllHTTPHeaderFields:header];
    }
    urlRequest.timeoutInterval = DEFAULT_TIME_OUT_IN_SEC;
    DebugLog(@"Request to %@ with header %@ by method %@", urlRequest.URL, header, urlRequest.HTTPMethod);
    DebugLog(@"HTTPBody %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    return urlRequest;
}

- (NSMutableURLRequest *) requestForPost:(NSDictionary *) item withHeader:(NSDictionary*) header
{
    NSString *post = @"";
    if (item)     
    {
        NSArray *keyArray =  [item allKeys];
        
        for (NSObject *key in keyArray) {
            NSObject *tmp = [item objectForKey:key];
            if(tmp)
            {
                NSString *valueString = [NSString stringWithFormat:@"%@", tmp];
                if ([post length] != 0)
                {
                    post = [NSString stringWithFormat:@"%@&%@=%@", post, key, [self urlEncodeValue:valueString ]];
                }
                else 
                {
                    post = [NSString stringWithFormat:@"%@=%@", key, [self urlEncodeValue:valueString ]]; 
                }
            }
        }
    }
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];

    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];

    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [urlRequest setHTTPMethod:HTTP_METHOD_POST];
    [urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:postData];
    
    if(header && [header count] > 0)
    {
        [urlRequest setAllHTTPHeaderFields:header];
    }
    
    urlRequest.timeoutInterval = DEFAULT_TIME_OUT_IN_SEC;
    
    DebugLog(@"Request to %@ with header %@ by method %@", urlRequest.URL, header, urlRequest.HTTPMethod);
    
    return urlRequest;
}

- (BOOL) putData : (NSData *) data
{
    return [self putData : data withHeader:nil];
}

- (BOOL) putData :(NSData *) data withHeader:(NSDictionary*) header
{
    request = [self requestForPut : data withHeader : header];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection) 
    {
        receivedData = [NSMutableData data];
        return YES;
    }
    else 
    {
        return NO;
    }
}

- (BOOL) postData : (NSData *) data withHeader:(NSDictionary*) header
{
    request = [self requestForPost:nil withHeader:header];
    
    request.HTTPMethod = HTTP_METHOD_POST;
    
    [request setHTTPBody: data];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
      
    if (theConnection)
    {
        receivedData = [NSMutableData data];
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL) post : (NSDictionary *) item
{
    return [self post:item withHeader:nil];
}

- (BOOL) post :(NSDictionary *) item withHeader:(NSDictionary*) header
{
    id data = [item objectForKey:@"data"];
    if (data && [data isKindOfClass:[NSData class]])
    {
        return [self postData:data withHeader:header];
    }
    
    request = [self requestForPost:item withHeader:header];
    request.HTTPMethod = HTTP_METHOD_POST;
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (theConnection) 
    {
        receivedData = [NSMutableData data];
        return YES;
    }
    else 
    {
        return NO;
    }
}

- (BOOL) delete : (NSDictionary *) header
{
    request = [self requestForDelete : header];
    request.HTTPMethod = HTTP_METHOD_DELETE;

    NSURLResponse *theResponse =[[NSURLResponse alloc]init];
    receivedData = [NSMutableData data];
    NSError *error = nil;
    
    [receivedData appendData:[NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&error]];
    
    if(self.delegate)
    {
        if (error)
        {
            DebugLog(@"%@", error);
            if ([self.delegate respondsToSelector:@selector(processError:)])
            {
                [self.delegate processError: @"Failed to delete "];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(processResponse:)])
            {
                [self.delegate processResponse : theResponse];
            }
            [self.delegate didFinishLoading:receivedData];
        }
    }
    return YES;
}

- (BOOL) get
{
    return [self get:nil];
}

- (void) get: (NSString *) url
            onSuccess: (SuccessDownload) callback
           onProgress: (ProgressCallback) progress
            onFailure: (ErrorCallback) errorCallback
{
    onError = errorCallback;
    onSuccess = callback;
    onProgress = progress;
    self.url = url;
    //DebugLog(@"%@", url);
    [self get];
}



- (void) downloadFile: (NSString *) url
            onSuccess: (SuccessDownload) callback
            onProgress: (ProgressCallback) progress
            onFailure: (ErrorCallback) errorCallback
{
    onError = errorCallback;
    onSuccess = callback;
    onProgress = progress;
    self.url = url;
    [self get];
}


- (BOOL) get : (NSDictionary*) header
{
    request = [self requestForGet : header];
    challenged = NO;
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection) 
    {
        receivedData = [NSMutableData data];
        return YES;
    }
    else 
    {
        return NO;
    }
}

#pragma mark NSURLConnectionDelegate methods


- (NSString *) getCredentialKey
{
    return [NSString stringWithFormat:@"%@://%@:%@", request.URL.scheme, request.URL.host, request.URL.port];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    httpResponse = (NSHTTPURLResponse *) response;
    [receivedData setLength:0];
    if(self.delegate && [self.delegate respondsToSelector:@selector(processResponse:)])
    {
        [self.delegate processResponse:response];
    }
}

//using a delegate might be better here
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //TODO this is where we should cache data into a file so we can restart it later
    [receivedData appendData:data];
    if(self.delegate && [self.delegate respondsToSelector:@selector(processData:)])
    {
        [self.delegate processData:receivedData];
    }
    if (onProgress)
    {
        onProgress(receivedData);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(processError:)])
    {
        [self.delegate processError:[NSString stringWithFormat:@"Connection failed! Error - %@ %@",
                                              [error localizedDescription],
                                              [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]]];
    }
    if (onError)
    {
        onError(error);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(self.delegate)
    {
        [self.delegate didFinishLoading:receivedData];
    }
    if (onSuccess)
    {
        onSuccess(receivedData);
    }

}

@end
