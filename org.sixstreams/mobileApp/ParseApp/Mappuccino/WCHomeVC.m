//
//  WCFirstViewController.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/16/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCHomeVC.h"
#import "WCByNBameVC.h"
#import "WCByCityVC.h"
#import "SSConnection.h"
#import "WCRoasterDetailsVC.h"
#import "SSSecurityVC.h"
#import "SSAddress.h"
#import "SSProfileVC.h"
#import "SSImagesVC.h"
#import "SSImageView.h"
#import "SSFilter.h"
#import "SSJSONUtil.h"

@interface WCHomeVC ()
{
    IBOutlet SSImageView *spotlightView;
}

- (IBAction) uploadData;
- (IBAction) uploadCity;

@end

@implementation WCHomeVC

static NSString *HOME = @"Home";


- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = COMPANY_CLASS;
    
    self.title = @"Mappuccino";
    self.addable = NO;
    
    self.limit = 40;
    self.queryPrefixKey = TITLE;
    self.orderBy = CREATED_AT;
    self.ascending = NO;
    
    [self.predicates removeAllObjects];
    //[self.predicates addObject:[SSFilter on:RELATED_TYPE op:EQ value: ROASTER_CLASS_TYPE]];
}

- (void) animate
{
    
}

- (void) onDataReceived:(id)objects
{
    if ([objects count]>0)
    {
        //start animation
        spotlightView.url = [[objects objectAtIndex:0] objectForKey:REF_ID_NAME];
    }
}


- (id) toCafe:(id) old
{
    NSMutableDictionary *new = [NSMutableDictionary dictionary];
    [new setObject:[NSNumber numberWithFloat:[[old objectForKey:LATITUDE] floatValue]] forKey:LATITUDE];
    [new setObject:[NSNumber numberWithFloat:[[old objectForKey:LONGITUDE] floatValue]] forKey:LONGITUDE];
    
    [new setValue:[old objectForKey:NAME] forKey:NAME];
    [new setValue:[old objectForKey:BEANS] forKey:BEANS];
    [new setValue:[old objectForKey:EMAIL]  forKey:EMAIL];
    [new setValue:[old objectForKey:CITY]  forKey:CITY];
    [new setValue:[old objectForKey:AREA]  forKey:AREA];
    [new setValue:[old objectForKey:METRO]  forKey:METRO];
    [new setValue:[old objectForKey:STATUS]  forKey:STATUS];
    [new setValue:[old objectForKey:PHONE]  forKey:PHONE];
    [new setValue:[old objectForKey:HOURS]  forKey:HOURS];
    [new setValue:[old objectForKey:EMAIL]  forKey:EMAIL];
    [new setValue:[old objectForKey:WEB_SITE] forKey:WEB_SITE];
    [new setValue:[old objectForKey:@"notes"]  forKey:DESC];
    
    SSAddress *address = [[SSAddress alloc]initWithDictionary:old];
    address.zipCode = [old objectForKey:@"postalCode"];
    address.street = [old objectForKey:ADDRESS];
    [new setValue:[address dictionary] forKeyPath:ADDRESS];
    [new setValue:[SSProfileVC profileId] forKeyPath:AUTHOR];
    [new setValue: [[old objectForKey:NAME] toKeywordList] forKeyPath:SEARCHABLE_WORDS];
    
    return new;
}

- (IBAction) uploadData
{
    [SSSecurityVC checkLogin:self withHint:@"" onLoggedIn:^(id user) {
        if(user)
        {
            NSString *myFile = [[NSBundle mainBundle] pathForResource:@"seededroasters" ofType:@"plist"];
            NSMutableArray *myArray = [[NSMutableArray alloc]initWithContentsOfFile:myFile];
            NSMutableArray *cafes = [NSMutableArray array];
            for (id roaster in myArray) {
                [cafes addObject:[self toCafe:roaster]];
            }
            SSConnection *conn = [SSConnection connector];
            [conn uploadObjects:cafes ofType:COMPANY_CLASS];
            [self uploadCity];
            DebugLog(@"%@", cafes);
        }
    }];
}

- (IBAction) uploadCity
{
    NSString *myFile = [[NSBundle mainBundle] pathForResource:@"seededroasters" ofType:@"plist"];
    NSMutableArray *myArray = [[NSMutableArray alloc]initWithContentsOfFile:myFile];
    NSMutableArray *myCities = [NSMutableArray array];
    NSMutableArray *myCityObjects = [NSMutableArray array];
    
    for (id roaster in myArray) {
        if (![myCities containsObject:[roaster objectForKey:@"city"]]) {
            [myCities addObject:[roaster objectForKey:@"city"]];
            [myCityObjects addObject:[NSDictionary dictionaryWithObjectsAndKeys:[roaster objectForKey:@"city"], @"city", nil]];
    
        }
    }
    SSConnection *conn = [SSConnection connector];
    [conn uploadObjects:myCityObjects ofType:@"com.sixstreams.mappuccino.City"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"53-house"];
        self.tabBarItem.title = HOME;
    }
    return self;
}

- (void) dataDidLoad: (NSArray *)data
{

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.navigationController.navigationBar.hidden = YES;
}


- (IBAction) showByName:(id)sender
{
    WCByNBameVC *viewController3 = [[WCByNBameVC alloc] initWithNibName:@"WCByNBameVC" bundle:nil];
    
    [viewController3 refreshOnSuccess:^(id data) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: HOME
                                       style: UIBarButtonItemStylePlain
                                       target: nil action: nil];
        [self.navigationItem setBackBarButtonItem: backButton];
        [self.navigationController pushViewController:viewController3 animated:YES];
    } onFailure:^(NSError *error) {
        [self showAlert:@"Failed to load data" withTitle:@"Error"];
    }];
}

- (IBAction) showByCity:(id)sender
{
    WCByCityVC *cityVC = [[WCByCityVC alloc] initWithNibName:@"WCByCityVC" bundle:nil];
        [cityVC refreshOnSuccess:^(id data) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                           initWithTitle: HOME
                                           style: UIBarButtonItemStylePlain
                                           target: nil action: nil];

        [self.navigationItem setBackBarButtonItem: backButton];
        [self.navigationController pushViewController:cityVC animated:YES];

    } onFailure:^(NSError *error) {
        [self showAlert:@"Failed to load data" withTitle:@"Error"];
    }];
}


- (IBAction) showRecommend:(id)sender
{
    [SSSecurityVC checkLogin:self withHint:@"Add New Cafe" onLoggedIn:^(id user) {
        WCRoasterDetailsVC *viewController3 = [[WCRoasterDetailsVC alloc] init];
        viewController3.action =  SSCreateEntity;
        viewController3.item2Edit = nil;
        viewController3.itemType = COMPANY_CLASS;
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: HOME
                                       style: UIBarButtonItemStylePlain
                                       target: nil action: nil];
        [self.navigationItem setBackBarButtonItem: backButton];
        
        [self.navigationController pushViewController:viewController3 animated:YES];

    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationController.navigationBar.hidden = NO;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.0;
    [label setFont:[UIFont fontWithName :@"Zapfino" size:16]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:self.title];
    [self.navigationItem setTitleView:label];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
