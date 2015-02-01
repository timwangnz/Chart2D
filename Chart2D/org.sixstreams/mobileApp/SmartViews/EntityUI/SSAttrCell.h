//
//  CRMAttrCell.h
//  CoreCrm
//
//  Created by Anping Wang on 11/11/12.
//  Copyright (c) 2012 Anping Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoreAttrCellDelegate <NSObject>
@required
- (void) editor:(UITextField *) editor beginToEdit: (id) object;
- (void) editor:(UITextField *) editor readyToEdit: (id) object;
- (void) editor:(UITextField *) editor finishedToEdit: (id) object;
- (BOOL) editor:(UITextField *) editor shouldFinishEdit: (id) object;

@optional
- (void) actionPerformed: (id) sender;
- (void) showLov: (id) lovVC;
@end

@interface SSAttrCell : UITableViewCell

@property (strong, nonatomic) id<CoreAttrCellDelegate> delegate;

- (void) updateCellUI:(id)attr object : (id) entity;
- (void) setValueFromLov:(id) selectedLov;
- (void) setDateFromLov:(NSDate *)date forEntity:(NSString *)entityName;
- (void) setValue:(id) value;
- (id) getValue;

- (void) becomeFirstResponder;

@end
