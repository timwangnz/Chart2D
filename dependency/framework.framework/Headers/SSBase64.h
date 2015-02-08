//
//  Base64.h
//  CryptTest
//


#import <Foundation/Foundation.h>


@interface SSBase64 : NSObject {

}

+ (void) initialize;

+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;

+ (NSString*) encode:(NSData*) rawBytes;

+ (NSData*) decode:(const char*) string length:(NSInteger) inputLength;

+ (NSData*) decode:(NSString*) string;

@end
