//
//  EditSeletedPhotoView.m
//  CustomPublickKeyboard
//
//  Created by 吴启凡 on 16/1/15.
//  Copyright © 2016年 可行星. All rights reserved.
//

#import "EditSeletedPhotoView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIViewExt.h"

#define kDuration  0.2
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@implementation EditSeletedPhotoView
{
    BOOL             _contain;
    CGPoint          _startPoint;
    CGPoint          _originPoint;
    UIScrollView     *_scrollView;
    NSMutableArray   *_itemArray;
    NSInteger        _btnIndex;
    UIButton         *_addPhotoBtn;
    UILabel          *_label1;
    UIView           *_borderView;
}
@synthesize delegate;
@synthesize photoArray;

- (instancetype)initWithFrame:(CGRect)frame withImageArray:(NSMutableArray *)imageArray {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        photoArray   = [NSMutableArray arrayWithArray:imageArray];
        
        _itemArray       = [NSMutableArray array];
        
        [self createScrollView];
        
    }
    
    return self;
}

- (void)createScrollView{
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 10, ScreenWidth, 135)];
    _scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:_scrollView];
    
    for (NSInteger i = 0; i<photoArray.count; i++) {
        
        UIImage    *image;
        
        if([[photoArray objectAtIndex:i] isKindOfClass:[UIImage class]]){
            
            image = [photoArray objectAtIndex:i];
        }
        else{
            ALAsset    *asset = photoArray[i];
            image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        }
        
        UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        itemBtn.frame     = CGRectMake(10+(100*i), 0, 90, 130);
        itemBtn.backgroundColor = [UIColor clearColor];
        itemBtn.tag       = i;
        [_scrollView addSubview:itemBtn];
        
        UIImageView   *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 80, 120)];
        imageView.tag = 100;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = image;
        [itemBtn addSubview:imageView];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame    = CGRectMake(CGRectGetWidth(itemBtn.bounds) - 22, 0, 22, 22);
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"publiccancel.png"] forState:UIControlStateNormal];
        deleteBtn.tag             = 10;
        [deleteBtn addTarget:self action:@selector(deletePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        [itemBtn addSubview:deleteBtn];
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
        [itemBtn addGestureRecognizer:longGesture];
        
        [_itemArray addObject:itemBtn];
    }
    
    _scrollView.contentSize = CGSizeMake(10+100*photoArray.count+10, _scrollView.height);
    if([photoArray count] < 10){
        
        _addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addPhotoBtn.bounds    = CGRectMake(0, 0, 90, 118);
        _addPhotoBtn.left      = 10+(100*(photoArray.count));
        _addPhotoBtn.top       = 10;
        _addPhotoBtn.backgroundColor = [UIColor clearColor];
        [_addPhotoBtn addTarget:self action:@selector(addPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView   *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
        imageview.image = [UIImage imageNamed:@"add.png"];
        imageview.center = CGPointMake(_addPhotoBtn.width/2.0, _addPhotoBtn.height/2.0);
        
        _borderView = [[UIView alloc]initWithFrame:_addPhotoBtn.frame];
        _borderView.layer.borderColor = [UIColor orangeColor].CGColor;
        _borderView.layer.borderWidth = 0.5;
        [_scrollView addSubview:_borderView];
        [_borderView addSubview:imageview];
        
        [_scrollView addSubview:_addPhotoBtn];
        _scrollView.contentSize = CGSizeMake(10+100*(photoArray.count+1)+10, _scrollView.height);
        
    }
    
    if(_scrollView.contentSize.width > ScreenWidth){
        UIButton   *lastBtn = [_itemArray objectAtIndex:[_itemArray count] - 3];
        [_scrollView setContentOffset:CGPointMake(lastBtn.left, 0)];
        
    }else
        [_scrollView setContentOffset:CGPointMake(0, 0)];
    
    _label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, _scrollView.bottom + 5, 200, 20)];
    _label1.text = [NSString stringWithFormat:@"%lu/10",(unsigned long)[photoArray count]];
    _label1.font = [UIFont systemFontOfSize:13];
    _label1.textAlignment = NSTextAlignmentCenter;
    _label1.textColor = [UIColor blackColor];
    _label1.center = CGPointMake(CGRectGetMidX(self.bounds), _label1.center.y);
    [self addSubview:_label1];
    
    UILabel   *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    label.top = _label1.bottom + 5;
    label.center = CGPointMake(CGRectGetMidX(self.bounds), label.center.y);
    label.text = @"长按可拖动交换位置";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor blackColor];
    [self addSubview:label];
    
}

- (void)buttonLongPressed:(UILongPressGestureRecognizer *)sender{
    
    UIButton *btn = (UIButton *)sender.view;
    
    NSUInteger  imageindex = [_itemArray indexOfObject:btn];
    ALAsset     *asset = [photoArray objectAtIndex:imageindex];
    
    
    if (sender.state == UIGestureRecognizerStateBegan){
        
        _startPoint  = [sender locationInView:sender.view];
        _originPoint = btn.center;
        _btnIndex = 0;
        [UIView animateWithDuration:kDuration animations:^{
            
            btn.transform = CGAffineTransformMakeScale(1.1, 1.1);
            btn.alpha     = 0.7;
        }];
        
    }
    else if (sender.state == UIGestureRecognizerStateChanged){
        
        CGPoint newPoint = [sender locationInView:sender.view];
        CGFloat deltaX   = newPoint.x-_startPoint.x;
        CGFloat deltaY   = newPoint.y-_startPoint.y;
        btn.center       = CGPointMake(btn.center.x+deltaX,btn.center.y+deltaY);
        
        NSInteger index = [self indexOfPoint:btn.center withButton:btn];
        _btnIndex = index;
        if (index<0){
            
            _contain = NO;
        }
        else{
            
            [UIView animateWithDuration:kDuration animations:^{
                
                CGPoint temp     = CGPointZero;
                UIButton *button = _itemArray[index];
                temp             = button.center;
                button.center    = _originPoint;
                btn.center       = temp;
                _originPoint      = btn.center;
                _contain          = YES;
                
                [_itemArray removeObject:btn];
                [_itemArray insertObject:btn atIndex:_btnIndex];
                
                [photoArray removeObjectAtIndex:imageindex];
                [photoArray insertObject:asset atIndex:_btnIndex];
                
            }];
        }
        
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded){
        
        [UIView animateWithDuration:kDuration animations:^{
            
            btn.transform = CGAffineTransformIdentity;
            btn.alpha     = 1.0;
            if (!_contain){
                
                btn.center = _originPoint;
                
                if(_btnIndex > 0){
                    
                    [_itemArray removeObject:btn];
                    [_itemArray insertObject:btn atIndex:_btnIndex];
                    
                    [photoArray removeObjectAtIndex:imageindex];
                    [photoArray insertObject:asset atIndex:_btnIndex];
                    
                }
            }
            
            NSUInteger  newTag = 0;
            for(UIButton *testBtn in _itemArray){
                
                testBtn.tag = newTag;
                newTag++;
            }
            for(UIButton *testBtn in _itemArray){
                
                NSLog(@"Btn tag = %ld",(long)testBtn.tag);
            }
        }];
    }
}


- (NSInteger)indexOfPoint:(CGPoint)point withButton:(UIButton *)btn{
    
    for (NSInteger i = 0;i<_itemArray.count;i++){
        
        UIButton *button = _itemArray[i];
        if (button != btn){
            
            if (CGRectContainsPoint(button.frame, point)){
                
                return i;
            }
        }
    }
    return -1;
}

#pragma mark - 删除图片
- (void)deletePhotoAction:(UIButton *)sender{
    
    UIButton    *deleteBtn = (UIButton *)sender;
    UIButton    *itemBtn = (UIButton *)deleteBtn.superview;
    
    NSUInteger  index = [_itemArray indexOfObject:itemBtn];
    __block CGRect newFrame;
    
    for (NSInteger i = index; i< _itemArray.count; i++) {
        
        UIButton *button = [_itemArray objectAtIndex:i];
        CGRect nextFrame = button.frame;
        if (i == index) {
            [button removeFromSuperview];
        }
        else{
            for (UIButton *btn in _itemArray) {
                btn.tag = i-1;
                break;
            }
            [UIView animateWithDuration:0.6 animations:^{
                //button.frame = newFrame;
                button.center = CGPointMake(button.center.x - 100, button.center.y);
            }];
        }
        newFrame = nextFrame;
        
    }
    
    [_itemArray removeObjectAtIndex:index];
    [photoArray removeObjectAtIndex:index];
    
    _scrollView.contentSize = CGSizeMake(10+100*photoArray.count+10, _scrollView.height);
    if([photoArray count] < 10 && !_addPhotoBtn){
        
        _addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addPhotoBtn.bounds    = CGRectMake(0, 0, 90, 118);
        _addPhotoBtn.left      = 10+(100*(photoArray.count));
        _addPhotoBtn.top       = 10;
        _addPhotoBtn.backgroundColor = [UIColor clearColor];
        [_addPhotoBtn addTarget:self action:@selector(addPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView   *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
        imageview.image = [UIImage imageNamed:@"add.png"];
        imageview.center = CGPointMake(_addPhotoBtn.width/2.0, _addPhotoBtn.height/2.0);
        
        _borderView = [[UIView alloc]initWithFrame:_addPhotoBtn.frame];
        _borderView.layer.borderColor = [UIColor orangeColor].CGColor;
        _borderView.layer.borderWidth = 0.5;
        [_scrollView addSubview:_borderView];
        [_borderView addSubview:imageview];
        [_borderView addSubview:imageview];
        
        [_scrollView addSubview:_addPhotoBtn];
        _scrollView.contentSize = CGSizeMake(10+100*(photoArray.count+1)+10, _scrollView.height);
    }
    else if(_addPhotoBtn){
        
        _addPhotoBtn.bounds    = CGRectMake(0, 0, 90, 118);
        _addPhotoBtn.left      = 10+(100*(photoArray.count));
        _addPhotoBtn.top       = 10;
        
        _borderView.frame = _addPhotoBtn.frame;
        
    }
    
    if(_addPhotoBtn)
        _scrollView.contentSize = CGSizeMake(10+100*(photoArray.count + 1)+10, _scrollView.height);
    
    _label1.text = [NSString stringWithFormat:@"%lu/10",(unsigned long)[photoArray count]];
    if(self.delegate)
        [self.delegate updatePhotoNum:[photoArray count]];
    
}

#pragma mark - 添加图片
- (void)addPhotoAction:(UIButton *)sender{
    
    if(self.delegate)
        [self.delegate addPhotoAction:photoArray];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
