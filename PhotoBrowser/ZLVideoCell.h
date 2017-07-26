//
//  ZLBigImageCell.h
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPhotoModel;
@class PHAsset;
@class ZLVideoView;

@interface ZLVideoCell : UICollectionViewCell

@property (nonatomic, strong) ZLVideoView *bigImageView;
@property (nonatomic, strong) ZLPhotoModel *model;
@property (nonatomic, copy)   void (^singleTapCallBack)();

- (void)resetCellStatus;

@end

@interface ZLVideoView : UIView


@property (nonatomic, copy)   void (^singleTapCallBack)();


- (void)loadAsset:(PHAsset *)asset;
@end
