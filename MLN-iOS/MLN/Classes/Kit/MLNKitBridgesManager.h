//
//  MLNKitBridgesManager.h
//  MLN
//
//  Created by MoMo on 2019/8/29.
//

#import <Foundation/Foundation.h>
#import "MLNExportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MLNLuaCore;
@interface MLNKitBridgesManager : NSObject

- (void)registerKitForLuaCore:(MLNLuaCore *)luaCore;

@end

@class MLNKitInstance;
@interface MLNKitBridgesManager (Deprecated)
- (instancetype)initWithUIInstance:(MLNKitInstance *)instance;
- (void)registerKit;
@end
NS_ASSUME_NONNULL_END
