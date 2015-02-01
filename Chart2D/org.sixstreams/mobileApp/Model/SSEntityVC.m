//
//  Created by Anping Wang on 1/29/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSEntityVC.h"
#import "ObjectTypeUtil.h"
#import "SSConversationVC.h"
#import "SSSecurityVC.h"

@interface SSEntityVC ()<SSScrollViewDelegate>
{
    id likeEntity;
}

- (IBAction) getPicture: (id) sender;
- (IBAction)makeCall;
- (IBAction)like : (id)sender;
- (IBAction)follow : (id)sender;
- (IBAction)showComments:(id)sender;
- (IBAction)share : (id)sender;

@end

@implementation SSEntityVC

- (void) email:(id) entity
{
    
}

- (void) fbShare:(id) entity
{
    
}

- (void) tweetShare:(id) entity
{
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
        case 0:
            [self email:self.entity];
            break;
        case 1:
            [self fbShare:self.entity];
            break;
        case 2:
            [self tweetShare:self.entity];
            break;
        default:
            break;
    }
}

- (IBAction)share : (id)sender
{
    [[[UIActionSheet alloc]initWithTitle: @"Share"
                                delegate: self
                       cancelButtonTitle: @"Cancel"
                  destructiveButtonTitle: nil
                       otherButtonTitles: @"Email", @"Facebook", @"Twitter", nil] showInView:self.view];
    
}
- (IBAction)showComments:(id)sender
{
    SSCommentVC *commentVC = [[SSCommentVC alloc]init];
    commentVC.entity = self.entity;
    commentVC.entityType = self.entityType;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:commentVC animated:YES];
    
}

- (IBAction)uploadPicture:(id)sender
{
    
    SSPictureVC *pictureVC = [[SSPictureVC alloc]init];
    pictureVC.parentId = [self.entity objectForKey:@"id"];
    pictureVC.parentType = self.entityType;
    
    pictureVC.title = self.title;
    [pictureVC setCurrentIndex:((UIView *) sender).tag];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:pictureVC animated:YES];
}

- (IBAction) getPicture: (id) sender
{
    changeIcon = YES;
    [self _getPicture:sender];
}

- (void) _getPicture: (id) sender
{
    [self loadImage:sender];
}

- (void) processImage: (id) image
{
    CGSize size = CGSizeMake(320, 320);
    NSData *imageData = UIImageJPEGRepresentation([SSImageEditorVC imageWithImage:image scaledToSize:size], 0.8);
    size = CGSizeMake(74, 74);
    avatar.image = [SSImageEditorVC imageWithImage:image scaledToSize:size];
    NSData *iconData = UIImageJPEGRepresentation(avatar.image, 0.8);
    
    NSMutableDictionary *resource = [NSMutableDictionary dictionary];
    
    [resource setValue:@"No Caption" forKey:@"name"];
    [resource setValue:@"image/jpeg" forKey:@"contentType"];
    [resource setValue:[SSSecurityVC username] forKey:@"owner"];
    
    if (changeIcon)
    {
        [resource setValue:[self.entity  objectForKey:@"id"]forKey:@"id"];
    }
    [resource setValue: self.entityType forKey:@"parentType"];
    [resource setValue:[self.entity  objectForKey:@"id"]forKey:@"parentId"];
    
    [resource setValue:[NSNumber numberWithInt:[imageData length]] forKey:@"contentLength"];
    [self blockView];
    [self upload:imageData icon:iconData withMetadata:resource];
}

- (void) uploaded :(SSCallbackEvent *)event
{
    [self unblockView];
    
    if (changeIcon)
    {
        [self.entity setValue:[event.data objectForKey:@"iconUrl"] forKey:@"imageUrl"];
        [self update:self.entity ofType:self.entityType];
    }
    [self updateImageRoll];
}

- (void) updated: (SSCallbackEvent *)event
{
    [self.entity setValue:[NSNumber numberWithInt:likes] forKey:@"liked"];
}

- (void) updateUI
{
    [self checkLikedBy];
    likes = [[self.entity objectForKey:@"liked"] intValue];
    [lLikes setText:[NSString stringWithFormat:@"%d likes   %d comments", likes, self.total]];
}

- (void) created:(id)object
{
    [self updateUI];
}

- (void) checkLikedBy
{
    if (![SSSecurityVC isSignedIn])
    {
        likeEntity = nil;
        [liked setTitle: @"Like" forState:UIControlStateNormal];
        liked.enabled = YES;
        return;
    }
    
    if (likeEntity)
    {
        //unlike it here
        return;
    }
    SSQuery *query = [[SSQuery alloc]init];
    
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    [filters setValue:[self.entity objectForKey:@"id"] forKey:@"aboutId"];
    [filters setValue:self.entityType forKey:@"aboutType"];
    
    [filters setValue:[[SSSecurityVC profile] objectForKey:@"id"] forKey:@"authorId"];
    
    [[[[query setLimit:1] setOffset:0] setQuery:WILD_SEARCH_CHAR]  addFilters:filters];
    SSClient *client = [SSClient getClient];
    [client setCachePolicy:nil];
    liked.enabled = NO;
    likeEntity = nil;
    
    [client query: query
           ofType: @"org.sixstreams.social.Like"
       onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error) {
             [liked setTitle: @"Like" forState:UIControlStateNormal];
             liked.enabled = YES;
         }
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             NSArray *myLikes = [event.data objectForKey:@"items"];
             if ([myLikes count] > 0)
             {
                 likeEntity = [myLikes objectAtIndex:0];
             }
             [liked setTitle:[myLikes count] > 0 ? @"Unlike" : @"Like" forState:UIControlStateNormal];
             liked.enabled = YES;
         }
     }
     ];
}


- (void) follow:(id)sender
{
    NSString *objectType = @"org.sixstreams.social.SocialFollow";
    NSMutableDictionary *follow = [NSMutableDictionary dictionary];
    
    id profile = [SSSecurityVC profile];
    
    [follow setValue:self.entityType forKey:@"aboutType"];
    [follow setValue:[self.entity objectForKey:@"id"] forKey:@"aboutId"];
    
    [follow setValue:[profile objectForKey:@"id"] forKey:@"authorId"];
    
    NSMutableDictionary *followDetails = [NSMutableDictionary dictionary];
    
    [followDetails setValue:[profile objectForKey:@"jobTitle"] forKey:@"followerTitle"];
    [followDetails setValue:[self getUserDisplayName:profile] forKey:@"authorName"];
    
    id displayValues = [ObjectTypeUtil displayValuesFor:self.entity ofType:self.entityType];
    
    
    [followDetails setValue:[displayValues objectForKey:@"title"] forKey:@"followedByTitle"];
    [followDetails setValue:[displayValues objectForKey:@"subtitle"] forKey:@"aboutName"];
    [followDetails setValue:[displayValues objectForKey:@"imageUrl"] forKey:@"aboutUrl"];
    
    
    [follow setValue:[followDetails JSONString] forKey:@"rawjson"];
    
    [[SSClient getClient] createObject:follow ofType:objectType onCallback:^(SSCallbackEvent *event) {
        if (event.error)
        {
            DebugLog(@"%@", event.error);
            NSString *msg = [event.error.userInfo objectForKey:@"message"];
            [self showAlert:@"Error" message:msg ? msg : @"Failed to follow, please try later!"];
        }
        else{
            [[SSClient getClient]invalidateCache:nil ofType:PROFILE_TYPE];
        }
    }];
}

- (IBAction)like : (id)sender
{
    if (likeEntity)
    {
        liked.enabled = NO;
        [[SSClient getClient] deleteObject:[likeEntity objectForKey:@"id"] ofType:@"org.sixstreams.social.Like"
                                onCallback:^(SSCallbackEvent *event) {
                                    if (event.error)
                                    {
                                        [self handleError:event];
                                    }
                                    else if(event.callingStatus == SSEVENT_SUCCESS)
                                    {
                                        [self.entity setValue:[NSNumber numberWithInt:likes - 1] forKey:@"liked"];
                                        liked.enabled = YES;
                                        [liked setTitle: @"Like" forState:UIControlStateNormal];
                                        likeEntity = nil;
                                        [self updateUI];
                                    }
                                }
         ];
        
    }
    else
    {
        NSMutableDictionary *like = [NSMutableDictionary dictionary];
        [like setValue: [self.entity objectForKey:@"id"] forKey:@"aboutId"];
        [like setValue: self.entityType forKey:@"aboutType"];
        id displayValues = [ObjectTypeUtil displayValuesFor:self.entity ofType:self.entityType];
        [like setValue: [displayValues objectForKey:@"title"] forKey:@"aboutName"];
        [like setValue: [self.entity objectForKey:@"imageUrl"] forKey:@"aboutUrl"];
        
        UIButton *likeBtn = (UIButton *) sender;
        
        likeBtn.enabled = NO;
        
        [[SSClient getClient] createObject:like
                                    ofType:@"org.sixstreams.social.Like"
                                onCallback: ^(SSCallbackEvent *event)
         {
             if (event.error)
             {
                 [self handleError:event];
             }
             else if(event.callingStatus == SSEVENT_SUCCESS)
             {
                 [self.entity setValue:[NSNumber numberWithInt:likes + 1] forKey:@"liked"];
                 [liked setTitle: @"Unlike" forState:UIControlStateNormal];
                 [self updateUI];
                 
             }
             
             likeBtn.enabled = YES;
             
         }];
    }
    
}

- (void) scrollView:(SSScrollView *)ssClient didSelectView:(id)view
{
    int tag = ((SSImageView*)view).tag;
    
    if (tag == [ssClient numberOfChildViews] - 1)
    {
        changeIcon = NO;
        [self _getPicture:self];
    }
    else
    {
        [self uploadPicture:view];
    }
}


- (IBAction)makeCall
{
    if ([phone.text length] != 0)
    {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Call "
                                                       message:phone.text
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
            NSString *phoneNumber  = [phone.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            [[UIApplication sharedApplication] openURL:
             [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]];
        }
    }
}

- (void) gotoWebsite:(NSString *) url
{
    if ([website.text length] != 0)
    {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", website.text]]];
    }
}

- (void)viewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:0.25
                     animations:^(void){
                         gestureRecognizer.view.alpha = 0.25f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.25 animations:^(void){
                             gestureRecognizer.view.alpha = 1.0f;
                         }
                                          completion:^(BOOL finished) {
                                              if ([gestureRecognizer.view isEqual:phone])
                                              {
                                                  [self makeCall];
                                              }
                                              if ([gestureRecognizer.view isEqual:website])
                                              {
                                                  [self gotoWebsite:website.text];
                                              }
                                          }
                          ];
                     }];
}

-(void) updateImageRoll
{
    iconRoll.objectType = @"org.sixstreams.social.Resource";
    iconRoll.queryString = [NSString stringWithFormat:@"parentId:%@", [self.entity objectForKey:@"id"]];
    iconRoll.orderBy= @"dateCreated,desc";
    [iconRoll clearAll];
    iconRoll.mode = 1;
    iconRoll.scrollViewDelegate = self;
    [iconRoll refreshViewOnSuccess:^(id sender, NSArray *objects)
     {
         int i = 0;
         for (id item in objects)
         {
             SSImageView *itemImage = [[SSImageView alloc]initWithFrame:CGRectMake(0,0, 72, 72)];
             itemImage.image = [UIImage imageNamed:@"people.png"];
             itemImage.url = [item objectForKey:@"iconUrl"];
             [iconRoll addChildView:itemImage];
             itemImage.tag = i++;
         }
         SSImageView *imageView = [[SSImageView alloc]initWithFrame:CGRectMake(0,0, 72, 72)];
         imageView.contentMode = UIViewContentModeScaleAspectFit;
         imageView.image =[UIImage imageNamed:@"photo.png"];
         imageView.tag = i++;
         [iconRoll addChildView:imageView];
     }
     ];
}

- (void) editObject
{
    [ObjectTypeUtil editObject:self.entity sender : self ofType:self.entityType];
}

- (void) setupUI;
{
    if (!self.entity || !self.entityType)
    {
        NSException *e = [NSException
                          exceptionWithName:@"No required arguments"
                          reason:@"Resource and its type must be given in order to add a comment"
                          userInfo:nil];
        
        @throw e;
    }
    /*
     if (self.editable)
     {
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
     target:self
     action:@selector(editObject)];
     }
     */
    [self addTapToView:phone onTap:@selector(viewTapped:)];
    [self addTapToView:website onTap:@selector(viewTapped:)];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self updateUI];
    
    if (iconRoll)
    {
        [self updateImageRoll];
    }
    
    self.objectType = @"org.sixstreams.social.Rating";
    self.queryString = [NSString stringWithFormat:@"aboutId:%@", [self.entity objectForKey:@"id"]];
    [self getObjects];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self
                       action:@selector(forceReload:)
             forControlEvents:UIControlEventValueChanged];
    
    [sectionTableView addSubview:refreshControl];
    
    //self.editable = [SSSecurityVC isItemEditable:self.entity];
    
    [self setUpData];
    [self setupUI];
}

- (void) forceReload:(UIRefreshControl *) refreshControl
{
    [self invalidateCache];
    [refreshControl endRefreshing];
}

#pragma sectioned table

- (UITableViewCell *) cellForSection:(NSString *) section for:(UITableView *) tableView atRow:(int) row
{
    return nil;
}

- (BOOL) configCell:(SSSearchCell *)searchCell forItem:(id)item
{
    searchCell.details.text = [item objectForKey:@"comment"];
    searchCell.title.text = [item objectForKey:@"authorName"];
    searchCell.details.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    searchCell.backgroundColor = [UIColor clearColor];
    searchCell.details.font = [UIFont systemFontOfSize:14];
    searchCell.icon.defaultImg = [UIImage imageNamed:@"people.png"];
    searchCell.icon.url = [NSString stringWithFormat:@"org.sixstreams.social.Resource/%@/icon", [item objectForKey:@"createdBy"]];
    return YES;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *section = [sortedKeys objectAtIndex:indexPath.section];
    BOOL isComments = [section isEqualToString:SECTION_COMMENTS];
    
    if (isComments)
    {
        SSConversationVC *conversationVC = [[SSConversationVC alloc]init];
        
        conversationVC.entity = [self.dataObjects objectAtIndex:indexPath.row];
        
        [tableView selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.navigationController pushViewController:conversationVC animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *section = [sortedKeys objectAtIndex:indexPath.section];
    BOOL isComments = [section isEqualToString:SECTION_COMMENTS];
    
    UITableViewCell *cell;
    if (isComments)
    {
        static NSString *searchCellIdentifier = @"SSSearchCellId";
        cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SSSearchCell" owner:self options:nil];
            cell = (SSSearchCell *)[nib objectAtIndex:0];
        }
        [self configCell:( (SSSearchCell *)cell) forItem: [self.dataObjects objectAtIndex:indexPath.row]];
    }
    else
    {
        cell = [self cellForSection:section for:tableView atRow:indexPath.row];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.clipsToBounds = YES;
            id item = [tableData objectForKey:section];
            [cell addSubview:item];
        }
    }
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    return cell;
}


- (void) setUpData
{
    tableData = [NSMutableDictionary dictionary];
    if (viewGeneral)
    {
        [tableData setValue:viewGeneral forKey:SECTION_GENERAL];
    }
    if (viewPictures)
    {
        [tableData setValue:viewPictures forKey:SECTION_PICTURES];
    }
    if (viewActions)
    {
        [tableData setValue:viewActions forKey:SECTION_ACTIONS];
    }
    if (viewComments)
    {
        [tableData setValue:viewComments forKey:SECTION_COMMENTS];
    }
    
    sortedKeys = [[tableData allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
}

- (NSString *) getHeaderText:(NSString *) sectionTitle
{
    
    if ([sectionTitle isEqualToString:SECTION_COMMENTS])
    {
        return @"  Comments";
    }
    return sectionTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return viewHeader.frame.size.height;
    }
    
    return [self heightForSection:[sortedKeys objectAtIndex:section]];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [self heightForRowInSection:[sortedKeys objectAtIndex:indexPath.section]];
}


- (CGFloat)heightForRowInSection : (NSString *) section;
{
    if ([section isEqualToString:SECTION_COMMENTS])
    {
        return 54;
    }
    
    UIView * item = [tableData objectForKey:section];
    
    return item.frame.size.height;
}

- (CGFloat)heightForSection : (NSString *) section
{
    if ([section isEqualToString:SECTION_COMMENTS])
    {
        return 30;
    }
    return 0;
}

- (NSInteger)rowsForSection : (NSString *) section
{
    BOOL isComments = [section isEqualToString:SECTION_COMMENTS];
    if (isComments)
    {
        return [self.dataObjects count];
    }
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionKey = [sortedKeys objectAtIndex:section];
    return [self rowsForSection:sectionKey];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return viewHeader;
    }
    
    UILabel* customView = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-40, 1)];
    customView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-40, 30)];
    customView.text = [self getHeaderText:[sortedKeys objectAtIndex:section]];
    customView.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    customView.font = [UIFont systemFontOfSize:16];
    customView.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    return customView;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
    return [sortedKeys count];
}

@end
