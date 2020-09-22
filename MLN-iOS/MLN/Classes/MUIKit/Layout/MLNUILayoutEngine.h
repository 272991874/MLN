//
//  MLNUILayoutEngine.h
//
//
//  Created by MoMo on 2018/10/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MLNUIKitInstance;
@class MLNUILayoutContainerNode;
@class MLNUISizeCahceManager;
@class MLNUILayoutNode;

/**
 自动布局引擎
 
 @note 该引擎主要监听MainRunLoop的BeforeWaiting事件，在视图渲染之前计算所有需要处理的视图布局。
        该引擎会持有所有需要布局视图的Layout Node 构建成的布局树，从Root节点，递归向下计算。
 */
@interface MLNUILayoutEngine : NSObject

/**
 当前引擎所在的Lua 实例
 */
@property (nonatomic, weak, readonly) MLNUIKitInstance *luaInstance;

/**
 当前布局引擎的Size缓存
 */
@property (nonatomic, strong, readonly) MLNUISizeCahceManager *sizeCacheManager;

/**
 创建布局引擎

 @param luaInstance 引擎所在的Lua 实例
 @return 布局引擎
 */
- (instancetype)initWithLuaInstance:(MLNUIKitInstance *)luaInstance;

/**
 开启布局引擎
 */
- (void)start;

/**
 关闭布局引擎
 */
- (void)end;

/**
 添加一个布局树

 @param rootnode 布局树的根节点
 */
- (void)addRootnode:(MLNUILayoutNode *)rootnode;

/**
添加一个布局节点，以key作为标识，避免额外添加

 @param rootNode 布局树的根节点
 @param key rootNode 标识
*/
- (void)addRootNode:(MLNUILayoutNode *)rootNode forKey:(id)key;

/**
 移除一个布局树

 @param rootnode 布局树的根节点
 */
- (void)removeRootNode:(MLNUILayoutNode *)rootnode;

/**
 移除一个布局树

  @param key rootNode 标识
 */
- (void)removeRootNodeForKey:(id)key;

/**
 手动触发一个布局计算。
 
 @note 这里会计算当前引擎中的所有布局树
 */
- (void)requestLayout;

@end

NS_ASSUME_NONNULL_END
