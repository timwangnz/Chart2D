//
//  WCPictureVC.m
//  Mappuccino
//
//  Created by Anping Wang on 3/23/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSPictureVC.h"
#import "SSImageEditorVC.h"
#import "SSTalkImageView.h"
#import "SSSecurityVC.h"

@interface SSPictureVC ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
{
    IBOutlet SSTalkImageView *imageView;
    NSDictionary *selected;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UILabel *noPictures;
    IBOutlet UIImageView *iconView;
    IBOutlet UIView *editView;
    IBOutlet UIView *imagesView;
    IBOutlet UILabel *caption;
    IBOutlet UITextField *captionField;
    IBOutlet UIButton *deleteBtn;
    
    IBOutlet UILabel *progressLabel;
    int initalPicture;
}

- (IBAction)setPage:(id)sender;
- (IBAction)last:(id)sender;
- (IBAction)next:(id)sender;

- (IBAction)upload:(id)sender;
- (IBAction)cancelUpdate:(id)sender;
- (IBAction)deletePicture:(id)sender;

@end

@implementation SSPictureVC

- (void) setCurrentIndex:(int) index
{
    initalPicture = index;
}

- (IBAction)last:(id)sender
{
    if ([self.dataObjects count] <=1) {
        return;
    }
    if (pageControl.currentPage > 0)
    {
        pageControl.currentPage --;
        [self setPage:sender];
    }
}

- (IBAction)next:(id)sender
{
    if ([self.dataObjects count] <=1) {
        return;
    }
    
    if (pageControl.currentPage < pageControl.numberOfPages - 1)
    {
        pageControl.currentPage ++;
        [self setPage:sender];
    }
}

- (IBAction)setPage:(id)sender
{
    selected = [self.dataObjects objectAtIndex:pageControl.currentPage];
    imageView.defaultImg = [UIImage imageNamed:@"imgbg.png"];
    imageView.url = [selected objectForKey:@"contentUrl"];
    caption.text = [selected objectForKey:@"name"];
}

- (IBAction)deletePicture:(id)sender
{
    [self delete: selected];
}

- (IBAction) cancelUpdate:(id)sender
{
    [self switchView:imagesView  withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (IBAction)upload:(id)sender
{
    CGSize size = CGSizeMake(320, 320);
    NSData *imageData = UIImageJPEGRepresentation([SSImageEditorVC imageWithImage:iconView.image scaledToSize:size], 0.8);
    size = CGSizeMake(72, 72);
    NSData *iconData = UIImageJPEGRepresentation([SSImageEditorVC imageWithImage:iconView.image scaledToSize:size], 0.8);
    
    progressLabel.text = @"Upload picture";
    NSMutableDictionary *resource = [NSMutableDictionary dictionary];
    
    [resource setValue:captionField.text ? captionField.text : @"No Caption" forKey:@"name"];
    
    [resource setValue:@"image/jpeg" forKey:@"contentType"];
    
    [resource setValue:@"normal" forKey:@"imageType"];
    
    [resource setValue:self.parentId forKey:@"parentId"];
    [resource setValue:self.parentType forKey:@"parentType"];
    [captionField resignFirstResponder];
    [resource setValue:[NSNumber numberWithInt:[imageData length]] forKey:@"contentLength"];
    [self blockView];
    [self upload:imageData icon:iconData withMetadata:resource];
}

- (void) showEditView
{
    [self switchView:editView  withOptions: UIViewAnimationOptionTransitionCrossDissolve];
}

- (void) getPicture
{

         captionField.text = nil;
         progressLabel.text = nil;
         [self loadImage: self];

}

- (void) processImage: (id) image
{
    iconView.image = image;
    [self showEditView];
}

- (void) downloaded :(SSCallbackEvent *)event
{
    imageView.image = [UIImage imageWithData:event.data];
    caption.text = [selected objectForKey:@"name"];
    [self unblockView];
    [self switchView:imagesView withOptions:UIViewAnimationOptionTransitionCrossDissolve];
}

- (void) updateUI
{
    [super updateUI];
    if ([self.dataObjects count] > 0)
    {
        pageControl.numberOfPages = [self.dataObjects count];
        pageControl.currentPage = initalPicture;
        progressLabel.text = @"Loading picture";
        
        [self setPage:pageControl];
    }
    else
    {
        imageView.image = nil;
    }
    pageControl.hidden = [self.dataObjects count] == 0;
    noPictures.hidden = !pageControl.hidden;
    deleteBtn.hidden = pageControl.hidden;
    caption.hidden = deleteBtn.hidden || [caption.text isEqualToString:@"No Caption"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.objectType = @"org.sixstreams.social.Resource";
    
    if (self.parentId)
    {
        self.queryString = [NSString stringWithFormat:@"parentId:%@", self.parentId];
    }
        
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Add"
                                                                              style: UIBarButtonItemStyleBordered
                                                                             target: self action: @selector(getPicture)
                                              ];
    [self getObjects];
}

@end
