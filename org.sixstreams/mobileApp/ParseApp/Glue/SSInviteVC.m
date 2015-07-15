//
//  SSInviteVC.m
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSInviteVC.h"
#import "SSInviteEditorVC.h"
#import "SSMeetupEditorVC.h"
#import "SSEventVC.h"
#import "SSImageView.h"
#import "SSTableViewCell.h"
#import "SSAddress.h"
#import "SSTimeUtil.h"
#import <Parse/Parse.h>
#import "SSFilter.h"
#import "SSSecurityVC.h"
#import "SSApp.h"
#import "SSConnection.h"
#import "SSGlueCatVC.h"
#import "SSSearchVC.h"
#import "SSProfileVC.h"

@interface SSInviteVC ()<SSEntityEditorDelegate, SSCrudListener>
{
    NSMutableArray *allInvites;
    NSMutableDictionary *sectionedData;
    NSArray *orderedKeys;
    BOOL sectioned;
    BOOL reloadNeeded;
}

- (IBAction) changeType:(UISegmentedControl *)sender;

@end

@implementation SSInviteVC

- (void) setupInitialValues
{
    [super setupInitialValues];
    
    self.tabBarItem.image = [UIImage imageNamed:@"icon_events.png"];
    
    self.myInvites = YES;
    
    self.editable = NO;
    self.orderBy = DATE_FROM;
    self.ascending = NO;
    
    self.objectType = INVITE_CLASS;
    self.limit = 200;
    sectioned = YES;
    self.offset = 0;
    self.ascending = NO;
    sectionedData = [NSMutableDictionary dictionary];
    self.pullRefresh = YES;
    self.addable = YES;
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearch:)];
    search.imageInsets = UIEdgeInsetsMake(2.0, -35.0, 0, 5);
    self.navigationItem.rightBarButtonItems = [self addBarItem: search to:self.navigationItem.rightBarButtonItem];
    [SSConnection addCrudListener:self];
}

- (void) dealloc
{
    [SSConnection removeCrudListener:self];
}

- (void) editObject:(id) item
{
    
    if (item)
    {
        [super editObject:item];
    }
    else
    {
        SSEntityEditorVC *entityEditor = [[SSMeetupEditorVC alloc]init];
        entityEditor.itemType = MEETING_CLASS;
        entityEditor.readonly = NO;
        [self.navigationController pushViewController:entityEditor animated:YES];
        entityEditor.title = @"Event";
    }
    
}

- (IBAction) showSearch:(id) sender
{
    SSSearchVC *events = [[SSSearchVC alloc]init];
    events.objectType = MEETING_CLASS;
    events.titleKey = TITLE;
    events.defaultHeight = 60;
    events.tabBarItem.image = [UIImage imageNamed: @"pageMenuNav_CalendarIcon"];
    events.defaultIconImgName = @"icon_people";
    events.subtitleKey = @"oragnizer.firstName";
    events.iconKey =  REF_ID_NAME;
    events.entityEditorClass = @"SSMeetupEditorVC";
    events.title = @"Events";
    events.subtitleKey = DATE_FROM;
    events.orderBy = CREATED_AT;
    events.addable = NO;
    events.ascending = NO;
    events.appendOnScroll = YES;
    [events refreshOnSuccess:^(id data) {
        [self.navigationItem setBackBarButtonItem: [[UIBarButtonItem alloc]
                                                    initWithTitle: @""
                                                    style: UIBarButtonItemStylePlain
                                                    target: nil action: nil]];
        [self.navigationController pushViewController:events animated:YES];
        
    } onFailure:^(NSError *error) {
        
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(reloadNeeded)
    {
        [super refreshAndWait:^(id data) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                [self refreshUI];
                reloadNeeded = NO;
                
            }];
           
        } onFailure:^(NSError *error) {
            //
        }];
    }
}

- (void) processList
{
    allInvites = self.objects;
    [sectionedData removeAllObjects];
    
    for (id invite in allInvites)
    {
        //NSString *date = [[invite objectForKey:DATE_FROM] toDate];
        NSDateComponents *components = [[NSCalendar currentCalendar]
                                        components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                        fromDate:[invite objectForKey:DATE_FROM]];
        NSDate *date = [[NSCalendar currentCalendar]
                        dateFromComponents:components];
        
        NSMutableArray *dateInvites = [sectionedData objectForKey:date];
        if (dateInvites == nil)
        {
            dateInvites = [NSMutableArray array];
            [sectionedData setObject:dateInvites forKey:date];
        }
        [dateInvites addObject:invite];
    }
    
    orderedKeys = [[sectionedData allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                   {
                       return [b compare:a];
                   }];
}

- (void) onDataReceived:(id) objects
{
    self.objects = objects;
    [self processList];
    [super onDataReceived:objects];
}

- (IBAction) changeType:(UISegmentedControl *)sender
{
    NSMutableArray *invites2Show = [NSMutableArray array];
    if (sender.selectedSegmentIndex == 2)
    {
        for (id item in allInvites) {
            id author = [item objectForKey:ORGANIZER];
            
            if ([[author objectForKey:USERNAME] isEqualToString:[SSSecurityVC username]])
            {
                [invites2Show addObject:item];
            }
        }
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        for (id item in allInvites) {
            id author = [item objectForKey:ORGANIZER];
            
            if (![[author objectForKey:USERNAME] isEqualToString:[SSSecurityVC username]])
            {
                [invites2Show addObject:item];
            }
        }
    }
    else
    {
        invites2Show = allInvites;
    }
    self.objects = invites2Show;
    [self refreshUI];
}

- (void) connection:(SSConnection *)connection didCreate:(id)object ofType:(NSString *)objectType
{
    if ([self.objectType isEqualToString:objectType])
    {
        reloadNeeded = YES;
    }
}

- (void) connection:(SSConnection *)connection didDelete:(id)object ofType:(NSString *)objectType
{
    if ([self.objectType isEqualToString:objectType])
    {
       reloadNeeded = YES;
    }
}

- (BOOL) isInvited:(NSString *) username
{
    BOOL found = NO;
    for(id item in self.objects)
    {
        if ([[item objectForKey:INVITEE] isEqualToString:username])
        {
            found = YES;
            break;
        }
    }
    return found;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *tblView = (UITableViewHeaderFooterView*) view;
    tblView.textLabel.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectioned ? [sectionedData count] : 1;
}

- (NSInteger ) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (sectioned && [orderedKeys count] > 0)
    {
        NSString *key = [orderedKeys objectAtIndex:section];
        return [[sectionedData objectForKey:key] count];
    }
    return [self.objects count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *date = [orderedKeys objectAtIndex:section];
    return sectioned ? [SSTimeUtil stringFromDateWithFormat:@"  EEE MM/dd/yyyy" date: date] : nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SSTableViewCellIdentifier";
    SSTableViewCell *cell = (SSTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SSTableViewCell" owner:self options:nil];
        cell = (SSTableViewCell *)[nib objectAtIndex:0];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    id item = sectioned ? [[sectionedData objectForKey:[orderedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] : [self.objects objectAtIndex:indexPath.row];
    
    [cell assign:item];
    
    cell.icon.defaultImg = [UIImage imageNamed:PERSON_DEFAULT_ICON];
    cell.icon.cornerRadius = 2;
    
    if (self.myInvites)
    {
        cell.icon.owner = item[ORGANIZER][USERNAME];
        cell.icon.url = item[MEETING_ID];
        cell.icon.backupUrl = item[ORGANIZER][REF_ID_NAME];
    }
    else
    {
        cell.icon.owner = [item objectForKey:INVITEE_ID];
        cell.icon.url = item[MEETING_ID];
        cell.icon.backupUrl = item[INVITEE];
    }
    
    id service = item[SERVICE];
    if (service)
    {
        NSUInteger serviceId = [[SSGlueCatVC services] indexOfObject:service];
        NSString *imgName = [NSString stringWithFormat:@"sub_bg0%ld_01", (serviceId + 1)];
        cell.statusIcon.image =[UIImage imageNamed:imgName];
    }
    else
    {
        cell.statusIcon.image = nil;
    }

    id event = item;
    id oraganizer =  event[ORGANIZER];
    
    cell.subtitle.text =   [NSString stringWithFormat:@"%@ %@",
                          oraganizer [FIRST_NAME],
                          oraganizer[LAST_NAME]];

    NSString *location = event[ADDRESS][LOCATION];
    if (location && [location length] > 0)
    {
        cell.author.text  =
        [NSString stringWithFormat:@"%@%@",
         [SSTimeUtil stringFromDateWithFormat:[[SSApp instance] dateTimeFormat] date: event[DATE_FROM]],
         [NSString stringWithFormat:@", %@",location]];
    }
    else{
        cell.author.text  =
        [NSString stringWithFormat:@"%@",
         [SSTimeUtil stringFromDateWithFormat:[[SSApp instance] dateTimeFormat] date: event[DATE_FROM]]];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = sectioned ? [[sectionedData objectForKey:[orderedKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] : [self.objects objectAtIndex:indexPath.row];
    
    [self onSelect:item];
}

- (void) entityEditor:(SSEntityEditorVC *)editor didDelete:(id)entity
{
    for (id object in self.objects) {
        if ([object[REF_ID_NAME] isEqualToString:entity[REF_ID_NAME]])
        {
            [self.objects removeObject:object];
            break;
        }
    }
    [self processList];
    [self refreshUI];
}

- (SSEntityEditorVC *) createEditorFor:(id) item
{
    id organizer = item[ORGANIZER];
    if (organizer && [organizer[AUTHOR] isEqualToString:[SSProfileVC profileId]])
    {
        //we need to get the event
        [self getObject:item[MEETING_ID] objectType:MEETING_CLASS OnSuccess:^(id data) {
            SSEntityEditorVC *entityEditor = [[SSMeetupEditorVC alloc]init];
            entityEditor.readonly = YES;
            entityEditor.itemType = MEETING_CLASS;
            [entityEditor updateEntity:data OfType: MEETING_CLASS];
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                           initWithTitle: @""
                                           style: UIBarButtonItemStylePlain
                                           target: nil action: nil];
            
            [self.navigationItem setBackBarButtonItem: backButton];
            [self.navigationController pushViewController:entityEditor animated:YES];
        } onFailure:^(NSError *error) {
            [self showAlert:@"Sorry, selected event not found, it might have been cancelled" withTitle:@"Error"];
            [self deleteObject:item ofType:self.objectType];
        }];
        return nil;//so the caller will not push the controller
    }
    else
    {
        SSInviteEditorVC *entityEditor = [[SSInviteEditorVC alloc]init];
        entityEditor.title = [item objectForKey:TITLE];
        entityEditor.readonly = YES;
        [entityEditor updateEntity:item OfType: self.objectType];
        entityEditor.entityEditorDelegate = self;
        return entityEditor;
    }
}

@end
