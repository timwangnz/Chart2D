//
// AppliaticsEntityVC.h
// Appliatics
//
//  Created by Anping Wang on 6/14/13.
//

#import "SSTableViewVC.h"
@class SSWidgetVC;

@interface SSEntityVC : SSTableViewVC

@property (nonatomic, strong) id viewDef;
@property (nonatomic, strong) id entity;

- (void) updateWidget:(SSWidgetVC *)widget;
- (void) doLayout;

@end
