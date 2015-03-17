//
//  MainViewController.m
//  Focus
//
//  Created by apple on 2015-02-09.
//  Copyright (c) 2015 UofT. All rights reserved.
//

#import "MainViewController.h"
#import "GardenViewController.h"
#import "userDB.h"

@interface MainViewController ()

@end

@implementation MainViewController


int sensor_count = 0;
bool isPrepared = NO;

int left_x_position, right_x_position;
int left_y_position, right_y_position;
int mouth_x_position, mouth_y_position;

-(void)viewDidAppear:(BOOL)animated{
    // Live Image Part
#pragma mark - live image
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetMedium;
    
    CALayer *viewLayer = self.liveImage.layer;
    NSLog(@"viewLayer = %@", viewLayer);
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    
    captureVideoPreviewLayer.frame = self.liveImage.bounds;
    [self.liveImage.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device;
    
    AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionFront;
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            device = d;
            break;
        }
    }
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [_session addInput:input];
    
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                       [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked
    
    // create a serial dispatch queue used for the sample buffer delegate
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    
    if ( [_session canAddOutput:self.videoDataOutput] ){
        [_session addOutput:self.videoDataOutput];
    }
    
    if (isPrepared) {
        [_session startRunning];

    }
    //  Live image Part End
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
                                                      options:(__bridge NSDictionary *)attachments];
    
    
    NSDictionary *imageOptions = nil;
    
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    imageOptions = [NSDictionary dictionaryWithObject:[self exifOrientation:curDeviceOrientation]
                                               forKey:CIDetectorImageOrientation];
    
    NSArray *features = [self.faceDetector featuresInImage:ciImage options:imageOptions];
    
    if ([features count] == 0) {
        sensor_count++;
        NSLog(@"%d", sensor_count);
    }
    else{
        for (CIFaceFeature *f in features) {
            sensor_count = 0;
            if (f.hasLeftEyePosition) {
                left_x_position = f.leftEyePosition.x;
                left_y_position = f.leftEyePosition.y;
                
            }
            if (f.hasRightEyePosition) {
                right_x_position = f.rightEyePosition.x;
                right_y_position = f.rightEyePosition.y;
            }
            
            if (f.hasMouthPosition) {
                mouth_x_position = f.mouthPosition.x;
                mouth_y_position = f.mouthPosition.y;
            }
            
        }
    }
    
}

- (NSNumber *) exifOrientation: (UIDeviceOrientation) orientation
{
    int exifOrientation;
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            if (/* DISABLES CODE */ (YES))
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            if (YES)
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    return [NSNumber numberWithInt:exifOrientation];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    UIImage *alertImg = [UIImage imageNamed:@"alertframe"];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:alertImg];
    imgView.frame = CGRectMake(160 - 75, 116, 150, 200);
    imgView.alpha = 0;
    imgView.tag = 107;
    [self.view addSubview:imgView];
    [self.view bringSubviewToFront:imgView];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.333 target:self selector:@selector(postionUpdate) userInfo:nil repeats:YES];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    userDB *myDB = [[userDB alloc] init];
    [myDB creatDataBase];
    
    self.isGiveUp = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MainToBreath"]) {
        UIButton *setBtn = (id)[self.view viewWithTag:101];
        setBtn.enabled = NO;
        
        UIButton *startBtn = (id)[self.view viewWithTag:102];
        startBtn.enabled = YES;
    }
    if ([segue.identifier isEqualToString:@"MainToGarden"]) {
        GardenViewController *gardenVC = [segue destinationViewController];
        NSMutableArray *gardenArray = [[NSMutableArray alloc] init];
        NSMutableArray *dateArray = [[NSMutableArray alloc] init];
        userDB *myDB = [[userDB alloc] init];
        gardenArray = [myDB loadTypeFromDataBaseWithOffset:0];
        dateArray = [myDB loadDateFromDataBase];
        NSLog(@"The dateArray: %@", dateArray);
        gardenVC.gardenArray = [[NSMutableArray alloc] initWithArray:gardenArray];
    }
}

- (IBAction)unwindtoMain:(UIStoryboardSegue *)segue {
    
    sensor_count = 0;
    [_session startRunning];

}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        _isGiveUp = YES;
    }
}

- (IBAction)StartTimer:(id)sender {
    isPrepared = YES;
    _isGiveUp = NO;
    _timerLabel.text = @"25:00";
    [_session startRunning];
    __block int timeout = 25 * 60;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0 || _isGiveUp == YES){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                NSLog(@"Time up!");
                _timerLabel.text = @"00:00";
                _timerLabel.text = @"25:00";
                UIImageView *imgView = (id)[self.view viewWithTag:107];
                imgView.alpha = 0;
                userDB *myDB = [[userDB alloc] init];
                
                if (_isGiveUp == YES) {
                    [myDB inserToDataBaseWithType:@"2"];
                } else {
                    [myDB inserToDataBaseWithType:@"1"];
                }                
                UIButton *setBtn = (id)[self.view viewWithTag:101];
                setBtn.enabled = YES;
                _liveImage.alpha = 0;
                isPrepared = NO;
                [_session stopRunning];
            });
        }
        //
        
        
        else {
            int minutes = timeout / 60;
            int seconds = timeout % 60;
            
            NSString *minStr = [[NSString alloc] init];
            NSString *secStr = [[NSString alloc] init];
            
            if (minutes < 10) {
                minStr = [NSString stringWithFormat:@"0%d", minutes];
            } else {
                minStr = [NSString stringWithFormat:@"%d", minutes];
            }
            
            if (seconds < 10) {
                secStr = [NSString stringWithFormat:@"0%d", seconds];
            } else {
                secStr = [NSString stringWithFormat:@"%d", seconds];
            }
            
            NSString *strTime = [NSString stringWithFormat:@"%@:%@", minStr, secStr];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                _timerLabel.text = strTime;
                
            });
            timeout--;
            
        }
    });
    
    
    dispatch_resume(_timer);
    
    UIButton *btn = (id)[self.view viewWithTag:102];
    btn.enabled = NO;
    
}

- (void)postionUpdate {
    if (isPrepared) {
        float dis = sqrt(pow((left_x_position - right_x_position), 2) + pow((left_y_position - right_y_position), 2));
        float k = (float)(left_x_position - right_x_position) / (left_y_position - right_y_position);
        //    _leftLabel.text = [NSString stringWithFormat:@"%.2f", dis];
        //    _rightLabel.text = [NSString stringWithFormat:@"%.2f", k];
        
        UIImageView *imgView = (id)[self.view viewWithTag:107];
        if (k < 0) {
            k = -k;
        }
/**************************sitting posture notification**************************/
        if (mouth_x_position > 290 || k > 0.2 || dis > 80) {
            imgView.alpha = 0.7;
            _liveImage.alpha = 0.5;
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
        } else {
            _liveImage.alpha = 0;
            imgView.alpha = 0;

        }
        
/**************************Leaving seat notification*****************************/

        if (sensor_count > 50 && isPrepared == YES) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            _timerLabel.alpha = 0.5;
        } else {
            _timerLabel.alpha = 1;
        }

    }
}



@end
