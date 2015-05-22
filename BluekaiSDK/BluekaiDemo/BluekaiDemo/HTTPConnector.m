#import "HTTPConnector.h"


@interface HTTPConnector()
{
    OnSuccessCallback onSuccessCallback;
    OnFailCallback onFailCallback;
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
   
    return urlRequest;
}

- (NSMutableURLRequest *) requestForPost:(NSDictionary *) item withHeader:(NSDictionary*) header
{
    NSString *post = [self toString: item];

    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [urlRequest setHTTPMethod:HTTP_METHOD_POST];
    [urlRequest setHTTPBody:postData];
   
    if(header && [header count] > 0)
    {
        [urlRequest setAllHTTPHeaderFields:header];
    }
    
    urlRequest.timeoutInterval = DEFAULT_TIME_OUT_IN_SEC;
    
    
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

- (BOOL) postData : (NSData *) data
       withHeader : (NSDictionary*) header
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

- (BOOL) post : (NSDictionary *) item
   withHeader : (NSDictionary*) header
{
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

- (BOOL) post : (NSDictionary *) item
   withHeader : (NSDictionary*) header
    onSuccess : (OnSuccessCallback) block
    onFailure : (OnFailCallback) failure
{
    request = [self requestForPost:item withHeader:header];
    request.HTTPMethod = HTTP_METHOD_POST;
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    onSuccessCallback = block;
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
  
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(processError:)])
    {
        [self.delegate processError:[NSString stringWithFormat:@"Connection failed! Error - %@ %@",
                                              [error localizedDescription],
                                              [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]]];
    }
    if (onFailCallback)
    {
        onFailCallback(error);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(self.delegate)
    {
        [self.delegate didFinishLoading:[self toDictionary:receivedData]];
    }
    if (onSuccessCallback)
    {
        onSuccessCallback([self toDictionary:receivedData]);
    }
}

- (id) toDictionary:(NSData *)data
{
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization
                         JSONObjectWithData:data
                         options:NSJSONReadingMutableContainers
                         error:&error];
    if (error) {
        NSLog(@"%@", error);
        NSLog(@"%@", [NSString stringWithUTF8String:[data bytes]]);
       
        return nil;
    }
    return dic;
    
}

-(NSString*) toString:(NSDictionary *) dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    
    if (! jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
