//
//  ViewController.m
//  CycleCollectionView
//
//  Created by Hello Cai on 2021/9/21.
//

#import "ViewController.h"
#import "HRCycleView.h"
#import "HRScrollCycleView.h"
#import "MJRefresh/MJRefresh.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setView];
}

-(void)setView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 500)];
    tableView.tableHeaderView = headerView;
    
    //用UICollectionView实现轮播
    HRCycleView *cycleView = [[HRCycleView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 200)];
    [headerView addSubview:cycleView];
    
    //用UIScrollView实现轮播
    HRScrollCycleView *scrol = [[HRScrollCycleView alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, 200)];
    [headerView addSubview:scrol];
    
    
    //下拉刷新
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        cycleView.data = @[@"num_1",@"num_2",@"num_3",@"num_4",@"num_5"];
        scrol.data = @[@"num_1",@"num_2",@"num_3",@"num_4",@"num_5"];
        
        [tableView.mj_header endRefreshing];
    }];
    
    [tableView.mj_header beginRefreshing];
}

@end
