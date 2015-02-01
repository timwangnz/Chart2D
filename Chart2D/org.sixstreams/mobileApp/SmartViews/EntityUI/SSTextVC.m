//
//  SSTextVC.m
//  Mappuccino
//
//  Created by Anping Wang on 5/7/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSTextVC.h"

@interface SSTextVC ()
{
    NSString *attrName;
    SSAttrCell *cellEditor;
    IBOutlet UITextView *textView;
}

@end

@implementation SSTextVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(done:)];
}

- (void)done:(id)sender
{
    [cellEditor setValue: textView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) cellEdtior : (SSAttrCell*) editor selectValueFor :(NSString *) attr
{
    attrName = attr;
    cellEditor = editor;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    textView.text = [cellEditor getValue];
}


@end
