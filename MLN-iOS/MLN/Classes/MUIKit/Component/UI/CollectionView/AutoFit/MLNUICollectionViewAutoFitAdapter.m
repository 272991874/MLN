//
//  MLNUICollectionViewAutoFitAdapter.m
//
//
//  Created by MoMo on 2019/2/19.
//

#import "MLNUICollectionViewAutoFitAdapter.h"
#import "MLNUIViewExporterMacro.h"
#import "MLNUICollectionViewCell.h"
#import "MLNUICollectionView.h"
#import "UIScrollView+MLNUIKit.h"
#import "MLNUIBlock.h"

@interface MLNUICollectionViewAutoFitAdapter ()<MLNUICollectionViewCellDelegate>

@end

@implementation MLNUICollectionViewAutoFitAdapter

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. cache
    NSValue *sizeValue = [self.cachesManager layoutInfoWithIndexPath:indexPath];
    if (sizeValue) {
        CGSize size = [sizeValue CGSizeValue];
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            return size;
        }
    }
    
    // 2. calculate size
    NSString *reuseId = [self reuseIdentifierAtIndexPath:indexPath];
    [self registerCellClassIfNeed:collectionView reuseId:reuseId];
    
    MLNUICollectionViewAutoSizeCell *cell = [[MLNUICollectionViewAutoSizeCell alloc] init];
    cell.delegate = self;
    [cell pushContentViewWithLuaCore:self.mlnui_luaCore forNodeKey:indexPath];
    
    MLNUIBlock *initCallback = [self initedCellCallbackByReuseId:reuseId];
    [initCallback addLuaTableArgument:[cell getLuaTable]];
    [initCallback callIfCan];
    
    MLNUIBlock *reuseCallback = [self fillCellDataCallbackByReuseId:reuseId];
    [reuseCallback addLuaTableArgument:[cell getLuaTable]];
    [reuseCallback addIntArgument:(int)indexPath.section+1];
    [reuseCallback addIntArgument:(int)indexPath.item+1];
    [reuseCallback callIfCan];
    
    CGSize size = [cell calculSizeWithMaxWidth:MLNUIUndefined maxHeight:MLNUIUndefined]; // 计算cell自适应大小
    [self.cachesManager updateLayoutInfo:[NSValue valueWithCGSize:size] forIndexPath:indexPath];  // update cache
    return size;
}

#pragma mark - Override

- (Class)cellClass {
    return [MLNUICollectionViewAutoSizeCell class];
}

#pragma mark - MLNUICollectionViewCellDelegate

- (void)mlnuiCollectionViewCellShouldReload:(MLNUICollectionViewCell *)cell size:(CGSize)size {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (!indexPath) return;
    
    // 直接更新缓存中的 cell 大小，这样，
    // - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
    // 方法中可以直接命中缓存，否则需要再进行一次计算
    [self.cachesManager updateLayoutInfo:@(size) forIndexPath:indexPath];

    // cell 上内容变更引起重新测量布局后，需要重新调整 cell 大小. (即 invalidate collectionViewLayout)
    UICollectionViewLayoutInvalidationContext *invalidContext = [UICollectionViewLayoutInvalidationContext new];
    [invalidContext invalidateItemsAtIndexPaths:@[indexPath]];
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:invalidContext];
}

LUAUI_EXPORT_BEGIN(MLNUICollectionViewAutoFitAdapter)
LUAUI_EXPORT_END(MLNUICollectionViewAutoFitAdapter, CollectionViewAutoFitAdapter, YES, "MLNUICollectionViewAdapter", NULL)

@end
