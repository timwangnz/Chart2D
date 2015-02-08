/*
     File: ProgressView.h
 Abstract: 
    This is a content view class for managing the 'resource progress' type table view cells
 
  Version: 1.0
 
 
*/

#import <UIKit/UIKit.h>

// TAG used in our custom table view cell to retreive this view
#define PROGRESS_VIEW_TAG (101)

@class SSConversation;

@interface ProgressView : UIView

@property (nonatomic, assign) SSConversation *transcript;

// Class method for computing a view height based on a given message transcript
+ (CGFloat)viewHeightForTranscript:(SSConversation *)transcript;

@end
