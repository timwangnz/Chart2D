//
//  SSMessagingVC.m
//  Medistory
//
//  Created by Anping Wang on 11/9/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSMessagingVC.h"
#import "SSFilter.h"
#import <Parse/Parse.h>
#import "SSConnection.h"
#import "SSSecurityVC.h"
#import "SSStorageManager.h"
#import "SSRoundLabel.h"
#import "SSMessageView.h"
#import "SSProfileVC.h"
#import "SSConversation.h"
#import "ProgressView.h"
#import "MessageView.h"
#import "ImageView.h"

@interface SSMessagingVC ()
{
    IBOutlet UITextField *tfMsg;
    IBOutlet UIView *editView;
    IBOutlet UIView *msgView;
    IBOutlet UIScrollView *messagesView;
    NSMutableArray *childViews;
}

- (IBAction) sendMessage:(id)sender;

@end

@implementation SSMessagingVC

- (NSString *) toId
{
    return [self.messageWith objectForKey:REF_ID_NAME];
}

- (IBAction) sendMessage:(id)sender
{
    if (!tfMsg.text)
    {
        return;
    }
    
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    
    [msg setObject:[SSProfileVC profileId] forKey:MESSAGE_FROM];
    [msg setObject:[self toId] forKey:MESSAGE_TO];
    [msg setObject:self.chatId forKey:CHAT_ID];
    [msg setObject:tfMsg.text forKey:MESSAGE];
    
    [[SSConnection connector] createObject: msg
                                    ofType: MESSAGING_CLASS
                                 onSuccess: ^(NSDictionary *newObject){
                                     tfMsg.text = @"";
                                     [self.objects addObject:newObject];
                                     [self cacheObject:self.objects forKey:[SSProfileVC profileId]];
                                     [self refreshUI];
                                 }
                                 onFailure: ^(NSError *error){
                                     [self showAlert:@"Failed to post, please try again" withTitle:@"Server error"];
                                 }
     ];
}

- (void) refreshUI
{
    for (UIView * subView in childViews) {
        [subView removeFromSuperview];
    }
    
    childViews = [NSMutableArray array];
    for (id message in self.objects)
    {
        [childViews addObject:[[SSMessageView alloc]initWithMessaage:message withFrame:CGRectMake(0, 0, self.view.frame.size.width, 52)]];
    }
    
    float totalHeight = 0;
    
    for (UIView * subView in childViews) {
        CGRect rect = subView.frame;        
        rect.origin.y = totalHeight;
        subView.frame = rect;
        [messagesView addSubview:subView];
        totalHeight += rect.size.height + 5;
    }
    [messagesView setContentInset: UIEdgeInsetsMake(0, 0, totalHeight + 10, self.view.frame.size.width)];
}

- (void) forceRefresh
{
    id cached = [self cachedObjectForKey:self.chatId];
    [self.predicates removeAllObjects];
    [self.predicates addObject:[SSFilter on: CHAT_ID op: EQ value: self.chatId]];
    if (cached)
    {
        NSDate *dateCached = [cached objectForKey:CACHED_AT];
        [self.predicates addObject:[SSFilter on:CREATED_AT op:GREATER value:dateCached]];
        self.objects = [NSMutableArray arrayWithArray:[cached objectForKey:CACHED_DATA]];
        [self refreshUI];
    }
    [super forceRefresh];
}

- (void) onDataReceived:(id) objects
{
    if (!objects && [objects count] == 0)
    {
        return;
    }
    if (!self.objects)
    {
        self.objects = objects;
    }
    else
    {
        [self.objects addObjectsFromArray:objects];
    }
    
    [self cacheObject:self.objects forKey:self.chatId];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the transcript for this row
    SSConversation *transcript = [[SSConversation alloc]initWithDictionary: [self.objects objectAtIndex:indexPath.row]];
    
    // Check if it's an image progress, completed image, or text message
    UITableViewCell *cell;
    if (nil != transcript.imageUrl) {
        // It's a completed image
        cell = [tableView dequeueReusableCellWithIdentifier:@"Image Cell" forIndexPath:indexPath];
        // Get the image view
        ImageView *imageView = (ImageView *)[cell viewWithTag:IMAGE_VIEW_TAG];
        // Set up the image view for this transcript
        imageView.transcript = transcript;
    }
    else if (nil != transcript.progress) {
        // It's a resource transfer in progress
        cell = [tableView dequeueReusableCellWithIdentifier:@"Progress Cell" forIndexPath:indexPath];
        ProgressView *progressView = (ProgressView *)[cell viewWithTag:PROGRESS_VIEW_TAG];
        // Set up the progress view for this transcript
        progressView.transcript = transcript;
    }
    else {
        // Get the associated cell type for messages
        cell = [tableView dequeueReusableCellWithIdentifier:@"Message Cell" forIndexPath:indexPath];
        // Get the message view
        MessageView *messageView = (MessageView *)[cell viewWithTag:MESSAGE_VIEW_TAG];
        // Set up the message view for this transcript
        messageView.transcript = transcript;
    }
    return cell;
}

// Return the height of the row based on the type of transfer and custom view it contains
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dynamically compute the label size based on cell type (image, image progress, or text message)
    SSConversation *transcript = [self.objects objectAtIndex:indexPath.row];
    if (nil != transcript.imageUrl) {
        return [ImageView viewHeightForTranscript:transcript];
    }
    else if (nil != transcript.progress) {
        return [ProgressView viewHeightForTranscript:transcript];
    }
    else {
        return [MessageView viewHeightForTranscript:transcript];
    }
}


- (void) viewWillAppear:(BOOL)animated
{
   // [super viewWillAppear:animated];
    //self.navigationController.navigationBar.hidden = NO;
    //[self refreshUI];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.objectType = MESSAGING_CLASS;
     
    self.title = @"Messaging";
    self.addable = YES;

    //self.queryPrefixKey = TITLE;
    self.orderBy = CREATED_AT;
    self.ascending = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    editView.frame = CGRectMake(0, keyboardTop - editView.frame.size.height, editView.frame.size.width, editView.frame.size.height);
    msgView.frame =  CGRectMake(0, 0, self.view.frame.size.width, keyboardTop - editView.frame.size.height);
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    editView.frame = CGRectMake(0, self.view.frame.size.height- editView.frame.size.height, editView.frame.size.width, editView.frame.size.height);
    msgView.frame =  CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - editView.frame.origin.y);
    [UIView commitAnimations];
}
@end
