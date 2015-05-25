#import <Foundation/Foundation.h>

typedef void (^OnSuccessCallback)(NSDictionary *data);
typedef void (^OnFailCallback)(NSError *error);

@protocol HTTPConnectorDelegate <NSObject>
@required
- (void) didFinishLoading: (id)data;
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

- (BOOL) post : (NSDictionary *) item
   withHeader : (NSDictionary*) header
    onSuccess : (OnSuccessCallback) success
    onFailure : (OnFailCallback) failure;

- (BOOL) get;
- (BOOL) get: (NSDictionary*) header;


- (BOOL) delete : (NSDictionary *) header;


@end
