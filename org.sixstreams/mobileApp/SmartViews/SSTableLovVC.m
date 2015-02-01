
#import "SSTableLovVC.h"
#import "SSApp.h"
#import "SSLovTextField.h"

@interface SSTableLovVC ()
{
    NSMutableArray *sortedFilteredKeys;
    IBOutlet UITableView *myTableView;
    IBOutlet UISearchBar *searchbar;
    NSString *query;
}

@end

@implementation SSTableLovVC

- (void) addNewValue:(id) sender
{
    if (self.searchVC)
    {
        UIViewController *addLovEditor = (UIViewController*) [[SSApp instance] entityVCFor:self.searchVC.objectType];
        [self.navigationController pushViewController:addLovEditor animated:YES];
    }
    //add new value editor
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = self.addable ?
    [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                                                 action:@selector(addNewValue:)] : nil;
    if([self.items count] < 50)
    {
        searchbar.hidden = YES;
        myTableView.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.title = [NSString stringWithFormat:@"Select %@", [[SSApp instance] displayName: self.field.attrName ofType: self.field.entityType]];
}

- (void) loadDataOnSuccess:(SuccessCallback) callback
{
    if (self.searchVC)
    {
        [self.searchVC refreshOnSuccess:^(id data) {
            NSMutableDictionary *lovItems = [NSMutableDictionary dictionary];
            NSArray *objects = data[PAYLOAD];
            if (objects)
            {
                NSString *refId = self.attrId ? self.attrId : REF_ID_NAME;
                for(id object in objects)
                {
                    id key =object[refId];
                    lovItems[key] = object[self.searchVC.titleKey] ? object[self.searchVC.titleKey] : @"No Name";
                }
            }
            self.items = lovItems;
            callback(self.items);
        } onFailure:^(NSError *error) {
            self.items = nil;
        }];
    }
    else
    {
        callback(self.items);
    }
}

- (NSDictionary *) dictionarizeItems:(NSDictionary *) dic
{
    NSMutableArray *allKeys = [NSMutableArray arrayWithArray:[dic allKeys]];
    NSMutableDictionary *newItems = [NSMutableDictionary dictionary];
    NSString *refId = self.attrId ? self.attrId : REF_ID_NAME;
    for (id key in allKeys) {
        id item = [dic objectForKey:key];
        
        //if item is dictionary already, we leave it alone, assuming it is
        //constructed as lov correctly
        if ([item isKindOfClass:[NSDictionary class]] && dic[refId])
        {
            return dic;
        }
        if ([item isKindOfClass:[NSDictionary class]])//but does not have refid
        {
            newItems[key] = [NSMutableDictionary dictionaryWithDictionary:item];
            newItems[key][refId] = key;
        }
        else
        {
            newItems[key] = @{REF_ID_NAME:key, NAME:item};
        }
    }
    return newItems;
}

- (void) setItems:(NSDictionary *)items
{
    _items = [self dictionarizeItems:items];
    if(!self.searchVC)
    {
        [self sortAndFilter];
    }
    else{
        sortedFilteredKeys = [NSMutableArray arrayWithArray:[self.items allValues]];
    }
}

- (BOOL) filterItem:(id)item
{
    NSString *displayName = item;
    if (query && [query length]>0)
    {
        return ![[displayName uppercaseString] hasPrefix:[query uppercaseString]];
    }
    else
    {
        return NO;
    }
}

- (void) sortAndFilter
{
    sortedFilteredKeys = [NSMutableArray array];
    NSMutableArray *allKeys = [NSMutableArray arrayWithArray:[self.items allKeys]];
    
    for (id key in allKeys) {
        id item = [self.items objectForKey:key];
        NSString *name = name = item[NAME];
        
        if (![self filterItem:name]) {
            [sortedFilteredKeys addObject:item];
        }
    }
    
    [sortedFilteredKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[NAME] compare: obj2[NAME]];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sortedFilteredKeys.count;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL) isSelected:(NSString *) key
{
    id value = self.field.value;
    NSString *refId = REF_ID_NAME;
    if ([value isKindOfClass:[NSArray class]])
    {
        BOOL contained = NO;
        for(id item in value)
        {
            contained = contained || [key isEqualToString:item[refId]];
        }
        return contained;
    }
    else
    {
        return [key isEqual: value];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [sortedFilteredKeys objectAtIndex:indexPath.row];
   
    if (self.tableLovDelegate && [self.tableLovDelegate respondsToSelector:@selector(tableLov:getCellFor:) ])
    {
        return [self.tableLovDelegate tableLov:self getCellFor:object];
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        
        if (((SSLovTextField *)self.field).allowMultiValues)
        {
            if([self isSelected:object[REF_ID_NAME]])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        cell.textLabel.text = object[NAME];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        return cell;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    query = searchText;
    [self sortAndFilter];
    [myTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selected = [sortedFilteredKeys objectAtIndex:indexPath.row];
    NSString *key = selected[REF_ID_NAME];
    if(((SSLovTextField *)self.field).allowMultiValues)
    {
        if (!self.field.value)
        {
            self.field.value = [NSMutableArray array];
        }
        
        if([self isSelected:key])
        {
            [self.field.value removeObject:selected];
        }
        else
        {
            [self.field.value addObject:selected];
        }
    }
    else
    {
        if (self.searchVC)
        {
            self.field.displayValue = selected[NAME];
            self.field.value = selected[REF_ID_NAME];
        }
        else{
            self.field.displayValue = selected[NAME];
            self.field.value = key;
        }
    }
    
    if (((SSLovTextField *)self.field).allowMultiValues)
    {
        [tableView reloadData];
    }
    else
    {
        [super save:self];
    }
    
    if (self.tableLovDelegate)
    {
        [self.tableLovDelegate tableLov:self didSelect:key];
    }
}


@end
