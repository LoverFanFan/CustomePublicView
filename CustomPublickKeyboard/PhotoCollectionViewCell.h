//
//  PhotoCollectionViewCell.h
//  CustomPublickKeyboard
//
//  Created by 吴启凡 on 16/1/15.
//  Copyright © 2016年 可行星. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong)    UIImage         *thumbImage;
@property (nonatomic,assign)    BOOL            firstThumb;
@property (nonatomic,assign)    BOOL            bSelected;

- (void)setBackColor:(UIColor *)color;

@end
