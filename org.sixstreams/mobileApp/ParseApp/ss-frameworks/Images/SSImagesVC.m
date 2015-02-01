//
//  SSImagesVC.m
//  SixStreams
//
//  Created by Anping Wang on 12/28/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSImagesVC.h"
#import "SSFilter.h"
#import "SSTableViewVC.h"
#import "SSImageEditorVC.h"
#import "SSConnection.h"
#import "SSImageViewCell.h"
#import "SSSecurityVC.h"

@interface SSImagesVC ()<ProcessImageDelegate, UIActionSheetDelegate>
{
    SSImageEditorVC *imageEditor;
    NSTimer *aTimer;
    int timerCounter;
}
- (IBAction)pickImg:(id)sender;

@end

@implementation SSImagesVC

- (void) doTimer
{
    timerCounter ++;
    if (timerCounter >= [self.objects count])
    {
        timerCounter = 0;
    }
    [self refreshUI];
}

- (void) startAnimation
{
    [aTimer invalidate];
    if (self.singlePicture) {
        if([self.objects count] < 2)
        {
            return;
        }
        timerCounter = 0;
        
         aTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                   target:self
                                                 selector:@selector(doTimer) userInfo:nil repeats:YES];
    }
    return;
}

- (void) stopAnimation
{
    [aTimer invalidate];
}

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = FILE_CLASS;
    //self.tableColumns = 1;
    self.title = @"Images";
    self.tabBarItem.image = [UIImage imageNamed:@"mind_map-32.png"];
    self.addable = NO;
    self.showBusyIndicator = NO;
    self.orderBy = CREATED_AT;
    self.ascending = NO;
    //self.showHeaders = NO;
}

- (void) forceRefresh
{
    [self.predicates removeAllObjects];
    [self.predicates addObject:[SSFilter on:RELATED_ID op:EQ value:self.relatedId ? self.relatedId : @"no_other_98453822"]];
    [super forceRefresh];
}

- (void) processImage: (UIImage *)image
{
    SSConnection *conn = [SSConnection connector];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", self.relatedType, self.relatedId];
    
    if(self.singlePicture && [self.objects count]>0)
    {
        [conn replaceFile:imageData
                 fileName:fileName
             fileObjectId:[[self.objects objectAtIndex:0]objectForKey:REF_ID_NAME]
         
                onSuccess:^(id data) {
                    [self forceRefresh];
                } onFailure:^(NSError *error) {
                    [self showAlert:@"Error" withTitle:@"Failed to upload, please try again"];
                }];
    }
    else
    {
        [conn uploadFile: imageData
                fileName: fileName
             relatedType: self.relatedType
               relatedId: self.relatedId
                fileType: FILE_TYPE_IMG
                    desc: self.desc == nil ? @"" : self.desc
               onSuccess:^(id data) {
                   [self forceRefresh];
               } onFailure:^(NSError *error) {
                   [self showAlert:@"Error" withTitle:@"Failed to upload, please try again"];
               }
         ];
    }
}

- (void) onDataReceived:(id) objects
{
    [super onDataReceived:objects];
    if ([objects count] == 0)
    {
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    }
    else{
        self.view.frame= CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [imageEditor pickFromLib:self];
    }
    if (buttonIndex == 1)
    {
        [imageEditor takePhoto:self];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.frame.size.width >= tableView.frame.size.height) {
        return  tableView.frame.size.height;
    }
    else
    {
        return tableView.frame.size.width;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.singlePicture && [self.objects count] > 0)? 1 : [self.objects count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSImageViewCell *cell = (SSImageViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SSImageViewCellIdentifier"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SSImageViewCell" owner:self options:nil];
        cell = (SSImageViewCell *)[nib objectAtIndex:0];
    }
    id item = [self.objects objectAtIndex:self.singlePicture ? timerCounter : indexPath.row];
    [cell changeFile:[item objectForKey:REF_ID_NAME]];
    return cell;
}


- (IBAction)pickImg:(id)sender
{
    if ([self isIPad])
    {
        imageEditor = [[SSImageEditorVC alloc]init];
    }
    else
    {
        imageEditor = [[SSImageEditorVC alloc] initWithNibName:@"SSImageEditorVC_iPhone" bundle:nil];
    }
    
    imageEditor.processImageDelegate = self;
    imageEditor.fromVC = self;
    imageEditor.scale2Size = 320;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Get Photos"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil otherButtonTitles:@"Load From Library", @"Take Photo", nil];
    
    
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    if ([window.subviews containsObject:self.view]) {
        [actionSheet showInView:self.view];
    } else {
        [actionSheet showInView:window];
    }

}


@end
