//
//  ViewController.m
//  TPDrawerViewController
//
//  Created by Tpphha on 16/1/14.
//  Copyright © 2016年 Tpphha. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,strong) UIButton *openDrawerButton;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self addDraweButton];
    [self addShowLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----------------单例--------------------
+ (instancetype)defaultPlainViewController { 
    static ViewController *defaultPVC = nil;
    if (!defaultPVC) {
        defaultPVC = [[self alloc] init];
    }
    return defaultPVC;
}

#pragma mark ----------------添加按钮--------------------
- (void)addDraweButton{
    self.openDrawerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openDrawerButton.frame = CGRectMake(10.0f, 20.0f, 44.0f, 44.0f);
    [self.openDrawerButton setImage:[UIImage imageNamed:@"zixunBarFlat"] forState:UIControlStateNormal];
    [self.openDrawerButton addTarget:self action:@selector(openDrawer:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.openDrawerButton];
}

#pragma mark ----------------添加展示按钮--------------------
- (void)addShowLabel{
    self.showLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 100, 200, 50)];
    self.showLabel.textAlignment = NSTextAlignmentCenter;
    self.showLabel.text = @"XXXX";
    self.showLabel.font = [UIFont systemFontOfSize:40];
    self.showLabel.center = self.view.center;
    self.showLabel.textColor = [UIColor blackColor];
    
    
    [self.view addSubview:self.showLabel];
}



/**
 *  openDeaw注册事件
 */
- (void)openDrawer:(UIButton *)button{
    [self.drawer open];
}

#pragma mark ----------------view’s layout behavior--------------------
- (BOOL)prefersStatusBarHidden{
    return NO;
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark ----------------ICSDrawerControllerPresenting--------------------
- (void)drawerControllerWillOpen:(TPDrawerViewController *)drawerController{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(TPDrawerViewController *)drawerController{
    self.view.userInteractionEnabled = YES;
}
@end
