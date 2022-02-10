//
//  HRCycleView.h
//  CycleCollectionView
//
//  Created by Hello Cai on 2021/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HRCycleView : UIView

@property (nonatomic, strong) NSArray<NSString *> *data;

/**
 自动翻页 默认 YES
 */
@property (nonatomic, assign) BOOL autoPage;

@end

NS_ASSUME_NONNULL_END
