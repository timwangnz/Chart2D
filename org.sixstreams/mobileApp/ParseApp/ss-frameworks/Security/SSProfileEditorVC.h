//
//  SSProfileEditorVC.h
//  Medistory
//
//  Created by Anping Wang on 10/6/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSEntityEditorVC.h"

@interface SSProfileEditorVC : SSEntityEditorVC

@property (nonatomic, strong) id friendRequest;

- (void) editMyProfile;

- (void) viewProfile: (NSString *) profileId
           onSuccess: (SuccessCallback) callback
           onFailure: (ErrorCallback) errorCallback;

@end
