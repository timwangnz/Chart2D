//
// AppliaticsObject.h
// Appliatics
//
//  Created by Anping Wang on 9/30/13.
//

#import <Foundation/Foundation.h>

@interface SSClassDef : NSObject

@property (nonatomic, readonly) NSString *className;
@property (nonatomic, strong) NSMutableDictionary *properties;

+ (SSClassDef *) object :(NSString *) quid;
+ (SSClassDef *) object :(NSString *) quid extends:(SSClassDef *) parentDef;

- (id) addProperty:(NSString *) name objectType:(NSString *) type;

@end
