//
//  ZYQuickPayPassswordTool.m
//  ZYLocalAuthenticitiaonIDDemo
//
//  Created by Clarence on 2018/5/16.
//  Copyright © 2018年 Clarence. All rights reserved.
//

#import "ZYQuickPayPersistent.h"

static NSString * const ZYQuickPayKeyChainTypePwdName = @"zy_quickpaypwd";
static NSString * const ZYQuickPayKeyChainTypeEPDName = @"zy_EPD";

typedef NS_ENUM(NSInteger, ZYQuickPayKeyChainItemType) {
    ZYQuickPayKeyChainItemTypePwd, //密码和秘钥
    ZYQuickPayKeyChainItemTypeEPD, //EvaluatedPolicyDomainState
};

@interface ZYQuickPayPersistent ()
@property (copy, nonatomic) NSString *password;
@end

@implementation ZYQuickPayPersistent

+ (instancetype)sharePersistent{
    static ZYQuickPayPersistent *persistent = nil;
    static dispatch_once_t dispacth;
    dispatch_once(&dispacth, ^{
        persistent = [[ZYQuickPayPersistent alloc] init];
    });
    return persistent;
}

#pragma mark -  fake getter

- (NSString *)keyForEpd{
#warning just test userId
    return [NSString stringWithFormat:@"%@_%@", ZYQuickPayKeyChainTypeEPDName, @"userId"];
}

#pragma mark - public

#pragma mark - 一键支付支付密码

- (void)storeQuickpayPassword:(NSString *)passWord{
    self.password = passWord; //缓存password.
    [self saveKeyChainItemWithType:ZYQuickPayKeyChainItemTypePwd value:passWord];//保存密码至keychain
    
}

- (void)deleteQuickPayPasswordIfExist{
    self.password = nil; //删除缓存密码
    [self removeKeyChainItemWithType:ZYQuickPayKeyChainItemTypePwd];//删除keychain密码
}

- (NSString *)getQuickPayPassword{
    
    //取缓存密码
    id ret = self.password;
    if (ret != nil) {
        return ret;
    }
    //从keychain取
    ret =  [self loadWithType:ZYQuickPayKeyChainItemTypePwd];
    if ([ret isKindOfClass:[NSData class]]){
        ret = [NSKeyedUnarchiver unarchiveObjectWithData:ret];
    }
    if ([ret isKindOfClass:[NSString class]]) {
        //更新缓存密码
        self.password = ret;
        return ret;
    }
    return nil;
}

#pragma mark - 一键支付 生物验证信息

- (void) storeQuickPayEvaluatedPolicyDomainState:(NSData *)evaluatedPolicyDomainState{
    [self saveDomainState:evaluatedPolicyDomainState]; //domainState 存入Userdefault
    [self saveKeyChainItemWithType:ZYQuickPayKeyChainItemTypeEPD value:evaluatedPolicyDomainState];//domainState 存入keychain
}

- (void)deleteQuickPayEvaluatedPolicyDomainStateIfExist{
    [self removeDomainState]; //domainState 从 UserDefault 移除
    [self removeKeyChainItemWithType:ZYQuickPayKeyChainItemTypeEPD];//domainState 从keychain移除
}

- (NSData *)getQuickPayEvaluatedPolicyDomainState{
    //从UserDefault 取值
    NSData *domainState = [self getDomainState];
    if (domainState != nil && [domainState isKindOfClass:[NSData class]]) {
        return domainState;
    }
    
    //从keychain取值
    domainState = [self loadWithType:ZYQuickPayKeyChainItemTypeEPD];
    if ([domainState isKindOfClass:[NSDate class]]) {
        //更新UserDefault的domainState
        [self saveDomainState:domainState];
        return domainState;
    }
    return nil;
}

#pragma mark - private

#pragma mark - 一键支付 存储domian stare , UserDefault

- (void)saveDomainState:(NSData *)domainState{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:domainState forKey:[self keyForEpd]];
    [user synchronize];
}

- (NSData *)getDomainState{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    return [user objectForKey:[self keyForEpd]];
}

- (void)removeDomainState{
   NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:[self keyForEpd]];
}

#pragma mark - tool

// 生成queryDict
- (NSDictionary *)getKeyChainqueryWithType:(ZYQuickPayKeyChainItemType)type{
    
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *typeName = type == ZYQuickPayKeyChainItemTypePwd ? ZYQuickPayKeyChainTypePwdName : ZYQuickPayKeyChainTypeEPDName;
#warning just test cookieID
    NSString *cookieId = @"cookieId";//cookieId 理论上kSecAttrAccessibleWhenUnlockedThisDeviceOnly 模式下,不需要, 先放着
#warning just test userID
    NSString *userId = @"userId";
    
    NSString *service = [NSString stringWithFormat:@"%@_%@", typeName,bundleId];
    NSString *account = [NSString stringWithFormat:@"%@_%@", cookieId, userId];
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            account, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly,(id)kSecAttrAccessible,
            nil];
}

//删除
- (void)removeKeyChainItemWithType:(ZYQuickPayKeyChainItemType)type{
    NSMutableDictionary *keychainQuery = [[self getKeyChainqueryWithType:type] mutableCopy];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

//保存
- (void)saveKeyChainItemWithType:(ZYQuickPayKeyChainItemType)type value:(id)value{
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [[self getKeyChainqueryWithType:type] mutableCopy];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    if ([value isKindOfClass:[NSData class]]) {
        [keychainQuery setObject:value forKey:(id)kSecValueData];
    }else{
        [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:value] forKey:(id)kSecValueData];
    }
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

//读取
- (id)loadWithType:(ZYQuickPayKeyChainItemType)type{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [[self getKeyChainqueryWithType:type] mutableCopy];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", @(type), e);
        } @finally {
            if (!ret && keyData != NULL) {
                ret = (__bridge NSData *)keyData;
            }
        }
    }
    if (keyData) CFRelease(keyData);
    return ret;
}


@end
