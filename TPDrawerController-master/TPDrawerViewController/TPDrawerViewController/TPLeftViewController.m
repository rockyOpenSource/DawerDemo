//
//  TPLeftViewController.m
//  TPDrawerViewController
//
//  Created by Tpphha on 16/1/14.
//  Copyright © 2016年 Tpphha. All rights reserved.
//

#import "TPLeftViewController.h"
#import "ViewController.h"
@interface TPLeftViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,strong) UITableView *tabelView;

@property (nonatomic,strong) NSArray *tabelArr;
@end

@implementation TPLeftViewController


static NSString * const BaoyuCellReuseId = @"baoyucell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    self.tabelArr = @[@"撼地神牛",@"主宰",@"风行者",@"混沌骑士"];
    
    [self.view addSubview:self.tabelView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ----------------tableView协议--------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tabelArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaoyuCellReuseId];
    cell.textLabel.text = self.tabelArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.drawer reloadCenterViewControllerUsingBlock:^{
        
        //执行点击事件，如果传值可以将plainViewController作成单例传值
        
        ViewController *plainVC = [ViewController defaultPlainViewController];
        plainVC.showLabel.text = self.tabelArr[indexPath.row];
        NSLog(@"%@",plainVC.showLabel.text);
    }];
}


#pragma mark ----------------懒加载--------------------
- (UITableView *)tabelView{
    if (!_tabelView) {
        _tabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kTPDrawerControllerDrawerDepth, self.view.bounds.size.height) style:UITableViewStylePlain];
        _tabelView.delegate = self;
        _tabelView.dataSource = self;
        [_tabelView registerClass:[UITableViewCell class] forCellReuseIdentifier:BaoyuCellReuseId];
    }
    return _tabelView;
}


#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen:(TPDrawerViewController *)drawerController
{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidOpen:(TPDrawerViewController *)drawerController
{
    self.view.userInteractionEnabled = YES;
}

- (void)drawerControllerWillClose:(TPDrawerViewController *)drawerController
{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(TPDrawerViewController *)drawerController
{
    self.view.userInteractionEnabled = YES;
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
