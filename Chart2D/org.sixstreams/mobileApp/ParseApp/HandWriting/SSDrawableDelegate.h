//
//  GLViewDelegate.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/1/12.
//

#import <Foundation/Foundation.h>


@protocol SSDrawableDelegate <NSObject>
@optional
- (void) viewDidRefresh : (UIView *) glView;
@end

