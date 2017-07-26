//
//  ZLBigImageCell.m
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLVideoCell.h"
#import "ZLPhotoManager.h"
#import "ZLDefine.h"
#import <Photos/Photos.h>
#import "ZLPhotoModel.h"
#import <AVFoundation/AVFoundation.h>
#import "ZLPhotoManager.h"
#import "ZLPhotoBrowser.h"


@interface ZLVideoCell ()

@end

@implementation ZLVideoCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (ZLVideoView *)bigImageView
{
    if (!_bigImageView) {
        _bigImageView = [[ZLVideoView alloc] initWithFrame:self.bounds];
    }
    return _bigImageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bigImageView];
        weakify(self);
        self.bigImageView.singleTapCallBack = ^() {
            strongify(weakSelf);
            if (strongSelf.singleTapCallBack) strongSelf.singleTapCallBack();
        };
    }
    return self;
}

- (void)resetCellStatus
{
}

- (void)setModel:(ZLPhotoModel *)model
{
    _model = model;
    
    [self.bigImageView loadAsset:model.asset];
}

@end

/////////////////
@interface ZLVideoView ()

@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) UILabel *icloudLoadFailedLabel;

@end

@implementation ZLVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSLog(@"---- %s", __FUNCTION__);
}

- (void)loadAsset:(PHAsset *)asset
{
    _asset = asset;
    [self requestPlayItem];
}

- (void)requestPlayItem
{
    if ([ZLPhotoManager judgeAssetisInLocalAblum:self.asset]) {
        weakify(self);
        [ZLPhotoManager requestVideoForAsset:self.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongify(weakSelf);
                if (!item) {
                    [strongSelf initVideoLoadFailedFromiCloudUI];
                    return;
                }
                [strongSelf initPlayView];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
                strongSelf.playLayer.player = player;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:player.currentItem];
            });
        }];
    } else {
        [self initVideoLoadFailedFromiCloudUI];
    }
}

- (void)initPlayView
{
    self.playLayer = [[AVPlayerLayer alloc] init];
    self.playLayer.frame = self.bounds;
    [self.layer addSublayer:self.playLayer];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setBackgroundImage:GetImageWithName(@"playVideo") forState:UIControlStateNormal];
    self.playBtn.frame = CGRectMake(0, 0, 80, 80);
    self.playBtn.center = self.center;
    [self.playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.playBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playBtnClick)];
    [self addGestureRecognizer:tap];
    
    weakify(self);
    [ZLPhotoManager requestOriginalImageForAsset:self.asset completion:^(UIImage *image, NSDictionary *info) {
        if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
        strongify(weakSelf);
        strongSelf.coverImage = image;
    }];
}

- (void)initVideoLoadFailedFromiCloudUI
{
    self.backgroundColor = [UIColor blackColor];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    //创建图片附件
    NSTextAttachment *attach = [[NSTextAttachment alloc]init];
    attach.image = GetImageWithName(@"videoLoadFailed");
    attach.bounds = CGRectMake(0, -10, 30, 30);
    //创建属性字符串 通过图片附件
    NSAttributedString *attrStr = [NSAttributedString attributedStringWithAttachment:attach];
    //把NSAttributedString添加到NSMutableAttributedString里面
    [str appendAttributedString:attrStr];
    
    NSAttributedString *lastStr = [[NSAttributedString alloc] initWithString:[NSBundle zlLocalizedStringForKey:ZLPhotoBrowseriCloudVideoText]];
    [str appendAttributedString:lastStr];
    self.icloudLoadFailedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 70, 200, 35)];
    self.icloudLoadFailedLabel.font = [UIFont systemFontOfSize:12];
    self.icloudLoadFailedLabel.attributedText = str;
    self.icloudLoadFailedLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.icloudLoadFailedLabel];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setBackgroundImage:GetImageWithName(@"playVideo") forState:UIControlStateNormal];
    self.playBtn.frame = CGRectMake(0, 0, 80, 80);
    self.playBtn.center = self.center;
    self.playBtn.enabled = NO;
    [self addSubview:self.playBtn];
    
}

- (void)playBtnClick
{
    AVPlayer *player = self.playLayer.player;
    CMTime stop = player.currentItem.currentTime;
    CMTime duration = player.currentItem.duration;
    if (player.rate == .0) {
        if (stop.value == duration.value) {
            [player.currentItem seekToTime:CMTimeMake(0, 1)];
        }
        [player play];
        self.playBtn.hidden = YES;
    } else {
        [player pause];
        self.playBtn.hidden = NO;
    }
    
    if (self.singleTapCallBack) self.singleTapCallBack();
}

- (void)playFinished:(AVPlayerItem *)item
{
    [self.playLayer.player seekToTime:kCMTimeZero];
    self.playBtn.hidden = NO;

}



@end
