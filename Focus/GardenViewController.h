//
//  GardenViewController.h
//  gardenDemo
//
//  Created by apple on 2015-03-10.
//  Copyright (c) 2015 UofT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GardenViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *gardenArray;
- (IBAction)preAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)backAction:(UISwipeGestureRecognizer *)sender;
- (IBAction)shareAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *grassView;

@end
