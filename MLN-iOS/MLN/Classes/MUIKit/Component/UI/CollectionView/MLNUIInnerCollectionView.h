//
//  MLNUIInnerCollectionView.h
//  MLNUI
//
//  Created by MoMo on 2019/9/2.
//

#import <UIKit/UIKit.h>
#import "MLNUIEntityExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNUILuaCore;
@interface MLNUIInnerCollectionView : UICollectionView

@property (nonatomic, weak) id<MLNUIEntityExportProtocol> containerView;

- (MLNUILuaCore *)mln_luaCore;

@end

NS_ASSUME_NONNULL_END
