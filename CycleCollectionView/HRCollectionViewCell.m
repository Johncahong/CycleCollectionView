//
//  HRCollectionViewCell.m
//  CycleCollectionView
//
//  Created by Hello Cai on 2021/9/21.
//

#import "HRCollectionViewCell.h"

@interface HRCollectionViewCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation HRCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.imageView];
}

-(void)setImageName:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    self.imageView.image = image;
}
@end
