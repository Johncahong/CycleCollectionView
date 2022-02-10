//
//  HRScrollCycleView.h
//  CycleCollectionView
//
//  Created by Hello Cai on 2022/2/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HRScrollCycleView : UIView

@property (nonatomic, strong) NSArray<NSString *> *data;
/**
 自动翻页 默认 YES
 */
@property (nonatomic, assign) BOOL autoPage;
@end

NS_ASSUME_NONNULL_END
