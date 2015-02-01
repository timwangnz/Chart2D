//
//  CheckBox.h
// Appliatics
//
//  Created by Anping Wang on 10/2/13.
//

#import "SSRoundButton.h"
#import "SSValueField.h"

@interface SSCheckBox : UIButton<SSFieldEditor>

@property (nonatomic, strong) NSString *attrName;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSString *displayValue;
@property (nonatomic, strong) NSString *valueType;

@property BOOL transient;
@property BOOL required;
@end
