//
//  WCRoasterDetailsVC.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/18/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCRoasterDetailsVC.h"
#import "WCMapMarker.h"
#import "WCSetupVC.h"
#import "WCHomeVC.h"

#import "SSCommentVC.h"
#import "SSSecurityVC.h"
#import "SSImagesVC.h"
#import "SSImageView.h"
#import "SSStarRating.h"
#import "SSValueField.h"
#import "SSAddressField.h"
#import "SSRoundTextView.h"
#import "SSAddress.h"
#import "SSProductsValueField.h"


@interface WCRoasterDetailsVC ()<SSTableViewVCDelegate, UITableViewDelegate, SSEntityEditorDelegate, SSListOfValueFieldDelegate>
{
    IBOutlet UIView *vEditor;
    
    IBOutlet UIView *vFooter;
    IBOutlet SSProductsValueField *tvProducts;
    __weak IBOutlet SSValueField *tfOpenHours;
    __weak IBOutlet SSValueField *tfFacebook;
    __weak IBOutlet SSValueField *tfWebsite;
    __weak IBOutlet SSValueField *tfPhone;
    __weak IBOutlet SSValueField *tfEmail;
    __weak IBOutlet SSValueField *tfName;
    
    IBOutlet UIView *vActions;
    __weak IBOutlet SSValueField *tfBeans;
    
    IBOutlet UIView *vContacts;
    
    __weak IBOutlet SSRoundTextView *tvSummary;
    __weak IBOutlet SSAddressField *tfAddress;
    IBOutlet SSStarRating *cafeRating;
    IBOutlet SSImageView *ownerIcon;
    IBOutlet UIView *vMap;
    IBOutlet MKMapView *mapView;
    IBOutlet UIView *commandView;
    IBOutlet UIView *summaryView;
    IBOutlet UILabel *lName;
    IBOutlet UILabel *beans;
    IBOutlet UILabel *phone;
    IBOutlet UILabel *website;
    IBOutlet UILabel *email;
    IBOutlet UIButton *liked;
    IBOutlet UILabel *address;
    IBOutlet UILabel *address2;
    IBOutlet UIButton *phoneBtn;
    IBOutlet UIButton *webBtn;
    SSImagesVC *imageVC;
    SSRoundTextView *descView;
}

@end

@implementation WCRoasterDetailsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.readonly = YES;
    }
    return self;
}

- (IBAction)checkin:(id)sender {

}

- (IBAction)promote:(id)sender {
}

- (IBAction)openWeb:(id)sender
{
    if ([website.text length] != 0)
    {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", website.text]]];
    }
}


- (IBAction)makeCall:(id)sender
{
    if ([phone.text length] != 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Call "
                                                       message: phone.text
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if ([phone.text length] != 0)
        {
            NSString *phoneNumber  = [self.item2Edit objectForKey:PHONE];//
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]];
        }
    }
}

- (void) entityEditor:(SSEntityEditorVC *)editor didSave:(id)entity
{
    self.item2Edit = entity;
    if (self.action == SSViewEntity)
    {
        [self initializeView];
    }
    else
    {
        [self initializeEditing];
    }
    [editor.navigationController popViewControllerAnimated:YES];
}

- (void) editItem:(id) sender
{
    WCRoasterDetailsVC *viewController3 = [[WCRoasterDetailsVC alloc] init];
    viewController3.action = SSEditEntity;
    viewController3.item2Edit = self.item2Edit;
    viewController3.itemType = self.itemType;
    viewController3.title = @"Edit";
    viewController3.entityEditorDelegate = self;
    [viewController3 uiWillUpdate:self.item2Edit];
    [self.navigationController pushViewController:viewController3 animated:YES];
}

- (void) listField:(id) listfield didAdd:(id) item
{
    [layoutTable reloadData];
}

- (void) listField:(id) listfield didDelete:(id) item
{
    [layoutTable reloadData];
}


- (void) initializeView
{
    phone.text = [self.item2Edit objectForKey:PHONE];
    if(phone.text)
    {
        phone.text = [phone.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        phone.text = [phone.text toPhoneNumber];
        [self addTapEvent:phone onTap:@selector(makeCall:)];
    }
    
    email.text = [self.item2Edit objectForKey:EMAIL] ? [self.item2Edit objectForKey:EMAIL] : @"";
    
    if ([email.text isEqualToString:@"null"])
    {
        email.text = @"";
    }
    
    SSAddress *addressObj = [[SSAddress alloc]initWithDictionary:[self.item2Edit objectForKey:ADDRESS]];
    
    if (addressObj.longitude == 0)
    {
        [addressObj updateLocation];
        self.item2Edit[@"longitude"] = [NSNumber numberWithFloat:addressObj.longitude];
        self.item2Edit[@"latitude"] = [NSNumber numberWithFloat:addressObj.latitude];
        self.item2Edit[ADDRESS] = [addressObj dictionary];
        [self saveInternal:^(id data) {
            NSLog(@"Update cordinates data");
        }];
    }
    
    tvProducts.item = self.item2Edit;
    address.text = addressObj.street;
    address2.text = [NSString stringWithFormat:@"%@, %@", addressObj.city, addressObj.state];
    
    beans.text = [self.item2Edit objectForKey:@"beans"];
    website.text = [self.item2Edit objectForKey:WEB_SITE];
    
    if(website.text)
    {
        [self addTapEvent:website onTap:@selector(openWeb:)];
    }
         
    liked.titleLabel.text = [self.item2Edit objectForKey:@"liked"];
    
    [mapView removeAnnotations:mapView.annotations];
    [mapView setMapType:MKMapTypeStandard];
    
    WCMapMarker *ann = [WCMapMarker getMarker:self.item2Edit];
    
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center = ann.coordinate;
    region.span.longitudeDelta = 0.1f;
    region.span.latitudeDelta = 0.1f;
    
    [mapView addAnnotation:ann];
    [mapView setRegion:region animated:YES];
    
    if ([WCSetupVC isAdmin])
    {
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editItem:)];
    }
    
    
    int i=1;
    
    imageVC = [[SSImagesVC alloc]init];
    imageVC.relatedId = [self.item2Edit objectForKey:REF_ID_NAME];
    imageVC.tableViewDelegate = self;
    imageVC.singlePicture = YES;
    imageVC.relatedType = self.itemType;
    
    imageVC.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.width/2);
    
    [layoutTable removeChildViews];
    
    [layoutTable addChildView:summaryView at:i++];

    NSString *desc = [self.item2Edit objectForKey:DESC];
    
    if (desc && [desc length] > 0)
    {
        descView.backgroundColor = [UIColor whiteColor];
        descView.alpha = 0.8;
        descView.text = desc;
        descView.font = tvSummary.font;
        [layoutTable addChildView:descView at:i++];
    }
    
    tvProducts.editable = !self.readonly;
    
    [layoutTable addChildView:vMap at:i++];
   
    if([tvProducts.items count]>0 || !self.readonly)
    {
        [layoutTable addChildView:tvProducts at:i++];
    }
    
  
    [super doLayout];
    
    
    [layoutTable addChildView:commandView at:i++];

    [layoutTable addChildView: vFooter at:i++];
    
    ownerIcon.url = [self.item2Edit objectForKey:AUTHOR];
    ownerIcon.defaultImg = [UIImage imageNamed:@"people"];
    ownerIcon.cornerRadius = ownerIcon.frame.size.width/2;

    //ownerIcon.cornerRadius = ownerIcon.frame.size.width/2;
    
    cafeRating.rating = [[self.item2Edit objectForKey:RATING]floatValue];
    cafeRating.tintColor = [UIColor redColor];
    cafeRating.editable = NO;
    cafeRating.backgroundColor = [UIColor clearColor];
    
    [imageVC forceRefresh];
    //[commentsVC forceRefresh];
    
    self.title = [self.item2Edit objectForKey: NAME];
    lName.text = self.title;
    [self linkEditFields];
    [layoutTable reloadData];
}

- (void) initializeEditing
{
    [layoutTable removeChildViews];
    if (self.item2Edit)
    {
        tfAddress.value = [self.item2Edit objectForKey:tfAddress.attrName];
        tfBeans.value = [self.item2Edit objectForKey:tfBeans.attrName];
        tfName.value = [self.item2Edit objectForKey:tfName.attrName];
        tfEmail.value = [self.item2Edit objectForKey:tfEmail.attrName];
        tfPhone.value = [self.item2Edit objectForKey:tfPhone.attrName];
        tfOpenHours.value =[self.item2Edit objectForKey:tfOpenHours.attrName];
        tfWebsite.value = [self.item2Edit objectForKey:tfWebsite.attrName];
        tfFacebook.value = [self.item2Edit objectForKey:tfFacebook.attrName];
        tvSummary.text = [self.item2Edit objectForKey:tvSummary.attrName];
        tvProducts.item = self.item2Edit;
        
        iconView.url = [self.item2Edit objectForKey:REF_ID_NAME];
        iconView.defaultImg = [UIImage imageNamed:@"shop"];
    }
    
    tvProducts.editable = YES;
    tvProducts.fieldDelegate = self;
    self.title = self.item2Edit ? [self.item2Edit objectForKey:NAME] : @"Create Store";
    
    [layoutTable addChildView:vEditor at:1];
    [layoutTable addChildView:vContacts at:2];
    [layoutTable addChildView:tvProducts at:3];
    [layoutTable addChildView:vActions at:4];
    [layoutTable addChildView:vFooter at:5];
     [self linkEditFields];
    [layoutTable reloadData];
}

- (void) uiWillUpdate:(id)object
{
    if (self.action == SSViewEntity)
    {
        [self initializeView];
    }
    else
    {
        [self initializeEditing];
    }
}


- (void) entityWillSave:(id)object
{
    SSAddress *cafeAddress = [[SSAddress alloc] initWithDictionary:[object objectForKey:ADDRESS]];
    if(cafeAddress)
    {
        [object setValue:[@[object[NAME], cafeAddress.city] toKeywordList] forKey:SEARCHABLE_WORDS];
    }
    else
    {
        [object setValue:[@[object[NAME]] toKeywordList] forKey:SEARCHABLE_WORDS];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.readonly = self.action == SSViewEntity;
    tfAddress.attrName = ADDRESS;
    tfName.attrName = NAME;
    tfBeans.attrName = BEANS;
    tvSummary.attrName = DESC;
    tfEmail.attrName = EMAIL;
    tfPhone.attrName = PHONE;
    tfWebsite.attrName = WEB_SITE;
    tfFacebook.attrName = FACEBOOK;
    tfOpenHours.attrName = HOURS;
    iconView.cornerRadius = 4;
    tvProducts.parentVC = self; tvProducts.attrName = PRODUCT;
}

- (void) edit
{
    [SSSecurityVC checkLogin:self withHint:@"Signin" onLoggedIn:^(id user) {
        if (user) {
            if ([self.navigationController topViewController] != self) {
                [self.navigationController popViewControllerAnimated:NO];
            }
            [self editItem:self.item2Edit];
        }
    }];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [imageVC stopAnimation];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationController.navigationBar.hidden = NO;
    
    if (self.readonly)
    {
        UIBarButtonItem *addAcc = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                   target:self
                                   action:@selector(edit)];
        NSMutableArray *arrBtns = [[NSMutableArray alloc]initWithObjects:addAcc, nil];
        self.navigationItem.rightBarButtonItems = arrBtns;
    }
}

- (void) tableViewVC:(id) tableViewVC didLoad : (id) objects
{
    if([imageVC isEqual:tableViewVC])
    {
        if ([imageVC.objects count] > 0)
        {
            layoutTable.tableHeaderView = imageVC.view;
            if ([imageVC.objects count] > 1)
            {
                [imageVC startAnimation];
            }
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}
@end
