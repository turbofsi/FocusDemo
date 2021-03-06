//
//  GardenViewController.m
//  gardenDemo
//
//  Created by apple on 2015-03-10.
//  Copyright (c) 2015 UofT. All rights reserved.
//

#import "GardenViewController.h"
#import "userDB.h"

@interface GardenViewController ()

@end

@implementation GardenViewController

int idx = 0;

- (void)viewDidLoad {
    idx = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self drawPomodoros];
    
    NSString *dateStr = [NSString stringWithString:[self showDateWithOffset:idx]];
    _dateLabel.text = dateStr;
    [self.view bringSubviewToFront:_dateLabel];
    [self.view sendSubviewToBack:_grassView];
    
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



- (IBAction)preAction:(id)sender {
    idx++;
    for(UIView *myImgview in [_grassView subviews])
    {
        if ([myImgview isKindOfClass:[UIImageView class]]) {
            [myImgview removeFromSuperview];
        }
    }
    
    userDB *myDB = [[userDB alloc] init];

    _gardenArray = [myDB loadTypeFromDataBaseWithOffset:idx];
    
    [self drawPomodoros];
    
    NSString *dateStr = [NSString stringWithString:[self showDateWithOffset:idx]];
    _dateLabel.text = dateStr;
    
}

- (IBAction)nextAction:(id)sender {
    if (idx > 0) {
        idx--;
    }
    for(UIView *myImgview in [_grassView subviews])
    {
        if ([myImgview isKindOfClass:[UIImageView class]]) {
            [myImgview removeFromSuperview];
        }
    }
    
    userDB *myDB = [[userDB alloc] init];
    
    _gardenArray = [myDB loadTypeFromDataBaseWithOffset:idx];
    
    [self drawPomodoros];
    
    NSString *dateStr = [NSString stringWithString:[self showDateWithOffset:idx]];
    _dateLabel.text = dateStr;

}

- (IBAction)backAction:(UISwipeGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)shareAction:(UIButton *)sender {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    userDB *myDB = [[userDB alloc] init];
    array = [myDB loadTypeFromDataBaseWithOffset:0];
    
    //get the number of successful pomodoro
    __block int spNum = 0;
    __block unsigned long spoilNum = 0;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *detStr = [NSString stringWithFormat:@"%@", obj];
        if ([detStr isEqualToString:@"1"]) {
            spNum++;
        }
    }];
    spoilNum = [array count] - spNum;
    
    NSString *shareText = [NSString stringWithFormat:@"I got %d successful pomodoros :) and %lu spoiled pomodoros :( today!", spNum, spoilNum];
    UIImage *imgFocus = [UIImage imageNamed:@"garden"];
    
    NSArray *itemsToShare = @[shareText, imgFocus];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[];
    [self presentViewController:activityVC animated:YES completion:NULL];
    if ([activityVC respondsToSelector:@selector(popoverPresentationController)])
    {
        // iOS 8+
        UIPopoverPresentationController *presentationController = [activityVC popoverPresentationController];
        
        presentationController.sourceView = sender; // if button or change to self.view.
    }
}

- (NSString *)showDateWithOffset: (int)offset {
    NSDate *myDate = [NSDate date];
    NSDate *showDate = [NSDate dateWithTimeInterval:-(60 * 60 * 24 * offset) sinceDate:myDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *dateStr = [dateFormatter stringFromDate:showDate];
    return dateStr;
}

- (void)drawPomodoros{
    int r = 0;
    int c = 0;
    for (int i = 0; i < [_gardenArray count]; i++) {
        UIImageView *imgView = [[UIImageView alloc] init];
        NSString *idStr = _gardenArray[i];
        if ([idStr isEqualToString:@"1"]) {
            imgView.image = [UIImage imageNamed:@"1"];
        } else {
            imgView.image = [UIImage imageNamed:@"2"];
        }
        r = i / 5;
        c = i % 5;
        imgView.frame = CGRectMake(c * 64, 120 + r * 64, 64, 64);
        [_grassView addSubview:imgView];
    }
}
@end
