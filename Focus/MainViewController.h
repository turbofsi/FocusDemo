//
//  MainViewController.h
//  Focus
//
//  Created by apple on 2015-02-09.
//  Copyright (c) 2015 UofT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MainViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *liveImage;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
- (IBAction)StartTimer:(id)sender;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) AVCaptureSession *session;
@property BOOL isGiveUp;

- (IBAction)unwindtoMain:(UIStoryboardSegue *)segue;



@end
