@import MultipeerConnectivity;

#import "SSConversation.h"
#import "SixStreams.h"

@implementation SSConversation

// Designated initializer with all properties
- (id)initWithPeerID:(NSString *)peerID message:(NSString *)message imageName:(NSString *)imageName imageUrl:(NSURL *)imageUrl progress:(NSProgress *)progress direction:(TranscriptDirection)direction
{
    if (self = [super init]) {
        _peerID = peerID;
        _message = message;
        _direction = direction;
        _imageUrl = imageUrl;
        _progress = progress;
        _imageName = imageName;
    }
    return self;
}

// Initializer used for sent/received text messages
- (id)initWithPeerID:(NSString *)peerID message:(NSString *)message direction:(TranscriptDirection)direction
{
    return [self initWithPeerID:peerID message:message imageName:nil imageUrl:nil progress:nil direction:direction];
}

// Initializer used for sent/received images resources
- (id)initWithPeerID:(NSString *)peerID imageUrl:(NSURL *)imageUrl direction:(TranscriptDirection)direction
{
    return [self initWithPeerID:peerID message:nil imageName:[imageUrl lastPathComponent] imageUrl:imageUrl progress:nil direction:direction];
}

- (id)initWithPeerID:(NSString *)peerID imageName:(NSString *)imageName progress:(NSProgress *)progress direction:(TranscriptDirection)direction
{
    return [self initWithPeerID:peerID message:nil imageName:imageName imageUrl:nil progress:progress direction:direction];
}

- (id) initWithDictionary:(NSDictionary *) dic
{
    _peerID = [dic objectForKey:MESSAGE_FROM];
    _message = [dic objectForKey:MESSAGE];
    _direction = [[dic objectForKey:DIRECTION] intValue];
    return self;
}
@end
