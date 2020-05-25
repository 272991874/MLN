//
//  MLNUIWaterfallAdapter.m
//  
//
//  Created by MoMo on 2018/7/18.
//

#import "MLNUIWaterfallAdapter.h"
#import "MLNUIWaterfallView.h"
#import "MLNUICollectionViewCell.h"
#import "MLNUIInternalWaterfallView.h"
#import "MLNUIWaterfallHeaderView.h"
#import "MLNUIBlock.h"
#import "MLNUIKitHeader.h"
#import "MLNUIViewExporterMacro.h"
#import "UIView+MLNUILayout.h"
#import "MLNUILayoutNode.h"


#define kMLNUIWaterfallViewReuseID @"kMLNUIWaterfallViewReuseID"

@interface MLNUIWaterfallAdapter ()

@property (nonatomic, strong) MLNUIBlock *heightForHeaderCallback;
@property (nonatomic, strong) MLNUIBlock *headerValidCallback;
@property (nonatomic, strong) MLNUIBlock *initedHeaderCallback;
@property (nonatomic, strong) MLNUIBlock *reuseHeaderCallback;
@property (nonatomic, strong) MLNUIBlock *heightForCellCallback;
@property (nonatomic, strong) MLNUIBlock *headerWillAppearCallback;
@property (nonatomic, strong) MLNUIBlock *headerDidDisappearCallback;

@end

@implementation MLNUIWaterfallAdapter

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.heightForCellCallback) {
        [self.heightForCellCallback addIntArgument:(int)indexPath.section+1];
        [self.heightForCellCallback addIntArgument:(int)indexPath.item+1];
        NSNumber *heightValue = [self.heightForCellCallback callIfCan];
        MLNUIKitLuaAssert(heightValue && [heightValue isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'heightForCell' must be a number!");
        CGFloat height = CGFloatValueFromNumber(heightValue);
        height = height < 0 ? 0 : height;
        return height;
    }
    return 60.f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section != 0) { // WaterfallView 限制只有一个headerView
        return CGSizeMake(0, 0);
    }
    
    UIView *headerView = [MLNUIInternalWaterfallView headerViewInWaterfall:collectionView];
    if (!headerView) { // headerView 不存在，使用header新接口initedHeader、fillHeaderData、heightForHeader
        BOOL isHeaderValid = [self _mln_in_headerIsValid];
        if (section == 0 && isHeaderValid) {
            if (!self.heightForHeaderCallback) {
                MLNUIKitLuaAssert(NO, @"The 'heightForHeader' callback must not be nil!");
                return CGSizeZero;
            } else {
                [self.heightForHeaderCallback addIntArgument:(int)section+1];
                NSNumber *heightValue = [self.heightForHeaderCallback callIfCan];
                MLNUIKitLuaAssert(heightValue && [heightValue isMemberOfClass:NSClassFromString(@"__NSCFNumber")], @"The return value of method 'heightForHeader' must be a number!");
                CGFloat height = CGFloatValueFromNumber(heightValue);
                height = height < 0 ? 0 : height;
                return CGSizeMake(0, height);
            }
        }
        return CGSizeZero;
    } else {
        CGSize size = [headerView.lua_node measureSizeWithMaxWidth:collectionView.frame.size.width maxHeight:CGFLOAT_MAX];
        return CGSizeMake(0, size.height);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UIView *headerView = [MLNUIInternalWaterfallView headerViewInWaterfall:collectionView];
    if (!headerView) {
        [collectionView registerClass:[MLNUIWaterfallHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNUIWaterfallHeaderViewReuseID];
        MLNUIWaterfallHeaderView *waterfallHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMLNUIWaterfallHeaderViewReuseID forIndexPath:indexPath];
        [waterfallHeaderView pushContentViewWithLuaCore:self.mln_luaCore];
        
        BOOL isHeaderValid = [self _mln_in_headerIsValid];
        if (indexPath.section != 0 || !isHeaderValid) {
            return waterfallHeaderView;
        }
        
        if (!waterfallHeaderView.isInited) {
            MLNUIKitLuaAssert(self.initedHeaderCallback, @"It must not be nil callback of header init!");
            [self.initedHeaderCallback addLuaTableArgument:[waterfallHeaderView getLuaTable]];
            [self.initedHeaderCallback addIntArgument:(int)indexPath.section+1];
            [self.initedHeaderCallback addIntArgument:(int)indexPath.row+1];
            [self.initedHeaderCallback callIfCan];
            [waterfallHeaderView initCompleted];
        }
        MLNUIKitLuaAssert(self.reuseHeaderCallback, @"It must not be nil callback of header reuse!")
        [self.reuseHeaderCallback addLuaTableArgument:[waterfallHeaderView getLuaTable]];
        [self.reuseHeaderCallback addIntArgument:(int)indexPath.section+1];
        [self.reuseHeaderCallback addIntArgument:(int)indexPath.row+1];
        [self.reuseHeaderCallback callIfCan];
        [waterfallHeaderView requestLayoutIfNeed];
        return waterfallHeaderView;
    } else {
        static NSString *reuseId = kMLNUIWaterfallViewReuseID;
        [collectionView registerClass:[MLNUICollectionViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseId];
        MLNUICollectionViewCell *headerContentView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseId forIndexPath:indexPath];
        [headerContentView pushContentViewWithLuaCore:self.mln_luaCore];
        if ([collectionView isKindOfClass:[MLNUIInternalWaterfallView class]]) {
            [headerContentView setupLayoutNodeIfNeed];
            [headerContentView lua_addSubview:headerView];
            [headerView.lua_node needLayoutAndSpread];
            [headerContentView requestLayoutIfNeed];
            [headerContentView updateLuaContentViewIfNeed];
            headerContentView.bounds = headerContentView.bounds;
            return headerContentView;
        }
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (self.headerWillAppearCallback) {
        id<MLNUIReuseCellProtocol> headerContentView = (id<MLNUIReuseCellProtocol>)view;
        [self.headerWillAppearCallback addLuaTableArgument:[headerContentView getLuaTable]];
        [self.headerWillAppearCallback addIntArgument:(int)indexPath.section+1];
        [self.headerWillAppearCallback addIntArgument:(int)indexPath.item+1];
        [self.headerWillAppearCallback callIfCan];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(nonnull UICollectionReusableView *)view forElementOfKind:(nonnull NSString *)elementKind atIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (self.headerDidDisappearCallback) {
        id<MLNUIReuseCellProtocol> headerContentView = (id<MLNUIReuseCellProtocol>)view;
        [self.headerDidDisappearCallback addLuaTableArgument:[headerContentView getLuaTable]];
        [self.headerDidDisappearCallback addIntArgument:(int)indexPath.section+1];
        [self.headerDidDisappearCallback addIntArgument:(int)indexPath.item+1];
        [self.headerDidDisappearCallback callIfCan];
    }
}

- (void)lua_headerWillAppearCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.headerWillAppearCallback = callback;
}

- (void)lua_headerDidDisappearCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.headerDidDisappearCallback = callback;
}

#pragma mark - WaterfallView header
- (void)lua_initHeaderCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.initedHeaderCallback = callback;
}

- (void)lua_reuseHeaderCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.reuseHeaderCallback = callback;
}

- (void)lua_headValidCallback:(MLNUIBlock *)callback
{
    MLNUICheckTypeAndNilValue(callback, @"function", MLNUIBlock);
    self.headerValidCallback = callback;
}

#pragma mark - WaterfallViewLayoutDelegate
- (BOOL)headerIsValidWithWaterfallView:(UICollectionView *)waterfallView
{
    return [self _mln_in_headerIsValid];
}

- (BOOL)headerIsSettingInNewWayWithWaterfallView:(UICollectionView *)waterfallView
{
    return self.headerValidCallback? YES : NO;
}

#pragma mark - Private method
- (BOOL)_mln_in_headerIsValid
{
    if (!self.headerValidCallback) {
        return NO;
    }
    NSNumber *headerValidValue = [self.headerValidCallback callIfCan];
    MLNUIKitLuaAssert(headerValidValue && [headerValidValue isMemberOfClass:NSClassFromString(@"__NSCFBoolean")], @"The return value of  method 'headerValid' must be a bool value!");
    return [headerValidValue boolValue];
}

LUA_EXPORT_BEGIN(MLNUIWaterfallAdapter)
LUA_EXPORT_METHOD(heightForHeader, "setHeightForHeaderCallback:", MLNUIWaterfallAdapter)
LUA_EXPORT_METHOD(initHeader, "lua_initHeaderCallback:", MLNUIWaterfallAdapter)
LUA_EXPORT_METHOD(fillHeaderData, "lua_reuseHeaderCallback:", MLNUIWaterfallAdapter)
LUA_EXPORT_METHOD(headerValid, "lua_headValidCallback:", MLNUIWaterfallAdapter)
LUA_EXPORT_METHOD(heightForCell, "setHeightForCellCallback:", MLNUIWaterfallAdapter)
LUA_EXPORT_METHOD(headerWillAppear, "lua_headerWillAppearCallback:", MLNUIWaterfallAdapter)
LUA_EXPORT_METHOD(headerDidDisappear, "lua_headerDidDisappearCallback:", MLNUIWaterfallAdapter)
LUA_EXPORT_END(MLNUIWaterfallAdapter, WaterfallAdapter, YES, "MLNUICollectionViewAdapter", NULL)

@end
