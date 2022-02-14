//
//  HRCycleView.m
//  CycleCollectionView
//
//  Created by Hello Cai on 2021/9/21.
// 当轮播图只有一张图片时，cell只创建一个。当轮播图两张及两张以上时，cell创建3个，图片在这3个cell之间复用

#import "HRCycleView.h"
#import "HRCollectionViewCell.h"

//轮播间隔
static CGFloat ScrollInterval = 3.0f;

@interface HRCycleView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSIndexPath *nextIndexPath;

@end

@implementation HRCycleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _autoPage = YES;
        [self buildUI];
    }
    return self;
}

static NSString *cellID = @"HRCollectionViewCell";
- (void)buildUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = true;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[HRCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    self.collectionView.showsHorizontalScrollIndicator = false;
    [self addSubview:self.collectionView];
    
    CGFloat controlHeight = 35.0f;
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - controlHeight, self.bounds.size.width, controlHeight)];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    [self addSubview:self.pageControl];
}

#pragma mark - CollectionViewDelegate&DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HRCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.imageName = self.dataArray[indexPath.row];
    NSLog(@"offset.x:%.1f, cell地址:%p", collectionView.contentOffset.x, cell);
    return cell;
}

//cell刚移入屏幕时回调，indexPath对应刚移入屏幕的cell下标
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    self.nextIndexPath = indexPath;
}

//cell完全移出屏幕时回调，indexPath对应完全移出屏幕的cell下标
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.nextIndexPath != indexPath) {
        [self adjustScrollLocation];
    }
}

#pragma mark - UIScrollViewDelegate
//将要开始拖拽时调用
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"scrollViewWillBeginDragging---");
    //停止定时器
    [self.timer setFireDate:[NSDate distantFuture]];
}

//松开拖拽时调用。松开时，scrollView如果还能惯性移动，decelerate则为1。如果停止滚动了，decelerate则为0
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //间隔3s继续轮播
    if (_autoPage) {
        self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:ScrollInterval];
    }
}

//调整循环显示的定位
- (void)adjustScrollLocation {
    NSInteger page = self.collectionView.contentOffset.x/self.collectionView.bounds.size.width;
    if (page == 0) {//滚动到最左边
        self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width * (self.dataArray.count - 2), 0);
        self.pageControl.currentPage = self.dataArray.count-3;
    }else if (page == self.dataArray.count - 1){//滚动到最右边
        self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width, 0);
        self.pageControl.currentPage = 0;
    }else{
        self.pageControl.currentPage = page - 1;
    }
}


#pragma mark - Setter
//设置数据时在第一个之前和最后一个之后分别插入数据
- (void)setData:(NSArray<NSString *> *)data {
    self.dataArray = [NSMutableArray arrayWithArray:data];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    if (data.count > 1) {
        [self.dataArray addObject:data.firstObject];
        [self.dataArray insertObject:data.lastObject atIndex:0];
        [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width, 0)];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:ScrollInterval target:self selector:@selector(showNext) userInfo:nil repeats:true];
        if(_autoPage == NO) {
            self.timer.fireDate = [NSDate distantFuture];
        }
    }
    self.pageControl.numberOfPages = data.count<=1 ? 0 : data.count;
    self.pageControl.currentPage = 0;
    [self.collectionView reloadData];
}

- (void)setAutoPage:(BOOL)autoPage {
    _autoPage = autoPage;
    NSDate *fireDate = autoPage ? [NSDate dateWithTimeIntervalSinceNow:ScrollInterval] : [NSDate distantFuture];
    self.timer.fireDate = fireDate;
}

//自动显示下一个
- (void)showNext {
    //手指拖拽是禁止自动轮播
    if (self.collectionView.isDragging) {return;}
//    CGFloat targetX =  self.collectionView.contentOffset.x + self.collectionView.bounds.size.width;
//    [self.collectionView setContentOffset:CGPointMake(targetX, 0) animated:true];
    
    int index = self.collectionView.contentOffset.x/self.collectionView.frame.size.width;
    [self.collectionView setContentOffset:CGPointMake((index+1)*self.collectionView.bounds.size.width, 0) animated:YES];
}


- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end
