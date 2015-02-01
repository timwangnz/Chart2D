//
//  KeyChainUtil.h
//  fakebook
//
//  Created by Anping Wang on 4/18/13.
//  Copyright (c) 2013 Oracle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSKeyChainUtil : NSObject
{
    NSMutableDictionary *keychainItemData;      // The actual keychain item data backing store.
    NSMutableDictionary *genericPasswordQuery;  // A placeholder for the generic keychain item query used to locate the item.
}

@property (nonatomic, retain) NSMutableDictionary *keychainItemData;
@property (nonatomic, retain) NSMutableDictionary *genericPasswordQuery;

// Designated initializer.
- (id)initWithIdentifier: (NSString *)identifier accessGroup:(NSString *) accessGroup;
- (void)setObject:(id)inObject forKey:(id)key;
- (id)objectForKey:(id)key;
// Initializes and resets the default generic keychain item data.
- (void)resetKeychainItem;

+ (void) saveUsername:(NSString *) username authSource:(NSString *) authSource password:(NSString *) password;
+ (NSString *) username;
+ (NSString *) password;
+ (NSString *) authSource;

+ (void) clearCredentials;

@end
