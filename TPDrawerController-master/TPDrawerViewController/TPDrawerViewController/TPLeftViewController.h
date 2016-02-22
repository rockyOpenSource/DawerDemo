//
//  TPLeftViewController.h
//  TPDrawerViewController
//
//  Created by Tpphha on 16/1/14.
//  Copyright © 2016年 Tpphha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPDrawerViewController.h"
@interface TPLeftViewController : UIViewController <TPDrawerControllerChild, TPDrawerControllerPresenting>
@property(nonatomic, weak) TPDrawerViewController *drawer;
@end
