//
//  SelectedPhotoViewController.h
//  CustomPublickKeyboard
//
//  Created by 吴启凡 on 16/1/15.
//  Copyright © 2016年 可行星. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SetFinishBlock)(NSMutableArray   *imageArray);
@interface SelectedPhotoViewController : UIViewController

@property (nonatomic,strong) NSMutableArray            *assetArray;
@property (nonatomic,copy)   SetFinishBlock            block;

@end
