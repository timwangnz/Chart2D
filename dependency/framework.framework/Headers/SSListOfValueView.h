//
//  ListOfValueView.h
// Appliatics
//
//  Created by Anping Wang on 10/8/13.
//  Copyright (c) 2013 Oracle. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ListOfValueViewDelegate <NSObject>
@optional
- (void) listOfValue:(id) list didSelect : (id) value;
@end

@interface SSListOfValueView : UITextField<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *listView;
}

@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) id<ListOfValueViewDelegate> listOfValueDelegate;

@end
