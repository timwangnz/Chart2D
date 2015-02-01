#import "SSDataViewVC.h"
#import "SSEntityVC.h"
#import "SSExpressionParser.h"
#import "SSStorageManager.h"
#import "SSIconView.h"
#import "SSViewDefWidardVC.h"
#import "SSObjectEditorVC.h"
#import "SSConnection.h"
#import "SSAddress.h"
#import "SSRoundButton.h"
#import "SSProfileVC.h"
#import "SSValueLabel.h"
#import "SSApp.h"


#define WIDTH @"width"
#define COLOR @"color"
#define BACKGROUND @"background"
#define ALIGNMENT @"alignment"
#define DEFAULT_COL_WIDTH 100
#define TITLE_BAR_HEIGHT 40

@interface SSDataViewVC ()<SSObjectEditorDelegate, SSEntityEditorDelegate, SSIconViewDelegate>
{
    IBOutlet SSRoundButton *btnAdd;
    IBOutlet SSRoundButton *btnConfig;
    IBOutlet UIButton *showInsights;
    IBOutlet UIScrollView *listView;
    IBOutlet UIView *toolboxView;
    IBOutlet UITableView *firstColumn;
    IBOutlet UITableView *otherColumns;
    IBOutlet UILabel *viewName;
    
    NSMutableArray *columnDefs;
    SSObjectEditorVC *detailsVC;
    NSMutableDictionary *summation;
    NSMutableArray *visibleColumns;
    BOOL adding;
    int left;
}

@property (nonatomic, strong) id viewDef;

- (IBAction)edit:(id)sender;
- (IBAction)addObject : (id)sender;

@end

@implementation SSDataViewVC

- (IBAction)addObject:(id)sender
{
    if (self.isIPad)
    {
        SSObjectEditorVC *objectEditor = [SSObjectEditorVC objectType: self.viewDef];
        objectEditor.item2Edit = [NSMutableDictionary dictionary];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController: objectEditor];
        objectEditor.objectDelegate = self;
        adding = YES;
        
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.parentVC.parentViewController presentViewController:nav animated:YES completion:nil];
    }
    else{
        [self onSelect:nil];
    }
}

- (void) entityEditor:(id)editor didSave:(id)entity
{
    [self updateUI];
    [self refreshUI];
}

- (IBAction)edit:(id)sender
{
    SSViewDefWidardVC *viewDefEditor = [SSViewDefWidardVC viewWizard:self.viewDef for:self.parentVC.entity];
    viewDefEditor.entityEditorDelegate = self;
    adding = NO;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController: viewDefEditor];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.parentVC.parentViewController presentViewController:nav animated:YES completion:nil];
}

- (void) objectEditor:(SSObjectEditorVC *)editor didSave:(id)entity
{
    if (adding)
    {
        [self forceRefresh];
    }
    else
    {
        [self refreshUI];
    }
}

-(UIColor *) colorWith:(NSString *) colorString defaultColor:(UIColor *) defaultColor
{
    if(!colorString)
    {
        return defaultColor;
    }
    
    NSArray *element = [colorString componentsSeparatedByString:@";"];
    if ([element count] <= 1)
    {
        element = [colorString componentsSeparatedByString:@","];
    }
    if ([element count]>=4)
    {
        float red = [[element objectAtIndex:0] floatValue];
        float green = [[element objectAtIndex:1] floatValue];
        float blue = [[element objectAtIndex:2] floatValue];
        float alpha = [[element objectAtIndex:3] floatValue];
        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    else if ([element count]==3)
    {
        float red = [[element objectAtIndex:0] floatValue];
        float green = [[element objectAtIndex:1] floatValue];
        float blue = [[element objectAtIndex:2] floatValue];
        return [UIColor colorWithRed:red green:green blue:blue alpha:1];
    }
    return defaultColor;
}

- (UIView *) tableView:(UITableView *)tableView cell: cell headerAt:(int) col
{
    if(![tableView isEqual:firstColumn])
    {
        col = col + 1;
    }
    
    if ([visibleColumns count]==0)
    {
        return nil;
    }
    
    id column = [visibleColumns objectAtIndex:col];

    UILabel *uiLabel = [[UILabel alloc]init];
    uiLabel.text = [self tableView:tableView headerText:col];
    uiLabel.textColor = [UIColor lightGrayColor];
    [cell setBackgroundColor:[UIColor darkGrayColor]];
    int alignment = [[column valueForKey:ALIGNMENT] intValue];
    switch (alignment) {
        case 0:
            uiLabel.textAlignment = NSTextAlignmentLeft;
            break;
        case 1:
            uiLabel.textAlignment = NSTextAlignmentCenter;
            break;
        case 2:
            uiLabel.textAlignment = NSTextAlignmentRight;
            break;
        default:
            break;
    }
    return uiLabel;
}

#define CELL @"cell"

- (UITableViewCell *) tableView:(UITableView *)tableView cellForHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
    }
    
    for (UIView *child in [cell.contentView subviews])
    {
        [child removeFromSuperview];
    }
    
      float x = self.cellLeftPadding;
    
    NSInteger columns = [self numberOfColumns:tableView];
    
    for (int i = 0; i < columns ; i++) {
        UIView *cellFrame = [self tableView:tableView cell:cell headerAt:i];
        NSInteger width = [self tableView:tableView widthForColumn:i];
        cellFrame.contentMode = UIViewContentModeCenter;
        cellFrame.frame = CGRectMake(x, 0, width, cell.contentView.frame.size.height);
        x += width;
        [cell.contentView addSubview: cellFrame];
    }
    return cell;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objects count] + (self.showHeaders ? 1 : 0) + (self.hasSummaryRow ? 1 : 0);
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0 && self.showHeaders)
    {
        return [self tableView:tableView cellForHeaderAtIndexPath:indexPath];
    }
    
    NSInteger row = indexPath.row - (self.showHeaders ? 1: 0);
    
    UITableViewCell *cell = nil;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
    }
    
    for (UIView *child in [cell.contentView subviews])
    {
        [child removeFromSuperview];
    }
    
    cell.textLabel.text = @"";
    
    if (self.alterRowBackground && row % 2 == 0)
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.9];
    }
    else{
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    NSInteger columns = [self numberOfColumns:tableView];
    
    int x = 0;
    for (int i = 0; i< columns ; i++) {
        UIView *cellFrame = [self tableView:tableView cell:cell row:row col:i];
        NSInteger width = [self tableView:tableView widthForColumn:i];
        cellFrame.frame = CGRectMake(x, 0, width, cell.contentView.frame.size.height);
        x += width;
        [cell.contentView addSubview: cellFrame];
    }
    return cell;
}

//customize the width
- (NSInteger) numberOfColumns:(id) tableView
{
    if([tableView isEqual:firstColumn])
    {
        return 1;
    }
    else
    {
        return self.tableColumns - 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView widthForColumn:(int) col
{
    if(![tableView isEqual:firstColumn])
    {
        col = col + 1;
    }
    if ([visibleColumns count] == 0)
    {
        return 0;
    }
    id columnDef = [visibleColumns objectAtIndex:col];
    
    int colWidth = [[columnDef objectForKey:WIDTH] intValue];
    return colWidth == 0 ? DEFAULT_COL_WIDTH : colWidth;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && self.showHeaders)
    {
        return 30;
    }
    return 44;
}

- (UIView *) tableView:tableView cell:(UITableViewCell *) cell row:(NSInteger) row col:(NSInteger) col
{
    id item  = row >= [self.objects count] ? nil : [self.objects objectAtIndex:row];
    NSString *cellText = nil;
   
    if(![tableView isEqual:firstColumn])
    {
        col = col + 1;
    }
    
    if (item == nil && self.hasSummaryRow)
    {
        cellText = [self getSummaryText:col];
    }
    else
    {
        cellText = [self tableView:tableView cellText:item atCol:col];
    }
    if ([cellText isEqual:[NSNull null]] || !cellText)
    {
        cellText = @"";
    }
  
    id column = [visibleColumns objectAtIndex:col];

    NSString *colorString = [column valueForKey:COLOR] ;
    UIColor *color = [self colorWith: colorString defaultColor:[UIColor grayColor]];
    colorString = [column valueForKey:BACKGROUND] ;
    
    UIView *contentView = nil;
    
    UILabel *uiLabel = [[UILabel alloc]init];
    
    uiLabel.text = [NSString stringWithFormat:@" %@", cellText];
    [uiLabel setClipsToBounds:YES];
    uiLabel.textColor = color;
    if (col <= 1) {
        left = 0;
    }
    int width = [[column objectForKey:WIDTH] intValue];
    
    width = width == 0 ? 100 : width;
    uiLabel.frame = CGRectMake(left ,0, width, 44);
    
    left += width;
    
    uiLabel.font = [UIFont systemFontOfSize:14];
    contentView = uiLabel;
    
    int alignment = [[column valueForKey:ALIGNMENT] intValue];
    switch (alignment) {
        case 0:
            uiLabel.textAlignment = NSTextAlignmentLeft;
            break;
        case 1:
            uiLabel.textAlignment = NSTextAlignmentCenter;
            break;
        case 2:
            uiLabel.textAlignment = NSTextAlignmentRight;
            break;
        default:
            break;
    }
    
    UIColor *background = [self colorWith: colorString defaultColor:[UIColor clearColor]];
    contentView.backgroundColor = background;
    return contentView;
}

- (NSString *) tableView:tableView headerText:(int)col
{
    return [[NSString stringWithFormat:@"%@", visibleColumns ? [[visibleColumns objectAtIndex:col] objectForKey:NAME] : NAME] fromCamelCase];
}

- (NSString *) getSummaryText:(NSInteger) col
{
    NSDictionary * column = [visibleColumns objectAtIndex:col];
    if ([[column objectForKey:@"canSum"] boolValue])
    {
        NSString *name = [column objectForKey:NAME];
        NSNumber *number = [summation objectForKey:name];
        
        NSString *displayName = [NSString stringWithFormat:@"%@", number];
        id metaType = [column objectForKey:META_TYPE];
        float sum = 0.0f;
        for (id item in self.objects)
        {
            NSString *binding = [column objectForKey:BINDING];
            id displayName = [item objectForKey:binding];
            
            if (!displayName)
            {
                displayName = [SSExpressionParser parse:binding forObject:item];
            }
            
            NSExpression *expression = [NSExpression expressionWithFormat:displayName];
            id evaluated = [expression expressionValueWithObject:nil context:nil];
            
            if (evaluated)
            {
                displayName = [NSString stringWithFormat:@"%@", evaluated];
            }
            sum += [evaluated floatValue];
        }
        displayName = [NSString stringWithFormat:@"%.2f", sum];
        if ((metaType != [NSNull null]) && [metaType isEqualToString:@"currency"])
        {
            displayName = [displayName toCurrency];
        }
        return displayName;
    }
    else{
        return @"";
    }
}

- (NSString *) getText:(id) item atCol:(NSDictionary *) column
{
    if(item == nil)
    {
        return @"";
    }
    
    NSString *binding = [column objectForKey:BINDING];
    NSString *displayName = nil;
    id value = [item objectForKey:binding];
    
    if (!value)
    {
        value = [SSExpressionParser parse:binding forObject:item];
    }
    
    if ([value isKindOfClass:[NSArray class]])
    {
        NSArray *arrayValue = (NSArray *) value;
        return [arrayValue count] == 0 ? @"" : [arrayValue objectAtIndex:0];
    }
    else
    {
        if (column)
        {
            id metaType = [column objectForKey:META_TYPE];
            BOOL isExpression = [[column objectForKey:EXPRESSION]boolValue];
            
            if (value && isExpression)
            {
                @try {
                    NSExpression *expression = [NSExpression expressionWithFormat:value];
                    id evaluated = [expression expressionValueWithObject:nil context:nil];
                    
                    if (evaluated)
                    {
                        value = [NSString stringWithFormat:@"%@", evaluated];
                    }
                }@catch (NSException *e) {
                    //
                }
            }

            if (metaType != [NSNull null])
            {
                if([metaType isEqualToString:@"currency"])
                {
                    displayName = [value toCurrency];
                }
                else if([metaType isEqualToString:ADDRESS])
                {
                    SSAddress *address = [[SSAddress alloc]initWithDictionary :value];
                    displayName = [address description];
                }
                else if([metaType isEqualToString:CATEGORY])
                {
                    NSString *meta = [column objectForKey:META_DATA];
                    displayName = nil;
                    if (meta)
                    {
                        NSArray *values = [meta componentsSeparatedByString:@","];
                        if ([values count]>0)
                        {
                            displayName = [values objectAtIndex:[value intValue]];
                        }
                    }
                    if (!displayName)
                    {
                        displayName = [self valueAtPath:binding of:item];
                    }
                }
                else
                {
                    displayName = [self valueAtPath:binding of:item];
                }
            }
        }
        return displayName;
    }
}

- (id) valueAtPath:(NSString *) path of:(id) parent
{
    NSMutableArray *attrs = [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"."]];
    if ([attrs count] == 1)
    {
        return [[SSApp instance] value:parent forKey:path];
    }
    else{
        id child = [parent objectForKey:[attrs objectAtIndex:0]];
        if(child == nil)
        {
            return nil;
        }
        [attrs removeObject:[attrs objectAtIndex:0]];
        NSString * childPath = [attrs componentsJoinedByString:@"."];
        return [self valueAtPath:childPath of:child];
    }
}

- (NSString *)tableView:(UITableView *)tableView cellText:(id) item atCol:(NSInteger) col
{
    return [NSString stringWithFormat:@"%@", [self getText:item atCol: [visibleColumns objectAtIndex:col]]];
}

- (void) onSelect
{
    NSString *viewId = [self.subscription objectForKey:APP_VIEW_ID];
    [self getObject:viewId objectType:APP_VIEW OnSuccess:^(id data) {
        self.viewDef = data;
        self.objectType = [self.viewDef valueForKey:SS_OBJECT_TYPE];
        [self.parentVC selectView:self];
        BOOL owner = [[SSProfileVC profileId] isEqualToString:[self.viewDef objectForKey:AUTHOR]];
        if (!owner) {
            btnConfig.hidden = YES;
            btnAdd.frame = btnConfig.frame;
        }
        [self updateUI];
        [self refreshData];
    } onFailure:^(NSError *error) {
        //
    }];
    
}
- (void) refreshData
{
    [self refreshOnSuccess:^(id data) {
        [self refreshUI];
    } onFailure:^(NSError *error) {
        [self showAlert:@"Failed to retrieve data, please try again" withTitle:@"Data Error"];
    }];
}
//called after got data from server

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self view];
    firstColumn.layer.masksToBounds = NO;
    firstColumn.layer.cornerRadius = 0; // if you like rounded corners
    firstColumn.layer.shadowOffset = CGSizeMake(2, 0);
    firstColumn.layer.shadowRadius = 2;
    firstColumn.layer.shadowOpacity = 0.2;
    self.cellLeftPadding = 2;
    return self;
}

- (void) doLayout
{
    listView.contentSize = CGSizeMake(otherColumns.frame.size.width, firstColumn.frame.size.height - listView.frame.origin.y);
    listView.frame = CGRectMake(firstColumn.frame.size.width, listView.frame.origin.y,
                                listView.superview.frame.size.width - firstColumn.frame.size.width - (detailsVC.view.hidden ? 0 : detailsVC.view.frame.size.width)
                                , firstColumn.frame.size.height);
}
- (BOOL) objectEditor:(SSObjectEditorVC *)editor shouldHide:(id)entity
{
    listView.frame = CGRectMake(firstColumn.frame.size.width, listView.frame.origin.y,
                                listView.superview.frame.size.width - firstColumn.frame.size.width
                                , firstColumn.frame.size.height);
    return YES;
}

- (void) objectEditor:(SSObjectEditorVC *)editor didHide:(id)entity
{
    //[self updateUI];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [firstColumn selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [otherColumns selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [firstColumn selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
  //  [otherColumns selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && self.showHeaders)
    {
        selectedPath = nil;
        return;
    }
    selectedPath = indexPath;
    NSInteger row = indexPath.row - (self.showHeaders ? 1 : 0);
    if (row == [self.objects count])
    {
        return;
    }
    [firstColumn selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [otherColumns selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self onSelect:[self.objects objectAtIndex:row]];
}

//on select row
- (void) onSelect:(id) selected
{
    if (!detailsVC)
    {
        detailsVC = [SSObjectEditorVC objectType: self.viewDef];
        [detailsVC updateEntity:selected OfType:[self.viewDef objectForKey:SS_OBJECT_TYPE]];
        detailsVC.view.hidden = YES;
        detailsVC.objectDelegate = self;
        detailsVC.dataVC = self;
    }
    
    [detailsVC updateEntity:selected OfType:[self.viewDef objectForKey:SS_OBJECT_TYPE]];
    if (self.isIPad && detailsVC.view.hidden)
    {
        [self.view addSubview:detailsVC.view];
        [self.view bringSubviewToFront:detailsVC.view];
        detailsVC.view.frame = CGRectMake(self.view.frame.size.width, listView.frame.origin.y, self.view.frame.size.width / 2, listView.frame.size.height);
        detailsVC.view.hidden = NO;
        float width = self.view.frame.size.width / 2;
        if (!self.isIPad)
        {
            width = self.view.frame.size.width;
        }
        [UIView animateWithDuration:0.5 animations:^{
            detailsVC.view.frame = CGRectMake(self.view.frame.size.width/2, listView.frame.origin.y, width, listView.frame.size.height);
        } completion:^(BOOL finished) {
            [self updateUI];
        }];
    }
    else
    {
        detailsVC.view.hidden = NO;
        detailsVC.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        [self.navigationController pushViewController:detailsVC animated:YES];
        //[self updateUI];
    }
}

- (void) updateUI
{
    columnDefs = [self.viewDef objectForKey:COLUMN_DEFS];
    self.tableColumns = 0;
    visibleColumns = [NSMutableArray array];
    
    self.showHeaders = YES;
    
    if (!columnDefs || [columnDefs count] == 0)
    {
        columnDefs = nil;
    }
    else
    {
        for (id column in columnDefs)
        {
            BOOL visible = [[column objectForKey:VISIBLE] boolValue];
            if (visible)
            {
                [visibleColumns addObject:column];
            }
        }
        int firstColumnWidth = [[[columnDefs objectAtIndex:0] objectForKey:WIDTH]intValue];
        firstColumnWidth = firstColumnWidth == 0 ? DEFAULT_COL_WIDTH : firstColumnWidth;
        
        firstColumn.frame = CGRectMake(firstColumn.frame.origin.x, firstColumn.frame.origin.y, firstColumnWidth, firstColumn.frame.size.height);
        
        int otherColumnsWidth = 0;
        for (id column in visibleColumns)
        {
            int width = [[column objectForKey:WIDTH]intValue];
            width = width == 0 ? 100 : width;
            otherColumnsWidth += width;
        }
        
        otherColumns.frame = CGRectMake(otherColumns.frame.origin.x, otherColumns.frame.origin.y, otherColumnsWidth, firstColumn.frame.size.height);
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:SEQUENCE  ascending:YES];
        visibleColumns = [NSMutableArray arrayWithArray:
                      [visibleColumns sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
        summation = [NSMutableDictionary dictionary];
        
        for (id col in visibleColumns)
        {
            [summation setObject:[NSNumber numberWithInt:0] forKey:[col objectForKey:NAME]];
            self.hasSummaryRow = self.hasSummaryRow || [[col objectForKey:@"canSum"] boolValue];
        }
    }
    self.tableColumns = [visibleColumns count];
    viewName.text = [self.viewDef objectForKey:NAME];
    self.title = viewName.text;
    
    self.iconView.selected = self.selected;
    self.iconView.delegate = self;
    self.iconView.subscription = self.subscription;
    self.iconView.listVC = self;
    self.iconView.imageUrl = [self.subscription objectForKey:APP_VIEW_ID];
    [self.iconView updateUI];
    [self doLayout];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    selectedPath = nil;
    detailsVC.view.hidden = YES;
   
    //[self updateUI];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     //[self updateUI];
}

- (void) refreshUI
{
    [super refreshUI];
    [firstColumn reloadData];
    if (selectedPath) {
        [firstColumn selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [otherColumns selectRowAtIndexPath:selectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void) iconView:(SSIconView *) view itemSelected:(id) item
{
    [self onSelect];
}

@end
