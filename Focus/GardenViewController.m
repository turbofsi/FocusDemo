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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        r = i / 3;
        c = i % 3;
        imgView.frame = CGRectMake(64 + c * 64, 100 + r * 64, 64, 64);
        [self.view addSubview:imgView];
    }
    
    NSString *dateStr = [NSString stringWithString:[self showDateWithOffset:idx]];
    UILabel *label = (id)[self.view viewWithTag:101];
    label.text = dateStr;
    
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
    for(UIView *myImgview in [self.view subviews])
    {
        if ([myImgview isKindOfClass:[UIImageView class]]) {
            [myImgview removeFromSuperview];
        }
    }
    
    userDB *myDB = [[userDB alloc] init];

    _gardenArray = [myDB loadTypeFromDataBaseWithOffset:idx];
    
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
        r = i / 3;
        c = i % 3;
        imgView.frame = CGRectMake(64 + c * 64, 100 + r * 64, 64, 64);
        [self.view addSubview:imgView];
    }
    
    NSString *dateStr = [NSString stringWithString:[self showDateWithOffset:idx]];
    UILabel *label = (id)[self.view viewWithTag:101];
    label.text = dateStr;
    
}

- (IBAction)nextAction:(id)sender {
    if (idx > 0) {
        idx--;
    }
    for(UIView *myImgview in [self.view subviews])
    {
        if ([myImgview isKindOfClass:[UIImageView class]]) {
            [myImgview removeFromSuperview];
        }
    }
    
    userDB *myDB = [[userDB alloc] init];
    
    _gardenArray = [myDB loadTypeFromDataBaseWithOffset:idx];
    
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
        r = i / 3;
        c = i % 3;
        imgView.frame = CGRectMake(64 + c * 64, 100 + r * 64, 64, 64);
        [self.view addSubview:imgView];
    }
    NSString *dateStr = [NSString stringWithString:[self showDateWithOffset:idx]];
    UILabel *label = (id)[self.view viewWithTag:101];
    label.text = dateStr;

}

- (IBAction)backAction:(UISwipeGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSString *)showDateWithOffset: (int)offset {
    NSDate *myDate = [NSDate date];
    NSDate *showDate = [NSDate dateWithTimeInterval:-(60 * 60 * 24 * offset) sinceDate:myDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    NSString *dateStr = [dateFormatter stringFromDate:showDate];
    return dateStr;
}
@end
