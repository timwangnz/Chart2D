/*
     File: MessageView.h
 Abstract: 
    This is a content view class for managing the 'text message' type table view cells
 
  Version: 1.0
 
 
*/

#import <UIKit/UIKit.h>

@class SSConversation;

// TAG used in our custom table view cell to retreive this view
#define MESSAGE_VIEW_TAG (99)

@interface MessageView : UIView

@property (nonatomic, assign) SSConversation *transcript;

// Class method for computing a view height based on a given message transcript
+ (CGFloat)viewHeightForTranscript:(SSConversation *)transcript;

@end
