//
//  ViewController.h
//  TPDrawerViewController
//
//  Created by Tpphha on 16/1/14.
//  Copyright © 2016年 Tpphha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPDrawerViewController.h"
@interface ViewController : UIViewController <TPDrawerControllerPresenting, TPDrawerControllerChild>
@property(nonatomic, weak) TPDrawerViewController *drawer;
@property (nonatomic,strong) UILabel *showLabel;

+ (instancetype)defaultPlainViewController;
@end

