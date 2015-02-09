//
//  SSCompanyVC.m
//  SixStreams
//
//  Created by Anping Wang on 5/24/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSCompanyVC.h"
#import "SSApp.h"
#import "SSImageView.h"

@interface SSCompanyVC ()

@end

@implementation SSCompanyVC


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil?nibNameOrNil :@"SSSearchVC" bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (UIView *) tableView:(UITableView *)tableView cell:(UITableViewCell *) cell row:(NSUInteger) row
{
    id item = [self.objects objectAtIndex:row] ;
    int height = self.defaultHeight == 0 ? tableView.rowHeight : self.defaultHeight;
    int margin = 5;
    
    SSImageView *icon = [[SSImageView alloc]initWithFrame:CGRectMake(margin,margin, height - 2*margin, height - 2*margin)];
    icon.cornerRadius = 5;
    icon.url = [item objectForKey:REF_ID_NAME];
    icon.defaultImg = [UIImage imageNamed:@"company"];

    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,height)];
    [view addSubview:icon];
    UIView *textView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,height)];
    
    [view addSubview:textView];
    [view bringSubviewToFront:textView];
    view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    view.backgroundColor = [UIColor colorWithRed:0.98 green:1.0 blue:1.0 alpha:1.0];
    
    if (self.defaultHeight > 200)
    {
        icon.frame = view.frame;
        textView.frame = CGRectMake(margin, self.defaultHeight - 54, view.frame.size.width - 2*margin, 54);
    }
    else
    {
        textView.frame = CGRectMake(icon.frame.size.width + margin, self.defaultHeight - 54, view.frame.size.width - icon.frame.size.width - 2*margin, 54);
    }
    //text view
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(margin, margin, textView.frame.size.width - 2*margin, 20)];
    
    label.text  = [[SSApp instance] value:item forKey:NAME];
    label.font = [UIFont fontWithName:@"Arial" size:17.0];
    label.textColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.8 alpha:1.0];
    [textView addSubview:label];
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(margin, 25, textView.frame.size.width - 10, 20)];
    
    label.text  = [[SSApp instance]value:item forKey:METRO];
    
    label.font = [UIFont fontWithName:@"Arial" size:12.0];
    label.textColor = [UIColor grayColor];
    [textView addSubview:label];
    label = [[UILabel alloc]initWithFrame:CGRectMake(textView.frame.size.width - 100, 5, 95, 40)];
    label.text  = [NSString stringWithFormat:@"Updated %@ ago by %@", [[item objectForKey:UPDATED_AT] since], [item objectForKey:USER]];
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentRight;
    label.font = [UIFont fontWithName:@"Arial" size:10.0];
    label.textColor = [UIColor grayColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [textView addSubview:label];
    return view;
}


@end
