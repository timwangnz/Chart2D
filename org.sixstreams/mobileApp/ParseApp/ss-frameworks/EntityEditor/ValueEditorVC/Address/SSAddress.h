//
//  SSAddress.h
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSAddress : NSObject

@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *zipCode;

@property float longitude;
@property float latitude;

- (void) updateLocation;

- (id) initWithDictionary:(NSDictionary *) data;
- (NSDictionary *) dictionary;
- (NSString *) longDesc;

@end
