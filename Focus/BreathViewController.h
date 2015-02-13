//
//  BreathViewController.h
//  Focus
//
//  Created by apple on 2015-02-09.
//  Copyright (c) 2015 UofT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "FaceViewController.h"

@interface BreathViewController : UIViewController {

    /******************Properties for Breath Detector Part********************/
    AVAudioRecorder *recorder;
    NSTimer *levelTimer;
    double lowPassResults;
    /******************Properties for Breath Detector Part********************/


}

@end
