//
//  EditSeletedPhotoView.h
//  CustomPublickKeyboard
//
//  Created by 吴启凡 on 16/1/15.
//  Copyright © 2016年 可行星. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditSeletedPhotoViewDelegate <NSObject>

- (void)addPhotoAction:(NSMutableArray *)array;
- (void)updatePhotoNum:(NSUInteger)photoNum;

@end

@interface EditSeletedPhotoView : UIView

- (instancetype)initWithFrame:(CGRect)frame withImageArray:(NSMutableArray *)imageArray;
@property (nonatomic,assign) id<EditSeletedPhotoViewDelegate>       delegate;
@property (nonatomic,strong) NSMutableArray                          *photoArray;

@end
