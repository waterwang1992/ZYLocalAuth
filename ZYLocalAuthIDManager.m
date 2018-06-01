//
//  ZYLocalAuthID.m
//  ZYLocalAuthenticitiaonIDDemo
//
//  Created by Clarence on 2018/5/14.
//  Copyright © 2018年 Clarence. All rights reserved.

#import "ZYLocalAuthIDManager.h"
#import <UIKit/UIKit.h>
#import "ZYQuickPayPersistent.h"

@interface ZYLocalAuthIDManager()

@property (copy, nonatomic) NSString *localDes;
@property (copy, nonatomic) NSString *localizedFallbackTitle;
@property (assign, nonatomic) LAPolicy currentPolicy;
@property (copy, nonatomic) ZYLAErrorStateBlock stateBlock;
@end

@implementation ZYLocalAuthIDManager

#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentPolicy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    }
    return self;
}

#pragma mark - getter
- (NSString *)localDes{
    if (_localDes.length == 0) {
        _localDes = @"通过Home键验证已有指纹";
    }
    return _localDes;
}

- (NSString *)localizedFallbackTitle{
    if (_localizedFallbackTitle.length == 0) {
        _localizedFallbackTitle = @"Enter Password";
    }
    return _localizedFallbackTitle;
}

#pragma mark - public

- (ZYLACanEvaluateState)zy_localAuthIdEvaluateState{
    ZYLACanEvaluateState canState =  [self zy_localAuthIdEvaluateStateWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics];
    if (canState == ZYLACanEvaluateStateLockout && ZYLA_SYSTEM_VERSION_LESS_THAN(ZYLA_IOS_9_0)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        return [self zy_localAuthIdEvaluateStateWithPolicy:LAPolicyDeviceOwnerAuthentication];
#pragma clang diagnostic pop
    }else{
        return canState;
    }
}

- (void)zy_showAuthIDWithDescribe:(NSString *)desc localizedFallbackTitle:(NSString *)localizedFallbackTitle blockState:(ZYLAErrorStateBlock)block{
    _localizedFallbackTitle = localizedFallbackTitle;
    _localDes = desc;
    _stateBlock = block;
    [self zy_showAuthIDWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics];
}

#pragma mark - private

- (ZYLACanEvaluateState)zy_localAuthIdEvaluateStateWithPolicy:(LAPolicy)policy{
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    BOOL result = [context canEvaluatePolicy:policy error:&error];
    if (result) {
        return ZYLACanEvaluateStateCan;
    }else{
        return [ZYLocalAuthIDConstant canEvaluateStateWithError:error];
    }
}

/**
 启动TouchID/FaceID进行验证
 
 @param policy 验证策略
 @note LAPolicyDeviceOwnerAuthenticationWithBiometrics: 用TouchID/FaceID验证
 LAPolicyDeviceOwnerAuthentication: 用TouchID/FaceID或密码验证, 默认是错误两次或锁定后, 弹出输入密码界面（本案例使用）
 */
- (void)zy_showAuthIDWithPolicy:(LAPolicy)policy {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        NSLog(@"系统版本不支持TouchID/FaceID (必须高于iOS 8.0才能使用)");
        [self blockStateOnMainQueue:ZYLAErrorStateVersionNotSupport error:nil];
        return;
    }
    
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = self.localizedFallbackTitle;
    _currentPolicy = policy;
    NSError *canEvaluateError = nil;
    if ([context canEvaluatePolicy:_currentPolicy error:&canEvaluateError]) {
        
        if (@available(iOS 9.0, *)) {
            if ([[ZYQuickPayPersistent sharePersistent] getQuickPayEvaluatedPolicyDomainState] == nil || ![[[ZYQuickPayPersistent sharePersistent] getQuickPayEvaluatedPolicyDomainState] isEqualToData:context.evaluatedPolicyDomainState]) {
                NSError *changeError = [NSError errorWithDomain:@"jollychic_quickpay_localauth" code:10000 userInfo:@{NSLocalizedDescriptionKey : @"指纹已经改变"}];
                [self blockStateOnMainQueue:ZYLAErrorStateBiometryHasChanged error:changeError];
                return;
            }
        }
        [context evaluatePolicy:_currentPolicy localizedReason:self.localDes reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [self handleLocalAuthSuccess];
            }else if(error){
                [self handleLocalAuthError:error];
            }
        }];
    }else{
        [self handleLocalAuthError:canEvaluateError];
    }
}

#pragma mark - output auth result

/**
 验证成功
 @note LAPolicyDeviceOwnerAuthentication 验证策略下, 如果成功则认为是密码解锁生物信息成功, 然后重新启用 LAPolicyDeviceOwnerAuthenticationWithBiometrics 验证策略.  达到的效果就是, 只有指纹验证成功才算真正的验证成功.
 */
- (void)handleLocalAuthSuccess{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if (ZYLA_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(ZYLA_IOS_9_0) && _currentPolicy == LAPolicyDeviceOwnerAuthentication) {
#pragma clang diagnostic pop
        [self zy_showAuthIDWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics];
    }else{
        NSLog(@"TouchID/FaceID 验证成功");
        [self blockStateOnMainQueue:ZYLAErrorStateSuccess error:nil];
    }
}

/**
 验证失败
 
 @param error 验证失败,系统提供信息
 */
- (void)handleLocalAuthError:(NSError *)error{
    if (error == nil) {
        return;
    }
    ZYLAErrorState state = [ZYLocalAuthIDConstant stateWithError:error];
    switch (state) {
        case ZYLAErrorStateFail:
            [self biometryAuthFailedWhenAuthingWithError:error];
            break;
        case ZYLAErrorStateBiometryLockout:
            [self biometryLockOutWhenAuthingWithError:error];
            break;
        default:
            [self blockStateOnMainQueue:state error:error];
            break;
    }
}

/**
 验证过程中 生物验证被锁定
 @note 对于ios9以上用户, 如果生物验证被锁定, 那么直接发起 LAPolicyDeviceOwnerAuthentication 验证, 通过输入密码来解锁验证
 */
- (void)biometryLockOutWhenAuthingWithError:(NSError *)error{
    if (ZYLA_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(ZYLA_IOS_9_0) && _currentPolicy == LAPolicyDeviceOwnerAuthenticationWithBiometrics) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        [self zy_showAuthIDWithPolicy:LAPolicyDeviceOwnerAuthentication];
#pragma clang diagnostic pop
    }else{
        NSLog(@"TouchID 被锁定(连续多次验证TouchID/FaceID失败,系统需要用户手动输入密码)");
        [self blockStateOnMainQueue:ZYLAErrorStateBiometryLockout error:error];
    }
}

/**
 验证过程中 生物验证失败
 @note 验证失败, 则再次发起验证尝试
 */
- (void)biometryAuthFailedWhenAuthingWithError:(NSError *)error{
    if ( _currentPolicy == LAPolicyDeviceOwnerAuthenticationWithBiometrics) {
        [self zy_showAuthIDWithPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics];
    }else{
        NSLog(@"TouchID 验证失败");
        [self blockStateOnMainQueue:ZYLAErrorStateFail error:error];
    }
}

- (void)blockStateOnMainQueue:(ZYLAErrorState)state error:(NSError *)error{
    if (!_stateBlock) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        _stateBlock(state,error);
    });
}

@end

