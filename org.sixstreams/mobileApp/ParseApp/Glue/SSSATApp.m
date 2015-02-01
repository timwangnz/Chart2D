//
//  SSSATApp.m
//  SixStreams
//
//  Created by Anping Wang on 2/1/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import "SSSATApp.h"
#import "SSSearchVC.h"

@implementation SSSATApp

- (UIViewController *) entityVCFor :(NSString *) type
{
    if ([type isEqualToString:@"org_sixstreams_sat_Word"] || [type isEqualToString:WORD_CLASS]) {
        return [[SSSATWordVC alloc]init];
    }
    return [super entityVCFor:type];
}

-(UIViewController *) createRootVC
{
   
   
     SSSearchVC *wordsVC = [[SSSearchVC alloc]init];
     wordsVC.objectType = WORD_CLASS;
     wordsVC.titleKey = WORD;
     wordsVC.subtitleKey = MEANING;
     wordsVC.iconKey = REF_ID_NAME;
     wordsVC.defaultIconImgName = @"word";
     wordsVC.orderBy = WORD;
     wordsVC.queryPrefixKey = SEARCHABLE_WORDS;
     wordsVC.addable = YES;
     wordsVC.title = @"SAT Words";
     wordsVC.defaultHeight = 64;
     wordsVC.orderBy = UPDATED_AT;
     wordsVC.ascending = NO;
     wordsVC.tabBarItem.image = [UIImage imageNamed:@"pageMenuNav_PeopleIcon"];
     wordsVC.filterable = YES;
     //[SSSATWordVC loadCSV];
    
    
    SSDataVC *dataVC = [[SSDataVC alloc]init];
    dataVC.title = @"Data";
    return dataVC;
}

- (UIView *) spotlightView: (id) entity ofType:(NSString *) entityType
{
    UIView *eventIcon =[[SSImageView alloc]init];
    eventIcon.contentMode = UIViewContentModeScaleAspectFill;
    SSWordView *customView = [[[NSBundle mainBundle] loadNibNamed:@"SSWordView" owner:nil options:nil] lastObject];
    [customView setValue:entity];
    [eventIcon addSubview:customView];
    return eventIcon;
}

@end
