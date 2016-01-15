//
//  PhotoCollectionViewCell.m
//  CustomPublickKeyboard
//
//  Created by 吴启凡 on 16/1/15.
//  Copyright © 2016年 可行星. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "UIViewExt.h"

@implementation PhotoCollectionViewCell
{
    UIImageView         *_imageView;
    CALayer             *_backLayer;
    UIImageView         *_selectImage;
    UILabel             *_label;
}

@synthesize thumbImage;
@synthesize bSelected =_bSelected;

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initContentView];
    }
    return self;
}

- (void)initContentView{
    
    _backLayer = [CALayer layer];
    _backLayer.frame = CGRectMake(-1, -1, self.width+2, self.height+2);
    [self.layer addSublayer:_backLayer];
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,self.width,self.height)];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_imageView];
    
    _selectImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.width - 30, 5, 24, 24)];
    _selectImage.image = [UIImage imageNamed:@"publicunselect.png"];
    [self addSubview:_selectImage];
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width, 20)];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"拍摄照片";
    _label.font = [UIFont systemFontOfSize:13];
    _label.textColor = [UIColor blueColor];
    [self addSubview:_label];
    _label.hidden =  YES;
    
}

-(void)setThumbImage:(UIImage *)_thumbImage{
    
    thumbImage = _thumbImage;
    _imageView.image = thumbImage;
    _imageView.frame = CGRectMake(0,0,self.width,self.height);//防止第一个cell重用导致变小
    _label.hidden = YES;
}

- (void)setBackColor:(UIColor *)color{
    
    //_backLayer.backgroundColor = color.CGColor;
}

-(void)setFirstThumb:(BOOL)firstThumb{
    
    _imageView.image = [UIImage imageNamed:@"publiccamera.png"];
    _imageView.frame = CGRectMake(0, 0, 36, 30) ;
    _imageView.center = CGPointMake(CGRectGetMidX(self.bounds), 40);
    _label.top = _imageView.bottom  + 8;
    _selectImage.hidden = YES;
    _label.hidden = NO;
    self.backgroundColor = [UIColor lightGrayColor];
}

-(void)setBSelected:(BOOL)bSelected{
    
    if(bSelected)
        _selectImage.image = [UIImage imageNamed:@"publicselect.png"];
    else
        _selectImage.image = [UIImage imageNamed:@"publicunselect.png"];
    
    _bSelected = bSelected;
}

-(void)dealloc{
    
}

@end
