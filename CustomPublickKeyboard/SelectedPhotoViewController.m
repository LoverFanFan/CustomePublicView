//
//  SelectedPhotoViewController.m
//  CustomPublickKeyboard
//
//  Created by 吴启凡 on 16/1/15.
//  Copyright © 2016年 可行星. All rights reserved.
//

#import "SelectedPhotoViewController.h"
#import "UIViewExt.h"
#import "PhotoCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define    SELECTCELLHEIGHT                 49
#define    SCROLL_CELL_WIDTH                49

static CGSize AssetGridThumbnailSize;

static ALAssetsLibrary                     *_assetsLibrary;

@interface SelectedPhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    UICollectionView                    *_flowCollectionView;
    NSMutableArray                      *_assetCache;
    UIScrollView                        *_imagesScrollView;
    NSMutableArray                      *_stichImages;
    NSMutableArray                      *_selectedArray;
    BOOL                                _inScan;
    UIButton                            *_btn;
    UIView                              *_bottomView;
}

@end

@implementation SelectedPhotoViewController
@synthesize assetArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [ALAssetsLibrary disableSharedPhotoStreamsSupport];
     self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initData];
    [self initNav];
    [self initCollectionView];
    [self scanCameraRoll];
    
    
    
    
    // Do any additional setup after loading the view.
}

- (void)initData{
    
    _stichImages = [NSMutableArray array];
    _assetCache  = [NSMutableArray array];
    
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    if(assetArray)
        _selectedArray = [NSMutableArray arrayWithArray:assetArray];
    else
        _selectedArray = [NSMutableArray array];
    
}

- (void)initNav{
    
    UIView *nav = [[UIView alloc]initWithFrame:CGRectMake(0, 0,ScreenWidth , 64)];
    nav.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:nav];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 12, 20)];
    imageView.image = [UIImage imageNamed:@"profile_back"];
    imageView.centerY = 44;
    [nav addSubview:imageView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, 0, 60, 40);
    backButton.centerY = 44;
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [nav addSubview:backButton];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    titleLab.text = @"相机胶卷";
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.centerY = 44;
    titleLab.centerX = ScreenWidth/2;
    [nav addSubview:titleLab];
    
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(ScreenWidth - 60 - 10, 0, 60, 40);
    finishBtn.centerY = 44;
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    [nav addSubview:finishBtn];
    
}

- (void)initCollectionView{
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//布局方向
    flowLayout.minimumInteritemSpacing = 1;
    flowLayout.minimumLineSpacing = 3;
    
    _flowCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64- SELECTCELLHEIGHT - 0.5)
                                            collectionViewLayout:flowLayout];
    
    _flowCollectionView.backgroundColor = [UIColor whiteColor];
    _flowCollectionView.delegate   = self;
    _flowCollectionView.dataSource = self;
    _flowCollectionView.clipsToBounds = YES;
    [_flowCollectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCollectionViewCell"];
    [self.view addSubview:_flowCollectionView];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize   cellSize = ((UICollectionViewFlowLayout *)flowLayout).itemSize;
    
    AssetGridThumbnailSize = CGSizeMake(cellSize.width*scale, cellSize.height * scale);
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0,ScreenHeight - SELECTCELLHEIGHT - 0.5, ScreenWidth, SELECTCELLHEIGHT+0.5)];
    _bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bottomView];
    
    UIView   *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor blueColor];
    [_bottomView addSubview:lineView];
    
    _imagesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10,0.5, ScreenWidth - 10 - 122, SELECTCELLHEIGHT)];
    
    _imagesScrollView.scrollEnabled = YES;
    [_imagesScrollView setShowsHorizontalScrollIndicator:NO];
    _imagesScrollView.backgroundColor = [UIColor clearColor];
    [_bottomView addSubview:_imagesScrollView];
    
    _btn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 112, -20, 102, 32)];
    _btn.center = CGPointMake(_btn.center.x, _imagesScrollView.center.y);
    _btn.layer.cornerRadius = 5.0;
    _btn.layer.masksToBounds = YES;
    _btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_btn setTitle:@"已选(0/10)" forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    _btn.backgroundColor = [UIColor orangeColor];
    [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_bottomView addSubview:_btn];
    
    
}

-(void)photoAction{
    
    [self getPhotoFromPicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)scanCameraRoll{  //获取全部图片
    
    _inScan = true;
    
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ( group != nil ){
            
            NSString   *albumName = [group valueForProperty:ALAssetsGroupPropertyName];
            NSLog(@"%@",albumName);
            
            NSNumber   *typeName = [group valueForProperty:ALAssetsGroupPropertyType];
            NSLog(@"%@",typeName);
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [_assetCache removeAllObjects];
            
            //cache all assets
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                _inScan = true;
                if ( result )
                    [_assetCache addObject:result];
                else{
                    
                    _inScan = false;
                    
                    [_flowCollectionView reloadData];
                }
            }];
            
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
}


-(void)getPhotoFromPicker:(UIImagePickerControllerSourceType)type{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate      = self;
    picker.sourceType    = type;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _assetCache.count+1;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString *identifier = @"PhotoCollectionViewCell";
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                              forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.thumbImage = [UIImage imageNamed:@""];
        cell.firstThumb = YES;
        [cell setBackColor:[UIColor grayColor]];
        return cell;
    }
    
    ALAsset *asset = (ALAsset *)[_assetCache objectAtIndex:indexPath.row - 1];
    BOOL       bSelected = [self isSelectedFile:asset];
    cell.thumbImage = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    cell.bSelected = bSelected;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((ScreenWidth - 3 - 3*4)/3, (ScreenWidth - 3 - 3*4)/3);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(3,3,3,3);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {//第一个拍照
        if (_stichImages.count >= 10) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"图片最多10张" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:okAction];
            return;
        }
        [self getPhotoFromPicker:UIImagePickerControllerSourceTypeCamera];
        return;
    }
    
    ALAsset *asset = (ALAsset *)[_assetCache objectAtIndex:indexPath.row - 1];
    UIImage *image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    NSURL *fileURL = [representation url];
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell && !cell.bSelected && _stichImages.count >= 10) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"图片最多10张" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:okAction];
        return;
    }
    else if (cell.bSelected){
        cell.bSelected = NO;
        [_selectedArray removeObject:asset];
    }
    else{
        cell.bSelected = YES;
        [_selectedArray addObject:asset];
    }
    
    [_btn setTitle:[NSString stringWithFormat:@"完成(%ld/10)",(unsigned long)[_selectedArray count]] forState:UIControlStateNormal];
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}


#pragma mark- ImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString    *assetPath = [info objectForKey:UIImagePickerControllerReferenceURL];
    UIImage     *imagesrc = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if(assetPath){
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
                 resultBlock:^(ALAsset *asset)
         {
             ALAssetRepresentation *representation = [asset defaultRepresentation];
             CGImageRef imgRef = [representation fullResolutionImage];
             UIImage *image1 = [UIImage imageWithCGImage:imgRef
                                                   scale:representation.scale
                                             orientation:(UIImageOrientation)representation.orientation];
             
             _imagesScrollView.contentSize = CGSizeMake([_stichImages count] * SCROLL_CELL_WIDTH < _imagesScrollView.right ? _imagesScrollView.right : [_stichImages count] * SCROLL_CELL_WIDTH, SCROLL_CELL_WIDTH);
         }
                failureBlock:^(NSError *error){
                    
                    return;
                }
         ];
    }
    else if(imagesrc){
        
        
    }
    
    [_btn setTitle:[NSString stringWithFormat:@"完成(%ld/10)",(unsigned long)[_stichImages count]] forState:UIControlStateNormal];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)backAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.block)
        self.block(nil);
}

- (void)finishAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.block)
        self.block(_selectedArray);
}



-(BOOL)isSelectedFile:(ALAsset *)asset{
    
    BOOL   br = NO;
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    NSURL   *fileurl = [representation url];
    
    NSUInteger    index = 0;
    for(index = 0; index < [_selectedArray count]; index++){
        
        if([[_selectedArray objectAtIndex:index]isKindOfClass:[ALAsset class]]){
            
            ALAsset   *each = [_selectedArray objectAtIndex:index];
            ALAssetRepresentation* eachrepresentation = [each defaultRepresentation];
            NSURL   *eachfileurl = [eachrepresentation url];
            if([fileurl isEqual:eachfileurl]){
                br = YES;
                break;
            }
        }
    }
    return br;
}

- (void)dealloc{
    
    NSLog(@"go 带");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
