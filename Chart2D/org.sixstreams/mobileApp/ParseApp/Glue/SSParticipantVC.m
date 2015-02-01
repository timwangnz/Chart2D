//
//  SSParticipantVC.m
//  SixStreams
//
//  Created by Anping Wang on 11/24/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSParticipantVC.h"
#import "SSImageView.h"
#import "SSTableViewCell.h"
#import "SSProfileEditorVC.h"
#import "SSProfileVC.h"
#import "SSApp.h"

@interface SSParticipantVC ()

@end

@implementation SSParticipantVC

- (void) onSelect:(id) object
{
    [SSProfileVC getProfile:[object objectForKey:INVITEE_ID]
                onComplete: ^(id data)
     {
         SSEntityEditorVC *profile = [[SSApp instance] entityVCFor:PROFILE_CLASS];
         profile.item2Edit = data;
         profile.readonly = YES;
         [self.eventVC.navigationController pushViewController:profile animated:YES];
     }
     ];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SSTableViewCell *cell = (SSTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SSTableViewCellIdentifier"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SSTableViewCell" owner:self options:nil];
        cell = (SSTableViewCell *)[nib objectAtIndex:0];
       
    }
    id item = [self.objects objectAtIndex:indexPath.row];
    
    id event = item;
   
    id oraganizer =  [event objectForKey:ORGANIZER];
    
    SSImageView *image = [[SSImageView alloc]initWithImage:[UIImage imageNamed:PERSON_DEFAULT_ICON]];
    image.cornerRadius = 2;
    image.defaultImg =  [UIImage imageNamed:PERSON_DEFAULT_ICON];
    
    self.myInvites = [[oraganizer objectForKey:REF_ID_NAME] isEqualToString:[item objectForKey:INVITEE_ID]];
    
    if (self.myInvites)
    {
        image.owner = [oraganizer objectForKey:USERNAME];
        image.isUrl = oraganizer[PICTURE_URL] != nil;
        image.url = image.isUrl ? oraganizer[PICTURE_URL]:oraganizer[REF_ID_NAME];
        event = oraganizer;
    }
    else
    {
        image.isUrl = item[PICTURE_URL] != nil;
        image.url = image.isUrl ? item[PICTURE_URL]:item[INVITEE_ID];
        image.owner = [item objectForKey:INVITEE];
    }
    
    cell.icon.image = image.image;
    
    cell.author.text =   [NSString stringWithFormat:@"%@ %@", [event objectForKey:FIRST_NAME], [event objectForKey:LAST_NAME]];
    
    id lov = [[SSApp instance] getLov:JOB_TITLE ofType:PROFILE_CLASS] ;
    cell.title.text = [lov objectForKey: [event objectForKey:JOB_TITLE]];

    CGRect iconFrame= cell.icon.frame;
    iconFrame.size.width = iconFrame.size.height;
    cell.icon.frame = iconFrame;
    
    iconFrame= cell.author.frame;
    iconFrame.origin.x = cell.icon.frame.origin.x + cell.icon.frame.size.width + 5;
    cell.author.frame = iconFrame;

    iconFrame= cell.title.frame;
    iconFrame.origin.x = cell.icon.frame.origin.x + cell.icon.frame.size.width + 5;
    cell.title.frame = iconFrame;
    
    return cell;
}

@end
