//
//  SSInviteEditorVC.m
//  Medistory
//
//  Created by Anping Wang on 10/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SSMapMarker.h"
#import "SSInviteEditorVC.h"
#import "SSMeetupView.h"
#import "SSImageView.h"
#import "SSSecurityVC.h"
#import "SSConnection.h"
#import "SSParticipantVC.h"
#import "SSFilter.h"
#import "SSProfileVC.h"
#import "SSEventVC.h"
#import "SSMeetupEditorVC.h"
#import "SSAddress.h"
#import "SSDateTimeView.h"
#import "SSCarouselView.h"
#import "SSApp.h"

@interface SSInviteEditorVC ()<SSTableViewVCDelegate, SSCarouselViewDelegate>
{
    IBOutlet UIView *vAction;
    IBOutlet UILabel *eventTitle, *subtitle;
    IBOutlet SSImageView *meetIcon;
    IBOutlet SSImageView *organizerIcon;
    IBOutlet UIView *headerView;
    IBOutlet MKMapView *mvEventLoc;
    IBOutlet UIView *vAttendees;
    IBOutlet SSMeetupView *vName;
    IBOutlet UITableView *tvParticipants;
    IBOutlet UISegmentedControl *scStatus;
    IBOutlet UIButton *cancelButton;
    SSParticipantVC *particpants;
    BOOL isOrganizer;
    IBOutlet SSDateTimeView *datetimeView;
    IBOutlet SSCarouselView *participantsView;
    IBOutlet UIView *timeViewHolder;
    IBOutlet UILabel *groups;
    id meet;
}

- (IBAction)changeStatus:(UISegmentedControl *)sender;
- (IBAction)cancelLunch :(id)sender;

@end

@implementation SSInviteEditorVC

- (IBAction) cancelLunch:(id)sender
{
    if (isOrganizer)
    {
      //you can not delete invitation of your own
    }
    else
    {
        [self deleteItem:^(id data) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void) view:(SSCarouselView *)view didSelect:(id)entity
{
    [[SSConnection connector] objectForKey: entity[INVITEE_ID] ofType:PROFILE_CLASS onSuccess:^(id data) {
         SSEntityEditorVC *profileEditor = [[SSApp instance] entityVCFor : PROFILE_CLASS];
         profileEditor.readonly = YES;
         profileEditor.item2Edit = data;
         [self.navigationController pushViewController:profileEditor animated:YES];
    } onFailure:^(NSError *error) {
        //
    }];
   
}

- (void) updateData:(OnCallback)onSuccess
{
    id meetId = [self.item2Edit objectForKey:MEETING_ID];
    if (meetId)
    {
        [[SSConnection connector] objectForKey:meetId ofType:MEETING_CLASS onSuccess:^(id data) {
            meet = data;
            particpants = [[SSParticipantVC alloc]init];
            particpants.defaultHeight = 60;
            [particpants.predicates removeAllObjects];
            [particpants.predicates addObject:[SSFilter on: MEETING_ID
                                                        op: EQ
                                                     value: meetId]];
            
            [particpants refreshOnSuccess:^(id data) {
                onSuccess(self);
            } onFailure:^(NSError *error) {
                //
            }];
        } onFailure:^(NSError *error) {
            //
        }];
    }
}

- (IBAction)changeStatus:(UISegmentedControl *)sender
{
    [self.item2Edit setValue:[NSNumber numberWithInteger:sender.selectedSegmentIndex] forKey:STATUS];
    [self save];
}

- (void) updateMapAtLatitude:(float) latitude longitude:(float) longitude
{
        [mvEventLoc removeAnnotations:mvEventLoc.annotations];
        CLLocationCoordinate2D cord = {latitude, longitude};
        SSMapMarker *ann = [[SSMapMarker alloc] init];
        ann.coordinate = cord;
        [mvEventLoc addAnnotation:ann];
        
        MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
        float longitudeDelta = 0.03;
        float latitudeDelta = 0.03;
        
        region.span.longitudeDelta =  longitudeDelta * 2;
        region.span.latitudeDelta = latitudeDelta * 2;
        
        region.center = cord;
        [mvEventLoc setRegion:region animated:YES];
}

- (void)uiWillUpdate:(id)object
{
    self.title = @"Glue";
    
    meetIcon.url = [object objectForKey:MEETING_ID];
    meetIcon.backupUrl = [object objectForKey:ORGANIZER][REF_ID_NAME];
    

    meetIcon.contentMode = UIViewContentModeScaleAspectFill;
    layoutTable.tableHeaderView = headerView;
    participantsView.carouselViewDelegate = self;
    NSDate *fromDate = [object objectForKey:DATE_FROM];
    cancelButton.hidden = [fromDate compare:[NSDate date]] == NSOrderedAscending;
    
    scStatus.selectedSegmentIndex = [[self.item2Edit objectForKey:STATUS] intValue];
    id organizer = [self.item2Edit objectForKey:ORGANIZER];
    
    isOrganizer = [[organizer objectForKey:REF_ID_NAME] isEqualToString:[SSProfileVC profileId]];
    if (isOrganizer)
    {
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"icon_nojoin"] forState:UIControlStateNormal];
        cancelButton.enabled = false;
    }
    else{
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"icon_leave"] forState:UIControlStateNormal];
    }
    
    datetimeView.datetime = fromDate;
    
    eventTitle.text = [meet objectForKey:TITLE];
    subtitle.text = [NSString stringWithFormat:@"By %@ %@, %@",
                     [meet objectForKey:ORGANIZER][FIRST_NAME],[meet objectForKey:ORGANIZER][LAST_NAME],
                     [meet objectForKey:ADDRESS][STREET_ADDRESS]];
    
    
    organizerIcon.owner = organizer[USERNAME];
    organizerIcon.url = organizer[PICTURE_URL] ? organizer[PICTURE_URL] : organizer[REF_ID_NAME];
    
    particpants.eventVC = self;
    
    
    tvParticipants.dataSource = particpants;
    tvParticipants.delegate = particpants;
    
    if ([particpants.objects count] > 0 )
    {
        [participantsView updateUI:particpants.objects];
        [layoutTable addChildView:participantsView];
        [layoutTable reloadData];
    }
    
    [particpants setDataView:tvParticipants];
    
    SSAddress *address = [[SSAddress alloc]initWithDictionary:[self.item2Edit objectForKey:ADDRESS]];
    
    if(address.latitude)
    {
        [self updateMapAtLatitude:address.latitude longitude:address.longitude];
    }
    
    meet = meet ? meet : object;
    
    [layoutTable removeChildViews];
    int i=1;
    
    if(!cancelButton.hidden)
    {
        [layoutTable addChildView:vAction at:i++];
    }
    
    
    groups.text = meet[DISPLAY_VALUES][meet[GROUP]] ? meet[DISPLAY_VALUES][meet[GROUP]] : meet[GROUP];
    if (!groups.text || [groups.text length]==0)
    {
        groups.text = @"Public";
        
    }

    if(address.latitude)
    {
        [layoutTable addChildView:mvEventLoc at:i++];
    }
    [layoutTable addChildView:timeViewHolder at:i++];
    [layoutTable addChildView:participantsView at:i++];
    [self linkEditFields];
    [layoutTable reloadData];
    
}


@end
