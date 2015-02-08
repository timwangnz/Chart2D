//
//  ImagePickerViewController.m
//  iSwim2.0
//
//  Created by Anping Wang on 3/17/11.
//  Copyright 2011 s. All rights reserved.
//
#import <MobileCoreServices/MobileCoreServices.h>
#import "SSImageEditorVC.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SSImageEditorVC ()
{
    UIImage *image;
    IBOutlet UIImageView *photoView;
    IBOutlet UIView *boundView;
    IBOutlet UIView *editView;
    IBOutlet UIView *selectView;
    CGFloat firstX;
    CGFloat firstY;
    CGFloat lastScale;
    UIImagePickerController *imagePicker;
    CGSize originSize;
    
}

- (IBAction) cancel :(id) sender;

@end

@implementation SSImageEditorVC

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) imagePickerController:(UIImagePickerController *) picker didFinishPickingMediaWithInfo:(NSDictionary*) info
{
    if([picker.mediaTypes count] == 1 && [[picker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie])
    {
        if (self.processImageDelegate && [self.processImageDelegate respondsToSelector:@selector(processVideo:)])
        {
            NSURL *videoURL = info[UIImagePickerControllerMediaURL];
            [self.processImageDelegate processVideo:videoURL];
        }
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    else
    {
        [self editImage : [info objectForKey:UIImagePickerControllerOriginalImage]];
        [picker pushViewController:self animated:YES];
    }
}

- (IBAction) takePhoto: (id) sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.fromVC showPopup:picker sender:sender];
}

- (IBAction) pickFromLib: (id) sender
{
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.fromVC showPopup:picker sender:sender];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.background)
    {
        self.view.backgroundColor = self.background;
        editView.backgroundColor = self.background;
    }
    self.navigationController.navigationBar.hidden = YES;
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [photoView addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [pinchRecognizer setDelegate:self];
    [photoView addGestureRecognizer:pinchRecognizer];
    photoView.frame = CGRectMake(0, 1, 320,320);
    
    photoView.image = image;
    [self initialPosition];
}

- (void) editImage :(UIImage *) anImage
{
    image = anImage;
}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
	//create a context to do our clipping in
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	//create a rect with the size we want to crop the image to
	//the X and Y here are zero so we start at the beginning of our
	//newly created context
	CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	CGContextClipToRect(currentContext, clippedRect);
	
	//create a rect equivalent to the full size of the image
	//offset the rect by the X and Y we want to start the crop
	//from in order to cut off anything before them
    
	CGRect drawRect = CGRectMake(rect.origin.x * -1,
								 rect.origin.y * -1,
								 imageToCrop.size.width,
								 imageToCrop.size.height);
	
	[imageToCrop drawInRect:drawRect];
  
	//draw the image to our clipped context using our offset rect
	//CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
	
	//pull the image from our cropped context
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	//Note: this is autoreleased
	return cropped;
}

- (IBAction) cancel :(id) sender
{
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) saveImage: (id) sender
{
	CGRect toRect;
	CGSize origin = boundView.frame.size;
	CGSize imageOrigin	= photoView.image.size;
	CGRect viewRect = photoView.frame;
	
	if (imageOrigin.width > imageOrigin.height) {
		
		CGFloat scale = viewRect.size.width/boundView.frame.size.width;
		CGFloat imageRatio = imageOrigin.width/origin.width;
		CGFloat xOffset = 0;
		CGFloat yOffset = origin.width * scale * (imageOrigin.width - imageOrigin.height)/imageOrigin.width/2;
		
		toRect = CGRectMake((-viewRect.origin.x - xOffset) * imageRatio/ scale, (-viewRect.origin.y - yOffset) * imageRatio/ scale,
							boundView.frame.size.width*imageRatio/scale,
							boundView.frame.size.height*imageRatio/scale);
        
	}
	else
    {
		CGFloat scale = viewRect.size.height/boundView.frame.size.height;
		CGFloat imageRatio = imageOrigin.height/origin.height;
		CGFloat yOffset = 0;
		CGFloat xOffset = origin.height	* scale * (imageOrigin.height - imageOrigin.width)/imageOrigin.height/2;
		
		toRect = CGRectMake((-viewRect.origin.x - xOffset) * imageRatio/ scale, (-viewRect.origin.y - yOffset) * imageRatio/ scale,
							boundView.frame.size.width*imageRatio/scale,
							boundView.frame.size.height*imageRatio/scale);
	}
	
	image = [self imageByCropping: photoView.image toRect:toRect];
    if (self.scale2Size > 0)
    {
        image = [SSImageEditorVC imageWithImage: image scaledToSize: CGSizeMake(self.scale2Size, self.scale2Size)];
    }

	if (self.processImageDelegate && [self.processImageDelegate respondsToSelector:@selector(processImage:)])
	{
        [self.processImageDelegate processImage:image];
	}
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

//initialial scale the picture to fit into the the square
- (void) initialPosition
{
    CGFloat scale = image.size.width > image.size.height ? image.size.width/image.size.height : image.size.height/image.size.width;
    
    if (fmax(image.size.width, image.size.height) < photoView.frame.size.width)
    {
        scale = 1;
    }
	CGAffineTransform currentTransform = photoView.transform;
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
	
	[photoView setTransform:newTransform];
}

-(void)scale:(id)sender
{
	[self.view bringSubviewToFront:[(UIPinchGestureRecognizer*)sender view]];
	
	if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
		
		lastScale = 1.0;
		return;
	}
	
	CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
	
	CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
	
	[[(UIPinchGestureRecognizer*)sender view] setTransform:newTransform];
	
	lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

-(void)move:(id)sender {
	[self.view bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
		
		firstX = [[sender view] center].x;
		firstY = [[sender view] center].y;
	}
	translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
	[[sender view] setCenter:translatedPoint];
}

@end
