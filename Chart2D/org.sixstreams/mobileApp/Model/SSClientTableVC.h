//
//  SSClientTableVC.h
//  Mappuccino
//
//  Created by Anping Wang on 4/7/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSClientDataVC.h"

@interface SSClientTableVC : SSClientDataVC<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *objectsTableView;
}

@end
