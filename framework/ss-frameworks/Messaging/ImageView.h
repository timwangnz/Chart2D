/*
     File: ImageView.h
 Abstract: 
    This is a content view class for managing the 'image resource' type table view cells 
 
  Version: 1.0
 
 
*/

#import <UIKit/UIKit.h>

// TAG used in our custom table view cell to retreive this view
#define IMAGE_VIEW_TAG (100)

@class SSConversation;

@interface ImageView : UIView

@property (nonatomic, assign) SSConversation *transcript;

// Class method for computing a view height based on a given message transcript
+ (CGFloat)viewHeightForTranscript:(SSConversation *)transcript;

@end
