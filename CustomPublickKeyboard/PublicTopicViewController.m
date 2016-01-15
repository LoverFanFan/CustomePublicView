//
//  PublicTopicViewController.m
//  CustomPublickKeyboard
//
//  Created by 吴启凡 on 16/1/14.
//  Copyright © 2016年 可行星. All rights reserved.
//

#import "PublicTopicViewController.h"
#import "SelectedPhotoViewController.h"


#import "PublicTopicViewController.h"
#import "UIViewExt.h"

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define kToolbarHeight (26 + 46)


@interface PublicTopicViewController ()<UITextFieldDelegate,UITextViewDelegate>
{
    UITextField       *_titleTF;
    UITextView        *_textView;
    UIView            *_toolbar;
    UIButton          *_toolbarPictureButton;
    UIButton          *_toolbarEmoticonButton;
    UIButton          *_toolbarvideoButton;
    UIButton          *_toolbarmoreButton;
    UIButton          *_toolbarvoiceButton;
    NSMutableArray    *_imageArray;
    NSString          *_pcmFilePath;//音频文件路径
    
    NSMutableArray    *_imagePublicArray;
    NSInteger         _videoPublicFinish;
    NSURL             *_videoURL;
    NSString          *_qiniuVideoPath;
    NSMutableArray    *_imagePathArray;
    UILabel           *_redlabel;
    
    NSString          *_category;
    
    UIView            *_backView;
    UIView            *_whiteView;
    
    UIButton          *_tempBtn;
    NSString          *_videothumbPath;
    NSUInteger        _photoError;
}

@end

@implementation PublicTopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initData];
    [self createTextFeildAndTextView];
    [self createToolBar];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initData{
    
    _imageArray = [[NSMutableArray alloc]init];
    _imagePublicArray = [[NSMutableArray alloc]init];
    _imagePathArray = [[NSMutableArray alloc]init];
    _videoPublicFinish = -1;
    _photoError = 0;
    
}

- (void)initNotice{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)createTextFeildAndTextView{
    
    _titleTF = [[UITextField alloc]initWithFrame:CGRectMake(15, 64 + 15, ScreenWidth - 30, 20)];
    _titleTF.placeholder   = @"标题";
    _titleTF.borderStyle   = UITextBorderStyleNone;
    _titleTF.delegate      = self;
    _titleTF.font = [UIFont boldSystemFontOfSize:16];
    _titleTF.backgroundColor = [UIColor whiteColor];
    [_titleTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_titleTF];
    
    UILabel *lineLab = [[UILabel alloc]initWithFrame:CGRectMake(0, _titleTF.bottom + 15, ScreenWidth, 0.5)];
    lineLab.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineLab];
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(15, lineLab.bottom, ScreenWidth-20, ScreenHeight-64-lineLab.bottom)];
    _textView.textContainerInset = UIEdgeInsetsMake(10, 0, 12, 16);
    _textView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarHeight, 0);
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textView.showsVerticalScrollIndicator = NO;
    _textView.alwaysBounceVertical         = YES;
    _textView.font       = [UIFont systemFontOfSize:17];
    _textView.delegate   = self;
    [self.view addSubview:_textView];
}

- (void)createToolBar{
    
    _toolbar                  = [[UIView alloc]initWithFrame:CGRectMake(-1, 0, ScreenWidth + 2, 46)];
    _toolbar.backgroundColor  = [UIColor redColor];
    _toolbar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _toolbar.layer.borderWidth = 0.5;
    _toolbar.bottom = ScreenHeight;
    
    
    _toolbarPictureButton  = [self _toolbarButtonWithImage:@"publicphoto"];
    _redlabel = [[UILabel alloc]initWithFrame:CGRectMake(_toolbarPictureButton.width/2.0 + 23/2.0 - 7.5, _toolbarPictureButton.height/2.0 - 23/2.0-7.5, 15, 15)];
    _redlabel.backgroundColor = [UIColor redColor];
    _redlabel.textAlignment = NSTextAlignmentCenter;
    _redlabel.clipsToBounds = YES;
    _redlabel.font = [UIFont systemFontOfSize:14];
    _redlabel.textColor = [UIColor whiteColor];
    _redlabel.layer.cornerRadius = _redlabel.width/2.0;
    _redlabel.hidden = YES;
    [_toolbarPictureButton addSubview:_redlabel];
    
    _toolbarEmoticonButton = [self _toolbarButtonWithImage:@"publicemoji.png"];
    _toolbarvideoButton    = [self _toolbarButtonWithImage:@"publicvideo"];
    _toolbarmoreButton     = [self _toolbarButtonWithImage:@"publiccategory"];
    _toolbarvoiceButton    = [self _toolbarButtonWithImage:@"publicaudio"];
    
    CGFloat one = _toolbar.width / 5.0;
    _toolbarPictureButton.center  = CGPointMake(one * 0.5,CGRectGetMidY(_toolbar.bounds));
    _toolbarEmoticonButton.center = CGPointMake(one * 1.5,CGRectGetMidY(_toolbar.bounds));
    _toolbarvideoButton.center    = CGPointMake(one * 2.5,CGRectGetMidY(_toolbar.bounds));
    _toolbarmoreButton.center     = CGPointMake(one * 3.5,CGRectGetMidY(_toolbar.bounds));
    _toolbarvoiceButton.center    = CGPointMake(one * 4.5,CGRectGetMidY(_toolbar.bounds));
    
    
    
    _toolbar.bottom                = self.view.height;
    [self.view addSubview:_toolbar];
}

- (UIButton *)_toolbarButtonWithImage:(NSString *)imageName {
    
    NSUInteger    btnWidth = _toolbar.width/5.0;
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, _toolbar.height)];
    button.exclusiveTouch = YES;
    [button setBackgroundColor:[UIColor clearColor]];
    [_toolbar addSubview:button];
    
    UIImageView  *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
    imageView.image = [UIImage imageNamed:imageName];
    imageView.center = CGPointMake(CGRectGetMidX(button.bounds), CGRectGetMidY(button.bounds));
    [button addSubview:imageView];
    
    [button addTarget:self action:@selector(_buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - Action

- (void)_buttonClicked:(UIButton *)button {
    
    _tempBtn = button;
    if(button != _toolbarEmoticonButton){
        
        if([_textView isFirstResponder])
            [_textView resignFirstResponder];
        
        if([_titleTF isFirstResponder])
            [_titleTF resignFirstResponder];
    }
    //图片按钮
    if (button == _toolbarPictureButton) {
        
        SelectedPhotoViewController *selectPhotoVC = [[SelectedPhotoViewController alloc]init];
        [selectPhotoVC setBlock:^(NSMutableArray *imageArray){
            
            if (imageArray) {
                
                
            }
            
        }];
        [self.navigationController presentViewController:selectPhotoVC animated:YES completion:nil];
        
    }
    else if (button == _toolbarEmoticonButton) {//表情
        
    }
    else if (button == _toolbarvideoButton){ //视频
        
          }
    else if (button == _toolbarmoreButton){ // 分类
       
    }
    else{                                   // 音频
      
    }
}


#pragma mark - NSNotification

- (void)keyboardWillShow:(NSNotification *)notice{
    
    //获取键盘的高度
    NSDictionary *userInfo = [notice userInfo];
    NSValue      *aValue   = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect       keyboardRect    = [aValue CGRectValue];
    CGFloat      _keyHeight     = keyboardRect.size.height;
    
    _toolbar.bottom = ScreenHeight - _keyHeight;
    
    if([_titleTF isFirstResponder])
        _toolbarvoiceButton.enabled = NO;
    else if([_textView isFirstResponder])
        _toolbarvoiceButton.enabled = YES;
    
}

- (void)keyboardWillHidden:(NSNotification *)notice{
    
    _toolbar.bottom = ScreenHeight;
    
    if([_titleTF isFirstResponder])
        _toolbarvoiceButton.enabled = NO;
    if([_textView isFirstResponder])
        _toolbarvoiceButton.enabled = YES;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
