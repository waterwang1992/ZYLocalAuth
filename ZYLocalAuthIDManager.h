//
//  ZYLocalAuthID.h
//  ZYLocalAuthenticitiaonIDDemo
//
//  Created by Clarence on 2018/5/14.
//  Copyright © 2018年 Clarence. All rights reserved.
//
#import "ZYLocalAuthIDConstant.h"

@interface ZYLocalAuthIDManager : NSObject

typedef void (^ZYLAErrorStateBlock)(ZYLAErrorState state,NSError *error);

/**
 获取 启用验证能力 的状态
 @note 默认以 LAPolicyDeviceOwnerAuthenticationWithBiometrics 方式验证
 @warning 对于 对于Lockout状态, ios9 及其以上版本, lockout的状态实际上可以通过LAPolicyDeviceOwnerAuthentication来启用密码解锁, 对于这种情况 返回 ZYLACanEvaluateStateCan, 认为是能启动生物验证流程的.
 */
- (ZYLACanEvaluateState)zy_localAuthIdEvaluateState;

/**
 启动TouchID/FaceID进行验证
 
 @param localizedFallbackTitle 取消按钮
 @param desc TouchID/FaceID显示的描述
 @param block 回调状态的block
 @note 默认以 LAPolicyDeviceOwnerAuthenticationWithBiometrics 方式启用, 如果因为被锁定而无法启用, 在条件允许(ios9)的情况下会自动尝试转入 LAPolicyDeviceOwnerAuthentication 方式 . 调出密码输入界面解锁生物信息, 密码解锁成功后, 会继续以 LAPolicyDeviceOwnerAuthenticationWithBiometrics 方式验证. 
 */
- (void)zy_showAuthIDWithDescribe:(NSString *)desc localizedFallbackTitle:(NSString *)localizedFallbackTitle blockState:(ZYLAErrorStateBlock)block;

@end

