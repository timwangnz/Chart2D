//
//  SSColorPickerVC.m
//  SixStreams
//
//  Created by Anping Wang on 2/28/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSColorPickerVC.h"
#import "SSLovTextField.h"

@interface SSColorPickerVC ()
{
    IBOutlet UIView *vSample;
    
    IBOutlet UISlider *sRed;
    
    IBOutlet UISlider *sAlpha;
    IBOutlet UISlider *sBlue;
    IBOutlet UISlider *sGreen;
}
- (IBAction)colorChanged:(id)sender ;
@end

@implementation SSColorPickerVC

- (UIColor *) selectedColor
{
    return [UIColor
            colorWithRed:sRed.value green:sGreen.value blue:sBlue.value alpha:sAlpha.value
            ];
}
- (IBAction)colorChanged:(id)sender {
    vSample.backgroundColor =  [self selectedColor];
    self.field.value = [NSString stringWithFormat:@"%.2f,%.2f,%.2f,%.2f", sRed.value, sGreen.value, sBlue.value, sAlpha.value];
    self.field.backgroundColor = vSample.backgroundColor;
}



@end
