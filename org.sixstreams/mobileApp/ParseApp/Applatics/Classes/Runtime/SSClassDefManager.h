//
// AppliaticsObjectManager.h
// Appliatics
//
//  Created by Anping Wang on 9/30/13.
//

#import <Foundation/Foundation.h>
#import "SSCommonVC.h"

#import "SSClassDef.h"
#import "SSObject.h"

@interface SSClassDefManager : NSObject

+ (SSClassDefManager *) instance;

- (SSClassDef *) definitionOf:(NSString *) className;

- (id) createInstanceOfType:(NSString *) name;


@end
