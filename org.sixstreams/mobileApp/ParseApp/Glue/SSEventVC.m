//
//  SSMeetupsVC.m
//  Medistory
//
//  Created by Anping Wang on 10/19/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <Parse/Parse.h>
#import "SSEventVC.h"
#import "SSMeetupEditorVC.h"
#import "SSImageView.h"
#import "SSFilter.h"
#import "SSTableViewCell.h"
#import "SSTimeUtil.h"
#import "SSApp.h"
#import "SSTableRowCell.h"
#import "SSScrollView.h"
#import "SSEventView.h"
#import "SSGlueCatVC.h"
#import "SSFilter.h"
#import "SSProfileVC.h"


@interface SSEventVC ()<SSCalendarCellDelegate,SSScrollViewDelegate>
{
    IBOutlet UIView *vCalendarTitle;
    IBOutlet UILabel *lCalendarTitle;
    SSScrollView *scrollview;
    //transient object
    NSDate *currentDate;
    NSMutableDictionary *categorized;
}

@property NSInteger serviceId;

- (IBAction)changeMonth:(UIButton *)sender;

@end

@implementation SSEventVC

- (void) initPredicates
{
    [self.predicates removeAllObjects];
    //
    //if current user is admin, no filters applied
    //otherwise
    //
    if(![SSProfileVC isAdmin])
    {
        id profile = [SSProfileVC profile];
        if (profile)
        {
            
            SSFilter *retrictionFilter = [SSFilter on:INVITATION_RESTRICTIONS op:CONTAINS value:@[PUBLIC_ACCESS, [[SSProfileVC profile] objectForKey:JOB_TITLE]]];
            SSFilter *ownerFilter = [SSFilter on:AUTHOR op:EQ value:[SSProfileVC profileId]];
            //BOOLEAN Filter
            SSFilter *filter = [SSFilter filter:retrictionFilter or:ownerFilter];
            
            
            [self.predicates addObject: filter];
        }
        else
        {
            //this should not happen, but if it did, only show public events
            SSFilter *retrictionFilter = [SSFilter on:INVITATION_RESTRICTIONS op:CONTAINS value:@[PUBLIC_ACCESS]];
            [self.predicates addObject: retrictionFilter];
            
        }
    }
}

- (void) setDateRange:(NSDate *) dateInMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar] ;
    NSDateComponents *components = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: dateInMonth];
    NSDate *firstDate = [calendar dateFromComponents:components];
    [components setDay:components.day + 1];
    NSDate *lastDate = [calendar dateFromComponents:components];
    [self.predicates addObject: [SSFilter on:DATE_FROM op:GREATER value:firstDate]];
    [self.predicates addObject: [SSFilter on:DATE_FROM op:LESS value:lastDate]];
}

- (void) setMonthRange:(NSDate *) dateInMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar] ;
    NSDateComponents *components = [calendar components: NSCalendarUnitMonth | NSCalendarUnitYear fromDate: dateInMonth];
    NSDate *firstDate = [calendar dateFromComponents:components];
    [components setMonth:components.month + 1];
    NSDate *lastDate = [calendar dateFromComponents:components];
    [self.predicates addObject: [SSFilter on:DATE_FROM op:GREATER value:firstDate]];
    [self.predicates addObject: [SSFilter on:DATE_FROM op:LESS value:lastDate]];
}

- (void) callendarCell:(SSCalendarCell*)calendarCell didSelect:(id)entity
{
    [self initPredicates];
    [self setDateRange:calendarCell.date];
    self.isCalendarView = NO;
    self.navigationItem.leftBarButtonItem.title = CALENDAR;
    [self forceRefresh];
}

- (IBAction)changeMonth:(UIButton *)sender
{
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    [dateComponents setMonth:sender.tag];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    currentDate = [calendar dateByAddingComponents:dateComponents toDate:currentDate options:0];
    [self updateList];
}

- (void) refreshUI
{
    dataView.hidden = NO;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM"];
    lCalendarTitle.text = [dateFormatter stringFromDate:currentDate];
    categorized = [NSMutableDictionary dictionary];
    
    for (id object in self.objects)
    {
        id category = [object objectForKey:self.isLeaf ? SUB_CATEGORY: SERVICE];
        if(category != nil)
        {
            NSMutableArray *objects = [categorized objectForKey:category];
            if (objects == nil)
            {
                objects = [NSMutableArray array];
                [categorized setObject:objects forKey:category];
            }
            [objects addObject:object];
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        if(self.isCalendarView)
        {
            CGRect frame = self.view.frame;
            frame.origin.y = vCalendarTitle.frame.size.height;
            frame.size.height = frame.size.height - frame.origin.y;
            dataView.frame = frame;
        }
        else
        {
            CGRect frame = self.view.frame;
            frame.origin.y = 0;
            dataView.frame = frame;
        }
    }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             vCalendarTitle.hidden = !self.isCalendarView;
                         }
                     }
     ];
     [super refreshUI];
}

- (void) updateList
{
    [self initPredicates];
    if (self.isCalendarView) {
        [self setMonthRange:currentDate];
        [self forceRefresh];
    }
    else
    {
        [self.predicates addObject:[SSFilter on:DATE_FROM op:GREATER value:[NSDate date]]];
        [self forceRefresh];
    }
}

- (void) toggleView:(UIBarButtonItem *) sender
{
    if (!self.isCalendarView)
    {
        sender.title = BROWSE;
        self.title = CALENDAR;
        currentDate = [NSDate date];
    }
    else
    {
        sender.title = CALENDAR;
        self.title = BROWSE;
    }
    self.isCalendarView = !self.isCalendarView;
    [self updateList];
    
}

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = MEETING_CLASS;
     
    self.title = BROWSE;
    self.limit = 30;
    self.tabBarItem.image = [UIImage imageNamed:@"icon_browse.png"];
    self.addable = YES;
    self.queryPrefixKey = TITLE;
    self.orderBy = DATE_FROM;
    self.ascending = YES;
    self.sections = [SSGlueCatVC services];
    [self initPredicates];
    [self.predicates addObject:[SSFilter on:DATE_FROM op:GREATER value:[NSDate date]]];
}


- (NSArray *) getEvents:(SSCalendarCell *)tableView
{
    NSMutableArray *events = [NSMutableArray array];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: tableView.date];
    
    for (id object in self.objects)
    {
        NSDateComponents *dateFrom = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: [object objectForKey:DATE_FROM]];
        if ([components isEqual:dateFrom])
        {
            [events addObject:object];
        }
    }
    return events;
}


- (SSEntityEditorVC *) createEditorFor:(id) item
{
    SSEntityEditorVC *entityEditor;
    if (item == nil)
    {
        entityEditor = [[SSGlueCatVC alloc]init];
    }
    else
    {
        entityEditor = [[SSMeetupEditorVC alloc]init];
    }
    entityEditor.itemType = self.objectType;
    [entityEditor updateEntity:item OfType: self.objectType];
    if(item)
    {
        NSString *organizer = [[item objectForKey:ORGANIZER] objectForKey:USERNAME];
        entityEditor.readonly = ![organizer isEqualToString:[PFUser currentUser].username];
        entityEditor.title = @"Meeting";
    }
    else
    {
        entityEditor.title = @"Create Meeting";
    }
    return entityEditor;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    currentDate = [NSDate date];
    if(NO && !self.isLeaf)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                 initWithTitle:CALENDAR
                                                 style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(toggleView:)];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iOS-7-Wallpaper-Download"]];
}

#pragma tableview

#define CELL @"cell"
#define CAT_SIZE 24
#define CELL_SIZE 113.6
#define TOP_EDGE 0

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isCalendarView) {
        if (indexPath.row == 0) {
            return 30;
        }
        else
        {
            return 45;
        }
    }
    else
    {
        return 8 + CELL_SIZE + TOP_EDGE - (indexPath.row > 1 ? 9 : 8);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.isCalendarView ? 1 : 4;
}

- (void) scrollView: (SSScrollView *) ssClient didSelectView:(id) view
{
    SSEventView *selectedView = (SSEventView *) view;
    [super onSelect:selectedView.event];
}

- (NSInteger ) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isCalendarView)
    {
        return 7;
    }
    return 1;
}

- (UITableViewCell *) rowTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        scrollview = [[SSScrollView alloc]init];
        scrollview.frame = CGRectMake(CAT_SIZE, TOP_EDGE, tableView.frame.size.width - CAT_SIZE, CELL_SIZE );
        scrollview.mode = 1;
        scrollview.tag = 1;
        scrollview.scrollViewDelegate = self;
        scrollview.showsHorizontalScrollIndicator = NO;
        
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CAT_SIZE, CELL_SIZE)];
        UIImageView *bgimage = [[UIImageView alloc] initWithFrame:CGRectMake(CAT_SIZE, 0, tableView.frame.size.width - CAT_SIZE, CELL_SIZE)];
       
        icon.tag = 2;
        bgimage.tag = 3;
        [cell addSubview:bgimage];
        [cell addSubview:scrollview];
        [cell addSubview:icon];
    }

    id sectionKey = [self.sections objectAtIndex:indexPath.section];
    NSArray *objectsInSec = [categorized objectForKey:sectionKey];
    
    SSScrollView *horizView =(SSScrollView*) [cell viewWithTag:1];
    [horizView reset];
    if (self.isLeaf)
    {
        horizView.frame = CGRectMake(0, TOP_EDGE, tableView.frame.size.width, CELL_SIZE );
    }
    else{
        horizView.frame = CGRectMake(CAT_SIZE, TOP_EDGE, tableView.frame.size.width - CAT_SIZE, CELL_SIZE);
    }
    int i = 10;
    for (id item in objectsInSec)
    {
        SSEventView *eventView = (SSEventView *) [horizView viewWithTag:i];
        if (!eventView)
        {
            eventView = [[SSEventView alloc]initWithEvent:item];
            eventView.tag = i;
            eventView.frame = CGRectMake(0, 22, CELL_SIZE - 16, CELL_SIZE - 18);
            eventView.backgroundColor = [UIColor whiteColor];
            [horizView addChildView:eventView];
        }
        else
        {
            eventView.hidden = NO;
            eventView.event = item;
            
        }
        i++;
        [eventView refreshUI];
    }
    [horizView refreshUI];
    UIImageView *bgimage = (UIImageView*) [cell viewWithTag:3];
    bgimage.frame = horizView.frame;
    if(!self.isLeaf)
    {
        switch (indexPath.section) {
            case 0:
                bgimage.image = [UIImage imageNamed:@"browsev04_bg-lunch"];
                break;
            case 1:
                bgimage.image = [UIImage imageNamed:@"browsev04_bg-service"];
                break;
            case 3:
                bgimage.image = [UIImage imageNamed:@"browsev04_bg-social"];
                break;
            case 2:
                bgimage.image = [UIImage imageNamed:@"browsev04_bg-school"];
                break;
            default:
                break;
        }
        UIImageView *icon = (UIImageView*) [cell viewWithTag:2];
        icon.image = [UIImage imageNamed:@"browsev03_sidebutton"];
    }
    else
    {
        
        NSString *imgName = [NSString stringWithFormat:@"sub_bg0%d_0%d",self.serviceId + 1, indexPath.section + 1];
        
        bgimage.image = [UIImage imageNamed:imgName];
        
        UIImageView *icon = (UIImageView*) [cell viewWithTag:2];
        
        icon.image = nil;
    }
    return cell;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isCalendarView)
    {
        return [self calendarView:tableView cellForRowAtIndexPath:indexPath];
    }
    else
    {
        return [self rowTableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isCalendarView)
    {
        return;
    }
    if (!self.isLeaf)
    {
        id sectionKey = [self.sections objectAtIndex:indexPath.section];
        SSEventVC *subevents = [[SSEventVC alloc]init];
        subevents.objectType = self.objectType;
        subevents.offset = 0;
        subevents.limit = 1000;
        subevents.isLeaf = YES;
        subevents.serviceId = indexPath.section;
        subevents.sections = [[SSGlueCatVC categories] objectForKey:sectionKey];
        [subevents.predicates addObject:[SSFilter on:@"service" op:EQ value:sectionKey]];
        subevents.title = sectionKey;
        [self.navigationController pushViewController:subevents animated:YES];
    }
}

- (UITableViewCell *) calendarView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSTableRowCell *cell = (SSTableRowCell *)[tableView dequeueReusableCellWithIdentifier:@"SSTableRowIdentifier"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SSTableRowCell" owner:self options:nil];
        cell = (SSTableRowCell *)[nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if (indexPath.row == 0)
    {
        cell.week = -1;
    }
    else
    {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: currentDate];
        cell.week = indexPath.row - 1;
        cell.month = [components month];
        cell.year = [components year];
    }
    [cell reloadData];
    return cell;
}

- (NSString *) getCellText:(id) rowItem atCol:(int) col
{
    NSString *text = [rowItem valueForKey:TITLE];
    return text ? text : [rowItem valueForKey:ADDRESS_LINE];
}


@end
