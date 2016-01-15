//
//  SelectedPhotoView.m
//  CustomPublickKeyboard
//
//  Created by 吴启凡 on 16/1/15.
//  Copyright © 2016年 可行星. All rights reserved.
//

#import "SelectedPhotoView.h"
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@implementation SelectedPhotoView
{
    UIScrollView     *_scrollView;
    NSMutableArray   *_photoArray;
}

- (id)initWithFrame:(CGRect)frame AndImageArray:(NSMutableArray *)imageArray{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _photoArray = imageArray;
        
    }
    return self;
}


- (void)configUI{
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 135)];
    [self addSubview:_scrollView];
    
    
    
    
}

@end
