//
//  HWDRecognizer.h
//  HandWritingDemo
//
//  Created by Anping Wang on 12/29/12.
//  Copyright (c) 2012 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSLine.h"

@interface HWDRecognizer : NSObject
{
    
}


- (NSString *) match :(SSLine *) lastLine;

@end
