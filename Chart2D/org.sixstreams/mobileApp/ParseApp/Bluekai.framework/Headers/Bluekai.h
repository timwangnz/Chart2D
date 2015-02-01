//
//  Bluekai.h
//  Bluekai
//
//  Created by Anping Wang on 1/13/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for Bluekai.
FOUNDATION_EXPORT double BluekaiVersionNumber;

//! Project version string for Bluekai.
FOUNDATION_EXPORT const unsigned char BluekaiVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Bluekai/PublicHeader.h>

@interface Bluekai : NSObject


+ (Bluekai *) initWithSiteId:(NSString *) siteId;

- (void) tagUser:(id) tags;

- (NSArray *) getCampaigns;

@end
