#import <Foundation/Foundation.h>
#import "SSReachability.h"
#import "SSConnection.h"

@protocol HTTPConnectorDelegate <NSObject>
@required
- (void) didFinishLoading: (NSData *)data;
@optional
- (void) processData: (NSData *)data;
- (void) processResponse: (NSURLResponse *)response;
- (void) processError: (NSString *) error;
@end

typedef void (^RequestCallback)(NSError *error, id data);

@interface HTTPConnector : NSObject
{
    NSMutableData *receivedData;
    NSMutableURLRequest *request;
    NSHTTPURLResponse *httpResponse;
    BOOL challenged;
}

@property (strong) id<HTTPConnectorDelegate> delegate;
@property (strong) NSString *url;

- (BOOL) putData: (NSData *) item;
- (BOOL) putData: (NSData *) item withHeader:(NSDictionary*) header;
- (BOOL) postData : (NSData *) data withHeader:(NSDictionary*) header;

- (BOOL) post: (NSDictionary *) item;
- (BOOL) post: (NSDictionary *) item withHeader:(NSDictionary*) header;

- (BOOL) get;
- (BOOL) get: (NSDictionary*) header;

- (void) get: (NSString *) url
   onSuccess: (SuccessDownload) callback
  onProgress: (ProgressCallback) progress
   onFailure: (ErrorCallback) errorCallback;

- (BOOL) delete : (NSDictionary *) header;

+ (BOOL) isHostReachable : (NSString *) host;

- (void) downloadFile: (NSString *) url
            onSuccess: (SuccessDownload) callback
           onProgress: (ProgressCallback) progress
            onFailure: (ErrorCallback) errorCallback;

@end
