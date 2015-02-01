//
//  SSMeetupEditorVC.m
//  Medistory
//
//  Created by Anping Wang on 10/19/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "SSMapMarker.h"
#import "SSMeetupEditorVC.h"
#import <Parse/Parse.h>
#import "SSTableViewVC.h"
#import "SSDatePickerVC.h"
#import "SSAddressVC.h"
#import "SSInviteVC.h"
#import "SSProfileVC.h"
#import "SSSecurityVC.h"
#import "SSConnection.h"
#import "SSTimeUtil.h"
#import "SSMeetupView.h"
#import "SSFilter.h"
#import "SSDateTextField.h"
#import "SSLovTextField.h"
#import "SSApp.h"
#import "SSCheckBox.h"
#import "SSRoundTextView.h"
#import "SSImagesVC.h"
#import "SSAddressField.h"
#import "SSParticipantVC.h"
#import "SSGlueCatVC.h"
#import "SSRoundView.h"
#import "SSDateTimeView.h"
#import "SSCarouselView.h"


@interface SSMeetupEditorVC ()<SSListOfValueDelegate, SSTableViewVCDelegate, UIScrollViewDelegate, SSCarouselViewDelegate>
{
    IBOutlet UIView *webView;
    IBOutlet SSDateTimeView *datetimeView;
    IBOutlet UIButton *nxt1, *nxt2, *nxt3;
    IBOutlet UILabel *groupsLabel;
    IBOutlet MKMapView *mapView;
    
    IBOutlet UILabel *hint4HeadlingPic;
    IBOutlet UIView *vHeader;
    IBOutlet SSImageView *orgIcon;
    IBOutlet UIView *vFooter;
    IBOutlet UIView *vNotes;

    IBOutlet UIView *vEventDetails;
    IBOutlet SSRoundButton *btnInvite;
    IBOutlet UILabel *lseats;
    IBOutlet UILabel *lduration;
    
    IBOutlet SSParticipantVC *particpants;
    
    IBOutlet SSCarouselView *participantsView;
    
    IBOutlet SSProfileVC *profileVC;
    
    IBOutlet UIButton *join;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIButton *deleteBtn;
    IBOutlet UIView *vAction;
    IBOutlet UIView *vLocationView;
    
    IBOutlet SSRoundView *detailsEditor;
    IBOutlet UIView *editView;
    
    IBOutlet UIButton *btnAddImg;
    IBOutlet UILabel *selectedCategory;
    BOOL notificationNeeded;
    
    IBOutlet UISlider *durationSlider;
    IBOutlet UISlider *seatsSlider;
    IBOutlet UILabel *milesLabel;
    
    IBOutlet UIButton *btnSpotlights;
    SSAddress *address;
    NSDate *dateFrom;
    NSDate *dateTo;
    float maxDuration;
    
    BOOL myEvent;
    int incremental;
    float maxSeatsAllowed;
    NSMutableArray *invited;
    NSString *myInviteId;
    BOOL addedSelf;
    IBOutlet UISwitch *sNearby;
    BOOL hasImage;
}
- (IBAction)invite:(id)sender;

@end

@implementation SSMeetupEditorVC

- (IBAction)distanceChanged:(UISlider *)sender
{
    milesLabel.text = [NSString stringWithFormat:@"%.0f miles", sender.value];
}

- (IBAction)makeInSpotlights:(UIButton *)sender {
    [self.item2Edit setObject:[NSNumber numberWithBool:YES] forKey: SPOT_LIGHTS];
    sender.hidden = YES;
    [self save];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    maxSeatsAllowed = 1;
    maxDuration = 36;
    particpants.eventVC = self;
    incremental = 1;
    incremental = 30;
}

- (IBAction)seatsChanged:(UISlider *)sender
{
    lseats.text = [NSString stringWithFormat:@"%d", [[NSNumber numberWithFloat:sender.value] intValue]];
    if (![self.item2Edit[SEATS] isEqual: [NSNumber numberWithInt:sender.value]])
    {
        self.item2Edit[SEATS] = [NSNumber numberWithInt:sender.value];
        self.valueChanged = YES;
    }
}

- (void) updateMap
{
    if (address.latitude != 0)
    {
        [mapView removeAnnotations:mapView.annotations];
        CLLocationCoordinate2D cord = {address.latitude, address.longitude};
        SSMapMarker *ann = [[SSMapMarker alloc] init];
        ann.coordinate = cord;
        [mapView addAnnotation:ann];
        
        MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
        float longitudeDelta = 0.03;
        float latitudeDelta = 0.03;
        
        region.span.longitudeDelta =  longitudeDelta * 2;
        region.span.latitudeDelta = latitudeDelta * 2;
        
        region.center = cord;
        [mapView setRegion:region animated:YES];
    }
    else
    {
        [mapView removeAnnotations:mapView.annotations];
        
        [mapView setMapType:MKMapTypeStandard];
        
        MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
        float longitudeDelta = 0.03;
        float latitudeDelta = 0.03;

        region.span.longitudeDelta =  longitudeDelta * 2;
        region.span.latitudeDelta = latitudeDelta * 2;

        [mapView setRegion:region animated:YES];
    }
}

- (void) clearFilters
{
    [super clearFilters];
    sNearby.on = NO;
}

- (NSArray *) getFilters
{
    if (sNearby.on)
    {
        SSValueField *nearBy = [[SSValueField alloc]init];
        nearBy.attrName = NEAR_BY;
        nearBy.value = [NSNumber numberWithInt:[milesLabel.text intValue]];
        return  [[super getFilters] arrayByAddingObject:nearBy];
    }
    else{
        return [super getFilters];
    }
}

- (IBAction)durationChanged:(UISlider *)sender
{
    int iValue = [[NSNumber numberWithFloat:sender.value*maxDuration] intValue];
    
    int value = incremental * (iValue - (iValue % incremental)) / incremental;
    if (![self.item2Edit[DURATION_IN_MINUTES] isEqual: [NSNumber numberWithInt:value]])
    {
        self.valueChanged = YES;;
    }
    int min = value % 60;

    int hour = (value - min)/60;
    if (hour <= 0)
    {
        lduration.text = [NSString stringWithFormat:@"%d mins",min];
    }
    else if (min == 0)
    {
        lduration.text = [NSString stringWithFormat:@"%d hr",hour];
    }
    else
    {
        lduration.text = [NSString stringWithFormat:@"%d hr %d mins",hour, min];
    }
    self.item2Edit[DURATION_IN_MINUTES] = [NSNumber numberWithInt:value];
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

- (void) valueEditor:(SSValueEditorVC *)valueEditor valueChanged:(id)value
{
    if ([valueEditor isKindOfClass:[SSDatePickerVC class]])
    {
        NSString *key = ((UIButton *) valueEditor.contextObject).tag == 0 ? DATE_FROM : DATE_TO;
        [self.item2Edit setObject: value forKey:key];
    }
    else
    {
        [self.item2Edit setObject: [value dictionary] forKey:ADDRESS];
        [self.item2Edit setValue:[value description] forKey:ADDRESS_LINE];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.readonly && !mapView)
    {
        mapView = [[MKMapView alloc]initWithFrame:CGRectMake(5, 32, vLocationView.frame.size.width - 10, 120)];
        mapView.scrollEnabled = NO;
        mapView.zoomEnabled = NO;
        [self updateMap];
        [vLocationView addSubview:mapView];
    }
}

- (void) uiWillUpdate:(id)entity
{
    [super uiWillUpdate:entity];
    
    if (entity == nil || participantsView == nil)
    {
        return;
    }
    
    if (self.item2Edit[ADDRESS])
    {
        address = [[SSAddress alloc] initWithDictionary: self.item2Edit[ADDRESS]];
    }
    
    participantsView.carouselViewDelegate = self;
    self.title = @"GLUE";
    btnAddImg.hidden = ![[SSProfileVC profileId] isEqualToString: [[entity objectForKey:ORGANIZER] objectForKey:REF_ID_NAME]];
    id organizer = entity[ORGANIZER];
    if (organizer)
    {
        orgIcon.owner = organizer[USERNAME];
        orgIcon.url = organizer[PICTURE_URL] ? organizer[PICTURE_URL] : organizer[REF_ID_NAME];
    }
    if(entity[SERVICE])
    {
        selectedCategory.text = [NSString stringWithFormat:@"%@/%@", entity[SERVICE], entity[SUB_CATEGORY]];
    }
    
    dateFrom = [entity valueForKey:DATE_FROM];
    dateTo = [entity valueForKey:DATE_TO];
    datetimeView.datetime = dateFrom;
    btnSpotlights.hidden = ![SSProfileVC isAdmin] || [[entity objectForKey: SPOT_LIGHTS]boolValue] || [dateFrom compare:[NSDate date]] == NSOrderedAscending;
    
    if (!dateTo && dateFrom)
    {
        dateTo = [NSDate dateWithTimeInterval:3600 sinceDate:dateFrom];
    }

    myEvent = [self.item2Edit[AUTHOR] isEqualToString:[self profileId]];
    
    [layoutTable removeChildViews];
    
    if(self.readonly)
    {
        
        groupsLabel.text = self.item2Edit[DISPLAY_VALUES][self.item2Edit[GROUP]] ? self.item2Edit[DISPLAY_VALUES][self.item2Edit[GROUP]] : self.item2Edit[GROUP];

        [layoutTable addChildView: webView];
        [layoutTable addChildView: vLocationView];

        if([entity objectForKey:REF_ID_NAME] && particpants)
        {
            [particpants.predicates removeAllObjects];
            [particpants.predicates addObject:[SSFilter on: MEETING_ID
                                                        op: EQ
                                                     value: [entity objectForKey:REF_ID_NAME]]];
            particpants.tableViewDelegate = self;
            [particpants forceRefresh];
        }
        else
        {
            particpants.view.hidden = YES;
        }
    }
    else
    {
        self.title = self.isCreating ? @"Create Event" : @"Edit Event";
        [layoutTable addChildView: editView];
        [layoutTable addChildView:detailsEditor];
        [layoutTable addChildView:vNotes];
        [layoutTable addChildView:vFooter];
    }
    
    hint4HeadlingPic.hidden = self.readonly;
    deleteBtn.hidden = self.isCreating || !myEvent;
    if (self.readonly)
    {
        layoutTable.tableHeaderView = vHeader;
    }
    else
    {
        layoutTable.tableHeaderView = iconView;
    }
    //
    if([entity objectForKey:DURATION_IN_MINUTES])
    {
        int iDuration = [[entity objectForKey:DURATION_IN_MINUTES] intValue];
        durationSlider.value = iDuration/maxDuration;
        seatsSlider.value = [entity[SEATS] intValue];
        [self durationChanged:durationSlider];
        [self seatsChanged:seatsSlider];
        durationSlider.userInteractionEnabled = seatsSlider.userInteractionEnabled = YES;
        seatsSlider.enabled = YES;
    }
    [self linkEditFields];
}

- (void) entityDidSave:(id) entity
{
     [super entityDidSave:entity];
    if (self.isCreating && !addedSelf)
    {
        addedSelf = YES;
        [self addInvite:[SSProfileVC profile]];
    }
}

- (BOOL) checkSaveable
{
    BOOL saveable = [super checkSaveable];
    if (!saveable)
    {
        return saveable;
    }
    else
    {
        saveable = iconView.imageChanged || iconView.url;
        if (!saveable)
        {
            [self showAlert:@"Image is requried for an event" withTitle:@"Error"];
        }
        return saveable;
    }
}

- (void) entityWillSave:(id)entity
{
    [super entityWillSave:entity];
    
    self.item2Edit = entity;
    [self.item2Edit setValue:[PFUser currentUser].username forKey:USERNAME];
    
    if (dateFrom == nil)
    {
        dateFrom = [NSDate date];
    }
    
    NSString *org = [self.item2Edit valueForKey:ORGANIZER];
    
    if (org==nil)
    {
        [self.item2Edit setValue:[SSProfileVC profile] forKey:ORGANIZER];
    }
    
    int iValue = [[NSNumber numberWithFloat:durationSlider.value*maxDuration] intValue];
    
    //int value = incremental * (iValue - (iValue % incremental)) / incremental;
    
    entity[SEATS] = [NSNumber numberWithInt: seatsSlider.value];
    entity[DURATION_IN_MINUTES] = [NSNumber numberWithInt: iValue];
    
    if(self.isCreating)
    {
        entity[ATTENDEES] = [NSNumber numberWithInt:0];
        entity[STATUS] = @"open";
    }
    
    id groups = entity[GROUP];
    
    if (groups == nil )
    {
        entity[GROUP] = @"public";
    }
}

- (void) tableViewVC:(id) tableViewVC didLoad : (id) objects
{
    if ([tableViewVC isEqual:particpants])
    {
        BOOL found = NO;
        for(id item in objects)
        {
            if ([[item objectForKey:INVITEE_ID] isEqualToString:[self profileId]])
            {
                found = YES;
                myInviteId = item[REF_ID_NAME];
                break;
            }
        }
        
        particpants.view.hidden = [objects count] == 0;
        if ([objects count] > 0 )
        {
            [participantsView updateUI:objects];
            [layoutTable addChildView:participantsView];
            [layoutTable reloadData];
        }
        
        join.hidden = found || myEvent|| [dateFrom timeIntervalSinceDate:[NSDate date]] < 0;
        cancelBtn.hidden = ! found || myEvent || [dateFrom timeIntervalSinceDate:[NSDate date]] < 3600;
        if(!cancelBtn.hidden || !join.hidden)
        {
            [layoutTable addChildView: vAction at:2];
            [layoutTable reloadData];
            
        }
    }
}

#pragma inivites

- (void) addInvite:(id)userProfile
{
    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
    newDic[MEETING_ID] = self.item2Edit[REF_ID_NAME];
    newDic[TITLE] = self.item2Edit[TITLE];
    newDic[DATE_FROM] = self.item2Edit[DATE_FROM];
    newDic[ORGANIZER] = self.item2Edit[ORGANIZER];
    
    if(userProfile[ADDRESS])
    {
        newDic[ADDRESS] = userProfile[ADDRESS];
    }
    
    if(userProfile[PICTURE_URL])
    {
        newDic[PICTURE_URL] = userProfile[PICTURE_URL];
    }
    
    newDic[INVITEE] = userProfile[USERNAME];
    newDic[FIRST_NAME] = userProfile[FIRST_NAME];
    newDic[LAST_NAME] = userProfile[LAST_NAME];
    newDic[INVITEE_ID] = userProfile[REF_ID_NAME];
    newDic[STATUS] = [NSNumber numberWithInt:0];
    
    SSConnection *conn = [SSConnection connector];
    [conn createObject:newDic ofType:INVITE_CLASS
             onSuccess:^(NSDictionary *data){
                 if (!self.isCreating) {
                     //now refresh my events and show it
                    [self.navigationController popToRootViewControllerAnimated:YES];
                 }
             }
             onFailure:^(NSError *error) {
                 join.enabled = YES;
             }];
}

- (NSArray *) selectedValuesFor:(id)tableView
{
    return invited;
}

- (BOOL) listOfValues:(id)tableView isSelected:(id)entity
{
    return [invited containsObject:entity];
}

- (void) listOfValues:(id) tableView didSelect : (id) entity
{
    if(invited == nil)
    {
        invited = [NSMutableArray array];
    }
    if ([invited containsObject:entity])
    {
        [invited removeObject:entity];
    }
    else
    {
        [invited addObject:entity];
    }
    [tableView refreshUI];
}

- (BOOL) multiValueAllowedFor:(id) tableView
{
    return YES;
}

- (IBAction)invite:(id)sender
{
    SSProfileVC *lov = [[SSProfileVC alloc]init];
    lov.listOfValueDelegate = self;
    [self.navigationController pushViewController:lov animated:YES];
}

- (IBAction)join:(id)sender
{
    join.enabled = NO;
    [self addInvite:[SSProfileVC profile]];
    [[SSConnection connector] subscribeToChannel:[NSString stringWithFormat:@"event_%@", [self.item2Edit objectForKey:REF_ID_NAME]]];
}

- (IBAction)leave:(id)sender
{
    if (myInviteId)
    {
        [self deleteEntity:myInviteId OfType:INVITE_CLASS onSuccess:^(id data) {
            [self uiWillUpdate:self.item2Edit];
        }];
    }
}

@end
