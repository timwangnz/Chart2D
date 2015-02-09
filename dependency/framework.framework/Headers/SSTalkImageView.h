//
//  SSTalkImageView.h
//  Mappuccino
//
//  Created by Anping Wang on 4/26/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSImageView.h"
#import <AVFoundation/AVFoundation.h>

@interface SSTalkImageView : SSImageView<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
}
@end
