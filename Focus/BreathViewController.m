//
//  BreathViewController.m
//  Focus
//
//  Created by apple on 2015-02-09.
//  Copyright (c) 2015 UofT. All rights reserved.
//

#import "BreathViewController.h"

@interface BreathViewController ()

@end

@implementation BreathViewController

int exhalCount = 0;
int breathTime = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
#pragma mark - shows the imageView
    exhalCount = 0;
    breathTime = 3;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 300, 100, 120)];
    UIImage *image = [UIImage imageNamed:@"balloon"];
    imgView.image = image;
    imgView.tag = 101;
    imgView.alpha = 0.8;
    [self.view addSubview:imgView];
    /******************Set Breath Detector********************/
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 2],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSError *error;
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    if (recorder) {
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    }
    /******************Set Breath Detector********************/
    
    
}
- (void)levelTimerCallback:(NSTimer *)timer {
    [recorder updateMeters];
    
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    NSString *str = [NSString stringWithFormat:@"result = %f", lowPassResults];
    NSLog(@"%@", str);
    /***********************Update the position of Balloon***********************/
    UIImageView *imgView = (UIImageView *)[self.view viewWithTag:101];
    CGRect frame = imgView.frame;
    
    double gap = lowPassResults - 0.55;
    if (gap > 0) {
        frame.size.width = frame.size.width + 3 * gap;
        frame.size.height = frame.size.height + 4 * gap;
        frame.origin.x = frame.origin.x - 1.5 * gap;
        exhalCount++;
    }else {
        frame.origin.y = frame.origin.y + 0.5 * gap;
    }
    
    if (exhalCount > 160 && breathTime != 0) {
        frame = CGRectMake(110, 300, 100, 120);
        breathTime--;
        exhalCount = 0;
        UILabel *manyLabel = (id)[self.view viewWithTag:303];
        NSString *manyStr = [NSString stringWithFormat:@"%d", 3 - breathTime];
        manyLabel.text = manyStr;
    }
    
    if (breathTime == 0) {
        [imgView removeFromSuperview];
        UIButton *btn = (id)[self.view viewWithTag:102];
        btn.enabled = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"check2`"] forState:UIControlStateNormal];
        [recorder stop];
        [levelTimer invalidate];
    }

    imgView.frame = frame;
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
