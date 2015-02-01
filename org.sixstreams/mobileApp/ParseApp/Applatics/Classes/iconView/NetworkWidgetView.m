//
//  NetworkGraphWidgetVC.m
// AppliaticsMobile
//
//  Created by Anping Wang on 4/7/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "NetworkWidgetView.h"
#import "TreeIconsLV.h"
#import "SSConnection.h"
#import "AttributeValue.h"
#import "SSTableViewVC.h"

@interface NetworkWidgetView ()
{
    NSString *objectType;
}

@end

@implementation NetworkWidgetView

- (IBAction) updateRankingFactor:(id) sender
{   
    UIControl *sgCtrl = (UIControl *) sender;
    [self setTab:sgCtrl.tag];
}

- (void) setTab:(NSInteger) tab
{
    [self updateOrgChart:tab];

    switch (tab) {
        case 0:
            sgBkg.image =[UIImage imageNamed:@"BT-orgChart.png"];
            break;
        case 1:
            sgBkg.image =[UIImage imageNamed:@"BT-influences.png"];
            break;
        case 2:
            sgBkg.image =[UIImage imageNamed:@"BT-coWorkers.png"];
            break;
        case 3:
            sgBkg.image =[UIImage imageNamed:@"BT-competitors.png"];
            break;
        default:
            break;
    }
}

- (int) getSentiment:(NSDictionary *) item
{
    NSArray *socialBuzz = [item objectForKey:@"socialBuzz"];
    for (NSString *buzz in socialBuzz)
    {
        NSArray *comps = [buzz componentsSeparatedByString:@":"];
        if ([[comps objectAtIndex:0] isEqualToString:@"Sentiment"]) {
            if ([[comps objectAtIndex:1] isEqualToString:@"High"]) {
                return 10;
            }
            else if ([[comps objectAtIndex:1] isEqualToString:@"Medium"]){
                return 5;
            }
        }
        
    }
    return 0;
}

- (int) getInfluence:(NSDictionary *) item
{
    NSArray *socialBuzz = [item objectForKey:@"socialBuzz"];
    for (NSString *buzz in socialBuzz)
    {
        NSArray *comps = [buzz componentsSeparatedByString:@":"];
        if ([[comps objectAtIndex:0] isEqualToString:@"Influence"]) {
            if ([[comps objectAtIndex:1] isEqualToString:@"High"]) {
                return 10;
            }
            else if ([[comps objectAtIndex:1] isEqualToString:@"Medium"]){
                return 5;
            }
            else if ([[comps objectAtIndex:1] isEqualToString:@"EX"]){
                return -1;
            }
        }
        
    }
    return 0;
}

- (int) getConnections:(NSDictionary *) item
{
    NSArray *connections = [item objectForKey:@"connections"];
    int acme = 0;
    int stanford = 0;
    int oxford = 0;
    for (NSString *buzz in connections)
    {
        NSArray *comps = [buzz componentsSeparatedByString:@":"];
        if ([[comps objectAtIndex:0] isEqualToString:@"Acme"]) {
            acme++;
        }
        else if ([[comps objectAtIndex:0] isEqualToString:@"Stanford"]) {
            stanford++;
        }
        else if ([[comps objectAtIndex:0] isEqualToString:@"Oxford"]) {
            oxford++;
        }
    }
    if (mode < 2) {
        return 0;
    }
    if (mode == 2) 
    {
        return stanford;
        
    }
    if (mode == 3) {
        return acme;
    }
    return 0;
}

- (IBAction) updateOrgChart:(NSInteger) selectedIndex
{   
   
    //242, 101, 34
    UIColor *highColor = [UIColor colorWithRed:242./255 green:101./255 blue:34./255 alpha:1];
    
    //251, 175, 93
    UIColor *mediumColor = [UIColor colorWithRed:251./255 green:175./255 blue:93./255 alpha:1];
    //225, 225, 225
    //255, 226, 195
    UIColor *lowColor = [UIColor colorWithRed:225./255 green:225./255 blue:225./255 alpha:1];
    //255, 226, 195
    UIColor *exColor = [UIColor colorWithRed:127./255 green:127./255 blue:127./255 alpha:1];
    //225, 225, 225
    UIColor *defaultColor = [UIColor colorWithRed:225./255 green:225./255 blue:225./255 alpha:1];
    
    mode = selectedIndex;
    
    [UIView transitionWithView:self duration:0.3
					   options:UIViewAnimationOptionTransitionNone
					animations:^ {
                        
                        for (IconViewVC *icon in [iconView getIconViews]) {
                            AttributeValue * av = icon.userInfo;
                            NSDictionary *item = (NSDictionary *) av.value;
                            int sentiment = [self getSentiment:item];
                            int influnence = [self getInfluence:item];
                            int connections = [self getConnections:item];
                            icon.mode = mode;
                            icon.sentimentLabel = sentiment == 10 ? @"Sentiment: Positive" : (sentiment == 5 ? @"Sentiment: Neutral" : @"Sentiment: Negative");
                            uiCompetitors.hidden = mode !=2;
                            legend.hidden = mode == 0;
                            if(mode == 0)
                            {
                                icon.viewBG = defaultColor;
                            }
                            else 
                            {
                                if (influnence == 10)
                                {
                                    icon.viewBG = highColor;
                                }
                                else if(influnence == 5)
                                {
                                    icon.viewBG = mediumColor;
                                }
                                else if(influnence == -1){
                                    icon.viewBG = exColor;
                                } else
                                {
                                    icon.viewBG = lowColor;
                                }
                            }
                            icon.tag = influnence;
                            icon.badges = connections;
                            [icon updateUI];
                        }
                        
                        
                    }
					completion:nil];
    [iconView doLayout];
}

- (void) updateUI
{
    [self setupGroup];
    iconView = [[TreeIconsLV alloc]initWithFrame:self.frame];
    iconView.iconViewDelegate = self;
    iconView.topMargin = 20;
    [self addSubview:iconView];
    CGRect rect = self.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    iconView.frame = rect;
    [iconView setItems: attributeValues];
    [self doLayout];
    [iconView setNeedsDisplay];
}

- (void) setupGroup
{
    NSMutableArray *attrArray = [[NSMutableArray alloc]init];
    for (NSDictionary *item in self.data)
    {
        AttributeValue *av = [[AttributeValue alloc]init];
        av.name = [item objectForKey:TITLE];
        av.subtitle = [item objectForKey:SUBTITLE];
        
        av.value = item;
        av.sequence = [[item objectForKey:SEQUENCE] intValue];
        av.iconImg = [item objectForKey:@"iconImg"];
        [attrArray addObject:av];
    };
    
    NSMutableArray * _attributeValues = [[NSMutableArray alloc]init];
   
    
    for(AttributeValue *av in attrArray)
    {
        [_attributeValues addObject:av];
        NSDictionary *item = (NSDictionary *) av.value;
        
        NSArray *directs = [item objectForKey:@"connections"];
        for(NSString * direct in directs)
        {
            for (AttributeValue *childAv in attrArray) 
            {
                NSDictionary *childItem = (NSDictionary *) childAv.value;
                NSString *childId = [childItem objectForKey:REF_ID_NAME];
                if ([childId isEqualToString:direct])
                {
                    [av addChildValue:childAv];
                    childAv.parent = av;
                   
                    av.iconSize = CGSizeMake(240,100);
                    childAv.iconSize = CGSizeMake(240,100);
                }
            }
        }
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:SEQUENCE ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    attributeValues = [_attributeValues sortedArrayUsingDescriptors:sortDescriptors];
}

- (void) doLayout
{
    [iconView doLayout];
    CGRect rect = iconView.frame;
    self.contentSize = CGSizeMake(rect.size.width, rect.size.height);
}

- (void) onSelect:(id) sender object:(id)item
{
     /*
    AttributeValue *av = (AttributeValue *) item;
   
    if(self.widgetDelegate)
    {
        [self.widgetDelegate onSelect: (NSDictionary *) av.value mode:mode];
    }
     */
}

@end
