//
//  HRScrollCycleView.m
//  CycleCollectionView
//
//  Created by Hello Cai on 2022/2/9.
//

#import "HRScrollCycleView.h"

//轮播间隔
static CGFloat ScrollInterval = 3.0f;

@interface HRScrollCycleView ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIView *contentView;
@end

@implementation HRScrollCycleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _autoPage = YES;
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = true;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = false;
    [self addSubview:self.scrollView];
    
    CGFloat controlHeight = 35.0f;
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - controlHeight, self.bounds.size.width, controlHeight)];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    [self addSubview:self.pageControl];
}

#pragma mark - UIScrollViewDelegate
//即将开始拖拽时调用
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"scrollViewWillBeginDragging---");
    //停止定时器
    [self.timer setFireDate:[NSDate distantFuture]];
}

//手指松开拖拽那一时刻调用
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //间隔3s继续轮播
    if (_autoPage) {
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:ScrollInterval];
    }
}


//调用了setContentOffset:animated:且animated为YES，当动画结束时回调
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self adjustScrollLocation];
}
//手指松开拖拽，scrollView会惯性滑动，滑动减速完毕时回调
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

//调整循环显示的定位
- (void)adjustScrollLocation {
    NSInteger page = self.scrollView.contentOffset.x/self.scrollView.bounds.size.width;
    if (page == 0) {//滚动到最左边
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * (self.dataArray.count - 2), 0);
        self.pageControl.currentPage = self.dataArray.count-3;
    }else if (page == self.dataArray.count - 1){//滚动到最右边
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0);
        self.pageControl.currentPage = 0;
    }else{
        self.pageControl.currentPage = page - 1;
    }
}


#pragma mark - Setter
//设置数据时在第一个之前和最后一个之后分别插入数据
- (void)setData:(NSArray<NSString *> *)data {
    self.dataArray = [NSMutableArray arrayWithArray:data];
    if (self.contentView.subviews>0) {
        [self.contentView removeFromSuperview];
    }
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    NSInteger count = data.count;
    if (data.count > 1) {
        [self.dataArray addObject:data.firstObject];
        [self.dataArray insertObject:data.lastObject atIndex:0];
        
        count = self.dataArray.count;
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width, 0)];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:ScrollInterval target:self selector:@selector(showNext) userInfo:nil repeats:true];
        if(_autoPage == NO) {
            self.timer.fireDate = [NSDate distantFuture];
        }
    }
    //添加UIImageView
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    [self.scrollView addSubview:contentView];
    self.contentView = contentView;
    for (int i=0; i<count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.frame = CGRectMake(i*self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        imageView.image = [UIImage imageNamed:self.dataArray[i]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:imageView];
    }
    self.pageControl.numberOfPages = data.count<=1 ? 0 : data.count;
    self.pageControl.currentPage = 0;
    self.scrollView.contentSize = CGSizeMake(count * self.bounds.size.width, self.bounds.size.height);
}

- (void)setAutoPage:(BOOL)autoPage {
    _autoPage = autoPage;
    NSDate *fireDate = autoPage ? [NSDate dateWithTimeIntervalSinceNow:ScrollInterval] : [NSDate distantFuture];
    self.timer.fireDate = fireDate;
}

#pragma mark - 轮播方法
//自动显示下一个
- (void)showNext {
    //手指拖拽是禁止自动轮播
    if (self.scrollView.isDragging) {return;}
    
    int index = self.scrollView.contentOffset.x/self.scrollView.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake((index+1)*self.scrollView.bounds.size.width, 0) animated:YES];
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end
