//
//  SSApp.m
//  Medistory
//
//  Created by Anping Wang on 11/12/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSApp.h"
#import "SSJSONUtil.h"
#import "SSCommonVC.h"
#import "SSProfileEditorVC.h"
#import "SSWelcomeVC.h"
#import "SSCompanyEditorVC.h"
#import "SSCommonSetupVC.h"
#import "SSLayoutVC.h"
#import "SSSpotlightView.h"
#import "SSValueLabel.h"
#import "SSGroupEditorVC.h"
#import "SSExpressionParser.h"

@interface SSApp ()
{
    NSDictionary *definition;
    
}
@end

@implementation SSApp

static SSApp *singleton;

+ (SSApp *) instance
{
    if (singleton)
    {
        return singleton;
    }

    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSDictionary* appInfo = [infoDict objectForKey:@"org.sixstreams.app"];
    NSString *className = [appInfo objectForKey:@"className"];
    NSString *name = [appInfo objectForKey:@"name"];
    NSString *welcomeMessage = [appInfo objectForKey:@"welcomeMessage"];
    NSString *email = [appInfo objectForKey:@"email"];
    NSString *displayName = [appInfo objectForKey:@"displayName"];
    singleton =  [self getInstance:className];
    singleton.name = name;
    singleton.displayName = displayName ? displayName : name;
    singleton.welcomeMessage = welcomeMessage ? welcomeMessage : [NSString stringWithFormat: @"Welcome to %@", name];
    singleton.email = email ? email : @"info@sixstreams.com";
    singleton.loginAgent = [appInfo objectForKey:@"loginAgent"];
    return singleton;
}

+ (SSApp *) getInstance:(NSString *)appClassName
{
    static NSMutableDictionary *apps;
    if(!apps)
    {
        apps = [NSMutableDictionary dictionary];
    }
    SSApp * app = [apps objectForKey:appClassName];
    if (!app)
    {
        Class myClass = NSClassFromString(appClassName);
        app = [myClass new];
        [apps setObject:app forKey:appClassName];
    }
    app.className = appClassName;
    return app;
}

CGAffineTransform makeTransform(CGFloat xScale, CGFloat yScale,
                                CGFloat theta, CGFloat tx, CGFloat ty)
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform.a = xScale * cos(theta);
    transform.b = yScale * sin(theta);
    transform.c = xScale * -sin(theta);
    transform.d = yScale * cos(theta);
    transform.tx = tx;
    transform.ty = ty;
    
    
    return transform;
}

- (UIView *) spotlightView: (id) entity ofType:(NSString *) entityType
{
    SSImageView *eventIcon =[[SSImageView alloc]init];
    eventIcon.defaultImg = [[SSApp instance] defaultImage:entity ofType:entityType];
    
    eventIcon.image = eventIcon.defaultImg;
    eventIcon.url = entity[REF_ID_NAME];
    eventIcon.backupUrl = entity[ORGANIZER][REF_ID_NAME];
    
    eventIcon.contentMode = UIViewContentModeScaleAspectFill;
    eventIcon.cornerRadius = 0;
    return eventIcon;
}

- (NSString *) deviceId
{
    NSUUID *uuid =[[UIDevice currentDevice] identifierForVendor] ;
    return uuid.UUIDString;
}

- (void) initializeOnSuccess:(SuccessCallback) callback
{
    callback(self);
}

- (NSString *) getAppIconName
{
    return @"application";
}

- (NSString *) evaluate : (NSString *) expression on:(id) item
{
    NSArray *attrs = [expression componentsSeparatedByString:@" "];
    NSMutableString *str = [[NSMutableString alloc] init];
    BOOL hasValue = NO;
    for (NSString *attrName in attrs){
        id value = [self valueAtPath:attrName of:item];
        if (value)
        {
            hasValue = YES;
            if ([attrName isEqual:[attrs lastObject]])
            {
                [str appendFormat:@"%@",[self valueAtPath:attrName of:item]];
            }
            else
            {
                [str appendFormat:@"%@ ",[self valueAtPath:attrName of:item]];
            }
        }
    }
    return hasValue ? str : nil;
}

- (id) valueAtPath:(NSString *) path of:(id) parent
{
    NSMutableArray *attrs = [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"."]];
    if ([attrs count] == 1)
    {
        return [[SSApp instance] value:parent forKey:path defaultValue:nil];
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

- (id) init
{
    self = [super init];
    lovs = [NSMutableDictionary dictionary];
    return self;
}

- (void) addView:(id) item inView:(UIView *) view withAttr:(NSString *) attrName at: (NSInteger) order
{
    static int font_size = 18;
    SSValueLabel *label = (SSValueLabel*) [view viewWithTag:order];
    if (!label)
    {
        
        label = [[SSValueLabel alloc]initWithFrame:CGRectMake(4, (order - 1) * font_size + 5, view.frame.size.width - 5, font_size)];
        if (order == 1)
        {
            label.font = [UIFont boldSystemFontOfSize:font_size - 2];
            label.textColor = [UIColor redColor];
        }
        else
        {
            label.font = [UIFont systemFontOfSize:font_size-4];
            label.textColor = [UIColor darkGrayColor];
        }
        
        label.attrName = attrName;
        label.tag = order;
        [view addSubview:label];
    }
    label.text = [self value:item forKey:attrName];
}

- (NSString*) highlightTitle: (id) item forCategory: (NSInteger) currentPage
{
    return nil;
}

- (NSString*) highlightSubtitle: (id) item forCategory: (NSInteger) currentPage
{
    return nil;
}

- (UIImage *) defaultImage:(id) item ofType:(NSString *) type
{
    
    if([type isEqualToString:USER_TYPE])
    {
        NSString *type = [item objectForKey:USER_TYPE];
        if ([type isEqualToString:@"1"])
        {
            return [UIImage imageNamed:@"triangle"];
        }
        else
        {
            return [UIImage imageNamed:@"circle"];
        }
    }
    if ([type isEqualToString:COMPANY_CLASS])
    {
        return [UIImage imageNamed:@"company-icon"];
    }
    if ([type isEqualToString:PROFILE_CLASS])
    {
        return [UIImage imageNamed:@"people"];
    }
    return nil;
}


- (void) updateHighlightItem:(id) item ofType:(NSString *) itemType inView:(UIView *) view
{
    if ([itemType isEqualToString:COMPANY_CLASS])
    {
        [self addView:item inView:view withAttr:NAME at:1];
        [self addView:item inView:view withAttr:INDUSTRY at:2];
        [self addView:item inView:view withAttr:PHONE at:3];
        [self addView:item inView:view withAttr:WEB_SITE at:4];
        [self addView:item inView:view withAttr:METRO at:5];
        SSImageView *recruitor = [[SSImageView alloc]initWithFrame:CGRectMake(view.frame.size.width - 30, 86, 24, 24)];
        recruitor.cornerRadius = 12;
        recruitor.image = [UIImage imageNamed:@"people.png"];
        recruitor.defaultImg = recruitor.image;
        recruitor.url = [[item objectForKey:USER_INFO] objectForKey:REF_ID_NAME];
        [view addSubview:recruitor];
    }
    if ([itemType isEqualToString:PROFILE_CLASS])
    {
        [self addView:item inView:view withAttr:FIRST_NAME at:1];
        [self addView:item inView:view withAttr:JOB_TITLE at:2];
        [self addView:item inView:view withAttr:COMPANY at:3];
        [self addView:item inView:view withAttr:EMAIL at:4];
        [self addView:item inView:view withAttr:METRO at:5];
        SSImageView *recruitor = [[SSImageView alloc]initWithFrame:CGRectMake(view.frame.size.width - 30, 86, 24, 24)];
        recruitor.cornerRadius = 12;
        recruitor.image = [UIImage imageNamed:@"people.png"];
        recruitor.defaultImg = recruitor.image;
        recruitor.url = [[item objectForKey:USER_INFO] objectForKey:REF_ID_NAME];
        [view addSubview:recruitor];
    }
}

- (UIViewController *) entityVCFor :(NSString *) type
{
    if ([type isEqualToString:SETTINGS]) {
        SSCommonSetupVC *settingsTab = [[SSCommonSetupVC alloc]init];
        settingsTab.tabBarItem.image = [UIImage imageNamed:@"gear_inx2"];
        settingsTab.editable = YES;
        return settingsTab;
    }
    
    if ([type isEqualToString:@"org_sixstreams_user_Profile"] || [type isEqualToString:PROFILE_CLASS]) {
        return [[SSProfileEditorVC alloc]init];
    }
    
    if ([type isEqualToString:@"org_sixstreams_Company"] || [type isEqualToString:COMPANY_CLASS]) {
        return [[SSCompanyEditorVC alloc]init];
    }
    
    if ([type isEqualToString:GROUP_CLASS]) {
        return [[SSGroupEditorVC alloc]init];
    }
         return nil;
}

- (NSString *) editorClassFor:(NSString *) objectType
{
    if ([objectType isEqualToString:@"org_sixstreams_user_Profile"] || [objectType isEqualToString:PROFILE_CLASS]) {
        return @"SSProfileEditorVC";
    }
    
    if ([objectType isEqualToString:@"org_sixstreams_Company"] || [objectType isEqualToString:COMPANY_CLASS]) {
        return @"SSCompanyEditorVC";
    }
    return nil;
}

- (id) contextForActiviy:(id)activity onSubject:(NSString *)subject
{
    return [activity objectForKey:CONTEXT];
}

- (UIViewController *) createWelcomeVC
{
    return [[SSWelcomeVC alloc]init];
}

- (UIImage *) imageForJobTitle:(id) type
{
    return nil;
}

- (id) contextualObject:(id) item ofType:(NSString *) type
{
    if ([type isEqualToString:PROFILE_CLASS])
    {
        return  @{
                  NAME: [NSString stringWithFormat:@"%@ %@",[item objectForKey:FIRST_NAME], [item objectForKey:LAST_NAME]],
                  SUBTITLE: [self value:item forKey:JOB_TITLE],
                  REF_ID_NAME: [item objectForKey:REF_ID_NAME]
                  };
        
    }
    if ([type isEqualToString:COMPANY_CLASS])
    {
        return  @{
                  NAME: [item objectForKey:NAME],
                  SUBTITLE: [self value:item forKey:METRO],
                  REF_ID_NAME: [item objectForKey:REF_ID_NAME]
                  };
    }
    return [NSNull null];
}

- (SSLayoutVC *) getLayoutVC
{
    return [[SSLayoutVC alloc] init];
}

- (NSDictionary *) lookupsFor:(NSString *)type
{
    return [lovs objectForKey:type];
}

- (id) value:(id) item forKey:(NSString *) attrName defaultValue:(id) defaultValue
{
    if (!attrName)
    {
        return nil;
    }
    if ([item isKindOfClass:[NSString class]])
    {
        NSString * value = [[lovs objectForKey:attrName] objectForKey:item];
        return value ? value : item;
    }
    else
    {
        //
        //if attribute end with something that is not alphabetical, we will keep those
        //organizer.firstName organizer.lastName, address.city
        //
        NSString * value = [[item objectForKey:DISPLAY_VALUES] objectForKey:attrName];
        if (value)
        {
            return value;
        }
        
        value = [[lovs objectForKey:attrName] objectForKey:[item objectForKey:attrName]];
        value = value ? value : [item objectForKey:attrName];
        
        return value ? value : defaultValue;
    }
}

- (id) value:(id) item forKey:(NSString *) attrName
{
    return [self value:item forKey:attrName defaultValue:attrName];
}


- (BOOL) showPastEvents
{
    return NO;
}

- (BOOL) enableSocialProfile
{
    return NO;
}

- (BOOL) enableResume
{
    return NO;
}

- (BOOL) invitationOnly
{
    return NO;
}

- (BOOL) isIPad
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

- (UIView *) backgroundView
{
    UIView *background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default.png"]];
    return background;
}

- (NSString *) appId
{
    return @"PSMk7ulKz7MMyFoDqQfR8DLQLc10CSnequbpPolk";
}

- (NSString *) appKey
{
    return @"YA35JDlm7cYz5m7aGUe4lA3Au49uSx1rxyh3768H";
}

- (NSString *) dateTimeFormat
{
    return @"EEE MM/dd hh:mm a";
}

- (NSString *) dateFormat
{
    return @"EEE MM/dd";
}

- (NSString *) timeFormat
{
    return @"hh:mm a";
}

- (NSString *) displayName:(NSString *) attrName ofType:(NSString *) objectType
{
    return [attrName fromCamelCase];
}

- (NSString *) displayNameOfType:(NSString *)objectType
{
    return objectType;
}

- (NSString *) format:(id)attrValue forAttr:(NSString *)attrName ofType:(NSString *)objectType
{
    if (!attrValue)
    {
        return @"";
    }
    
    if ([attrValue isKindOfClass:NSDate.class])
    {
        return [((NSDate *)attrValue) toDateString];
    }
    else
    {
        return [NSString stringWithFormat:@"%@", attrValue];
    }
}

- (NSString *) displayValue:(NSString *)attrValue forAttr:(NSString *)attrName ofType:(NSString *)objectType
{
    NSDictionary *lov = [self getLov:attrName ofType:objectType];
    id value = [lov objectForKey:attrValue];
    value = [self displayName:value ofType:objectType];
    if (value)
    {
        return value;
    }
    else
    {
        return attrValue;
    }
}


- (NSDictionary *) getLov:(NSString *)attrName ofType:(NSString *)objectType
{
    NSDictionary *lov = [lovs objectForKey:attrName];
    if (lov)
    {
        return lov;
    }
    return [NSDictionary dictionary];
}

- (UIViewController *) createVCForActivity:(id) activity
{
    return nil;
}

- (UIViewController *) createRootVC
{
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [self customizeAppearance];
    return tabBarController;
}

- (void) readFile:(id) info url:(NSURL *) url
{
    
}

//
- (void) customizeProfileEditor:(id) profileEditor
{
    
}

- (void) customizeAppearance
{
   
}


@end
