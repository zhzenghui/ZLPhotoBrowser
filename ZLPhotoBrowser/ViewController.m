//
//  ViewController.m
//  ZLPhotoBrowser
//
//  Created by long on 15/12/1.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ViewController.h"
#import "ZLPhotoActionSheet.h"
#import "ZLShowBigImage.h"
#import "ZLDefine.h"
#import "ImageCell.h"
#import "YYFPSLabel.h"
#import <Photos/Photos.h>
#import "ZLShowGifViewController.h"
#import "ZLShowVideoViewController.h"
#import "ZLPhotoModel.h"
#import "ZLShowLivePhotoViewController.h"

///////////////////////////////////////////////////
// git 地址： https://github.com/longitachi/ZLPhotoBrowser
// 喜欢的朋友请去给个star，谢谢
///////////////////////////////////////////////////
@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegment;
@property (weak, nonatomic) IBOutlet UISwitch *selImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *selGifSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *selVideoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *takePhotoInLibrarySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *rememberLastSelSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showCaptureImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *selLivePhotoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *allowForceTouchSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *allowEditSwitch;
@property (weak, nonatomic) IBOutlet UITextField *previewTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxSelCountTextField;
@property (weak, nonatomic) IBOutlet UITextField *cornerRadioTextField;

@property (nonatomic, strong) NSMutableArray<UIImage *> *lastSelectPhotos;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *lastSelectAssets;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *arrDataSources;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    YYFPSLabel *label = [[YYFPSLabel alloc] initWithFrame:CGRectMake(kViewWidth - 100, 30, 100, 30)];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [self initCollectionView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)initCollectionView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((width-9)/4, (width-9)/4);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:NSClassFromString(@"ImageCell") forCellWithReuseIdentifier:@"ImageCell"];
}

- (ZLPhotoActionSheet *)getPas
{
    ZLPhotoActionSheet *actionSheet = [[ZLPhotoActionSheet alloc] init];
    
#pragma optional
    //以下参数为自定义参数，均可不设置，有默认值
    actionSheet.sortAscending = self.sortSegment.selectedSegmentIndex==0;
    actionSheet.allowSelectImage = self.selImageSwitch.isOn;
    actionSheet.allowSelectGif = self.selGifSwitch.isOn;
    actionSheet.allowSelectVideo = self.selVideoSwitch.isOn;
    actionSheet.allowSelectLivePhoto = self.selLivePhotoSwitch.isOn;
    actionSheet.allowForceTouch = self.allowForceTouchSwitch.isOn;
    actionSheet.allowEditImage = self.allowEditSwitch.isOn;
    //设置相册内部显示拍照按钮
    actionSheet.allowTakePhotoInLibrary = self.takePhotoInLibrarySwitch.isOn;
    //设置在内部拍照按钮上实时显示相机俘获画面
    actionSheet.showCaptureImageOnTakePhotoBtn = self.showCaptureImageSwitch.isOn;
    //设置照片最大预览数
    actionSheet.maxPreviewCount = self.previewTextField.text.integerValue;
    //设置照片最大选择数
    actionSheet.maxSelectCount = self.maxSelCountTextField.text.integerValue;
    //设置照片cell弧度
    actionSheet.cellCornerRadio = self.cornerRadioTextField.text.floatValue;
    //单选模式是否显示选择按钮
    actionSheet.showSelectBtn = NO;
    
#pragma required
    //如果调用的方法没有传sender，则该属性必须提前赋值
    actionSheet.sender = self;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (PHAsset *asset in self.lastSelectAssets) {
//        if (asset.mediaType == PHAssetMediaTypeImage) {
//            if (self.selGifSwitch.isOn && [[asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
//                continue;
//            }
//            if (self.selLivePhotoSwitch.isOn && (asset.mediaSubtypes== PHAssetMediaSubtypePhotoLive || asset.mediaSubtypes == 10)) {
//                continue;
//            }
            [arr addObject:asset];
//        }
    }
    actionSheet.arrSelectedAssets = self.rememberLastSelSwitch.isOn&&self.maxSelCountTextField.text.integerValue>1 ? arr : nil;
    
    weakify(self);
    [actionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        strongify(weakSelf);
        strongSelf.arrDataSources = images;
        strongSelf.lastSelectAssets = assets.mutableCopy;
        strongSelf.lastSelectPhotos = images.mutableCopy;
        [strongSelf.collectionView reloadData];
        NSLog(@"image:%@", images);
    }];
//    [actionSheet setSelectGifBlock:^(UIImage * _Nonnull gif, PHAsset * _Nonnull asset) {
//        strongify(weakSelf);
//        strongSelf.arrDataSources = @[gif];
//        strongSelf.lastSelectAssets = @[asset].mutableCopy;
//        [strongSelf.collectionView reloadData];
//        NSLog(@"gif:%@", gif);
//    }];
//    [actionSheet setSelectLivePhotoBlock:^(UIImage * _Nonnull livePhoto, PHAsset * _Nonnull asset) {
//        strongify(weakSelf);
//        strongSelf.arrDataSources = @[livePhoto];
//        strongSelf.lastSelectAssets = @[asset].mutableCopy;
//        [strongSelf.collectionView reloadData];
//        NSLog(@"livePhoto:%@", livePhoto);
//    }];
//    [actionSheet setSelectVideoBlock:^(UIImage * _Nonnull coverImage, PHAsset * _Nonnull asset) {
//        strongify(weakSelf);
//        strongSelf.arrDataSources = @[coverImage];
//        strongSelf.lastSelectAssets = @[asset].mutableCopy;
//        [strongSelf.collectionView reloadData];
//        NSLog(@"video cover image:%@", coverImage);
//    }];
    
    return actionSheet;
}

- (IBAction)btnSelectPhotoPreview:(id)sender
{
    [self showWithPreview:YES];
}

- (IBAction)btnSelectPhotoLibrary:(id)sender
{
    [self showWithPreview:NO];
}

- (void)showWithPreview:(BOOL)preview
{
    ZLPhotoActionSheet *a = [self getPas];
    
    if (preview) {
        [a showPreviewAnimated:YES];
    } else {
        [a showPhotoLibrary];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.imageView.image = _arrDataSources[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.lastSelectAssets[indexPath.row];
    if (self.selGifSwitch.isOn && [[asset valueForKey:@"filename"] containsString:@"GIF"]) {
        //gif预览
        ZLShowGifViewController *vc = [[ZLShowGifViewController alloc] init];
        ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeGif duration:nil];
        vc.model = model;
        [self showDetailViewController:vc sender:self];
    } else if (self.selLivePhotoSwitch.isOn && (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive || asset.mediaSubtypes == 10)) {
        ZLShowLivePhotoViewController *vc = [[ZLShowLivePhotoViewController alloc] init];
        ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeLivePhoto duration:nil];
        vc.model = model;
        [self showDetailViewController:vc sender:self];
    } else if (asset.mediaType == PHAssetMediaTypeVideo) {
        //视频预览
        ZLShowVideoViewController *vc = [[ZLShowVideoViewController alloc] init];
        ZLPhotoModel *model = [ZLPhotoModel modelWithAsset:asset type:ZLAssetMediaTypeVideo duration:nil];
        vc.model = model;
        [self showDetailViewController:vc sender:self];
    } else {
        //image预览
        [[self getPas] previewSelectedPhotos:self.lastSelectPhotos assets:self.lastSelectAssets index:indexPath.row];
    }
}

- (IBAction)valueChanged:(id)sender
{
    UISwitch *s = (UISwitch *)sender;
    
    if (s == self.selImageSwitch) {
        if (!s.isOn) {
            [self.selGifSwitch setOn:NO animated:YES];
            [self.selLivePhotoSwitch setOn:NO animated:YES];
            [self.allowEditSwitch setOn:NO animated:YES];
            [self.selVideoSwitch setOn:YES animated:YES];
        }
    } else if (s == self.selGifSwitch) {
        if (s.isOn) {
            [self.selImageSwitch setOn:YES animated:YES];
        }
    } else if (s == self.selVideoSwitch) {
        if (!s.isOn) {
            [self.selImageSwitch setOn:YES animated:YES];
        }
    }
}


#pragma mark - text field delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _previewTextField) {
        NSString *str = textField.text;
        textField.text = str.integerValue > 50 ? @"50" : str;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
