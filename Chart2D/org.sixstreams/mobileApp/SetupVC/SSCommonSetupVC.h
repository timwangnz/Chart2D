//
//  OPCSSSetupViewController.h
//  FileSync
//
//  Created by Anping Wang on 9/21/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSSettingEditorVC.h"

@protocol ConfigurationDelegate <NSObject>
@required
- (void) onClearConfiguration;
@end

@interface SSCommonSetupVC : SSSettingEditorVC
{
    

}

@property (strong, nonatomic) NSString *clearLabel;
@property (strong, nonatomic) id<ConfigurationDelegate> delegate;

- (IBAction)unattachDevice:(id)sender;
+ (UINavigationController *) initSetupVC;

@end
