//
// AppliaticsProperty.h
// Appliatics
//
//  Created by Anping Wang on 9/30/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSProperty : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *type;

- (id) initWithName:(NSString *) name andType:(NSString *) type;

@end
