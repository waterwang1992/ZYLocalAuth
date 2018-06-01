//
//  ZYLocalAuthIDConstant.m
//  ZYLocalAuthenticitiaonIDDemo
//
//  Created by Clarence on 2018/5/15.
//  Copyright © 2018年 Clarence. All rights reserved.
//

#import "ZYLocalAuthIDConstant.h"

@implementation ZYLocalAuthIDConstant

+ (ZYLAErrorState)stateWithError:(NSError *)error{
    if (error == nil) {
        return ZYLAErrorStateOther;
    }
    
    switch (error.code) {
        case LAErrorAuthenticationFailed:
            return ZYLAErrorStateFail;
        case LAErrorUserCancel:
            return ZYLAErrorStateUserCancel;
        case LAErrorUserFallback:
            return ZYLAErrorStateFallBack;
        case LAErrorSystemCancel:
            return ZYLAErrorStateSystemCancel;
        case LAErrorPasscodeNotSet:
            return ZYLAErrorStatePasscodeNotSet;
        case LAErrorNotInteractive:
            return ZYLAErrorStateNotInteractive;
        default:
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            if (ZYLA_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(ZYLA_IOS_8_0) && ZYLA_SYSTEM_VERSION_LESS_THAN(ZYLA_IOS_11_0)) {
                if (error.code == LAErrorTouchIDNotAvailable) {
                    return ZYLAErrorStateBiometryNotAvailable;
                }
                if (error.code == LAErrorTouchIDNotEnrolled) {
                    return ZYLAErrorStateBiometryNotEnrolled;
                }
            }
            if (ZYLA_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(ZYLA_IOS_9_0) && ZYLA_SYSTEM_VERSION_LESS_THAN(ZYLA_IOS_11_0)) {
                if (error.code == LAErrorTouchIDLockout) {
                    return ZYLAErrorStateBiometryLockout;
                }
            }
            if (ZYLA_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(ZYLA_IOS_9_0)) {
                if (error.code == LAErrorAppCancel) {
                    return ZYLAErrorStateAppCancel;
                }
                if (error.code == LAErrorInvalidContext) {
                    return ZYLAErrorStateInvalidContext;
                }
            }
            if (ZYLA_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(ZYLA_IOS_11_0)) {
                if (error.code == LAErrorBiometryNotAvailable) {
                    return ZYLAErrorStateBiometryNotAvailable;
                }
                if (error.code == LAErrorBiometryNotEnrolled) {
                    return ZYLAErrorStateBiometryNotEnrolled;
                }
                if (error.code == LAErrorBiometryLockout) {
                    return ZYLAErrorStateBiometryLockout;
                }
            }
#pragma clang diagnostic pop
            return ZYLAErrorStateOther;
        }
    }
    return ZYLAErrorStateOther;
}

+ (ZYLACanEvaluateState)canEvaluateStateWithError:(NSError *)error{
    if (error == nil) {
        return ZYLACanEvaluateStateOther;
    }
    ZYLAErrorState state = [self stateWithError:error];
    switch (state) {
        case ZYLAErrorStateBiometryNotEnrolled:
            return ZYLACanEvaluateStateNotEnrolled;
        case ZYLAErrorStateBiometryNotAvailable:
            return ZYLACanEvaluateStateNotAvailable;
        case ZYLAErrorStatePasscodeNotSet:
            return ZYLACanEvaluateStatePasscodeNotSet;
        case ZYLAErrorStateBiometryLockout:
            return ZYLACanEvaluateStateLockout;
        default:
            return ZYLACanEvaluateStateOther;
            break;
    }
    return  ZYLACanEvaluateStateOther;
}

@end
