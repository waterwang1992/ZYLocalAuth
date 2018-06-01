//
//  ZYLocalAuthIDConstant.h
//  ZYLocalAuthenticitiaonIDDemo
//
//  Created by Clarence on 2018/5/15.
//  Copyright © 2018年 Clarence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

#define ZYLA_IOS_8_0 @"8.0"
#define ZYLA_IOS_9_0 @"9.0"
#define ZYLA_IOS_11_0 @"11.0"

#define ZYLA_SYSTEMVERSION [[UIDevice currentDevice] systemVersion]
#define ZYLA_SYSTEM_VERSION_EQUAL_TO(version)                  ([ZYLA_SYSTEMVERSION compare:version options:NSNumericSearch] == NSOrderedSame)
#define ZYLA_SYSTEM_VERSION_GREATER_THAN(version)              ([ZYLA_SYSTEMVERSION compare:version options:NSNumericSearch] == NSOrderedDescending)
#define ZYLA_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version)  ([ZYLA_SYSTEMVERSION compare:version options:NSNumericSearch] != NSOrderedAscending)
#define ZYLA_SYSTEM_VERSION_LESS_THAN(version)                 ([ZYLA_SYSTEMVERSION compare:version options:NSNumericSearch] == NSOrderedAscending)
#define ZYLA_SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version)     ([ZYLA_SYSTEMVERSION compare:version options:NSNumericSearch] != NSOrderedDescending)

/**
 *  TouchID/FaceID 错误状态
 */
typedef NS_ENUM(NSUInteger, ZYLAErrorState){
    ZYLAErrorStateOther = 0, //其他错误类型 无具体意义
    ZYLAErrorStateSuccess = 1, // TouchID/FaceID 验证成功
    ZYLAErrorStateFail = 2, // TouchID/FaceID 验证失败
    ZYLAErrorStateUserCancel = 3, // TouchID/FaceID 被用户手动取消
    ZYLAErrorStateFallBack = 4, // 用户不使用TouchID/FaceID,选择手动输入密码
    ZYLAErrorStateSystemCancel = 5, // TouchID/FaceID 被系统取消 (如遇到来电,锁屏,按了Home键等)
    ZYLAErrorStatePasscodeNotSet = 6, // TouchID/FaceID 无法启动,因为用户没有设置密码
    ZYLAErrorStateBiometryNotEnrolled = 7, // TouchID/FaceID 无法启动,因为用户没有设置TouchID/FaceID
    ZYLAErrorStateBiometryNotAvailable = 8, // TouchID/FaceID 无效
    ZYLAErrorStateBiometryLockout = 9, // TouchID/FaceID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)
    ZYLAErrorStateAppCancel = 10,// 当前软件被挂起并取消了授权 (如App进入了后台等)
    ZYLAErrorStateInvalidContext = 11,// 当前软件被挂起并取消了授权 (LAContext对象无效)
    ZYLAErrorStateVersionNotSupport = 12,// 系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)
    ZYLAErrorStateNotInteractive = 13, // 身份验证失败，因为它需要显示已被禁止的UI
    ZYLAErrorStateBiometryHasChanged = 14 // 指纹有更改
    
};

// LA 认证启动能力
typedef NS_ENUM(NSInteger, ZYLACanEvaluateState) {
    ZYLACanEvaluateStateCan = 1, //可以启动
    ZYLACanEvaluateStatePasscodeNotSet = 2, // 密码未设置, 无法启动
    ZYLACanEvaluateStateNotAvailable = 3, // 不可用, 无法启动
    ZYLACanEvaluateStateNotEnrolled = 4, //不可用 未设置
    ZYLACanEvaluateStateLockout = 5, // 被锁定, 无法启动(LAPolicyDeviceOwnerAuthenticationWithBiometrics时, 无法启动, 可通过LAPolicyDeviceOwnerAuthentication 启动输入密码界面)
    ZYLACanEvaluateStateOther = 6, // 其他无法启动的类型, 无具体意义
};

@interface ZYLocalAuthIDConstant : NSObject

+ (ZYLAErrorState)stateWithError:(NSError *)error;

+ (ZYLACanEvaluateState)canEvaluateStateWithError:(NSError *)error;
@end
