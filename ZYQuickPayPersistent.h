//
//  ZYQuickPayPassswordTool.h
//  ZYLocalAuthenticitiaonIDDemo
//
//  Created by Clarence on 2018/5/16.
//  Copyright © 2018年 Clarence. All rights reserved.
//
//  1. 用于将用户 支付密码和 指纹domainState 存储于keychain.
//  2. domainState属于非敏感信息, 这里之所以也将domainState存入keychain, 是为了使domainState的生命周期和支付密码保持一致.
//  3. 这两个信息分别以不同的Dict去存储, 是因为 domainState读取和更新的频次会远高于密码的读取和更新, 分别存储可减少domainState相对频繁的keyChain操作对密码的影响.
//  4. 由于domainState属于非敏感信息, 为了提高读取更新成功率, 这里会将domainState存储于keyChain的同时, 也会将其存入UserDefault进行持久化.
//  5. 由于password属于敏感信息, 为了提高读取跟新成功率, 这里会将password存储于keyChain的同时, 也会将其放入缓存中.
//  NOTE:  使用该类进行信息的读取 必须保证用户为登陆状态.

#import <Foundation/Foundation.h>

@interface ZYQuickPayPersistent : NSObject

/**
 单例
 
 @return instancetype
 */
+ (instancetype)sharePersistent;

#pragma mark - 一键支付支付密码 keychain

/**
 存储支付密码

 @param passWord 支付密码
 */
- (void)storeQuickpayPassword:(NSString *)passWord;

/**
 删除存储的支付密码
 */
- (void)deleteQuickPayPasswordIfExist;

/**
 获取支付密码
 */
- (NSString *)getQuickPayPassword;

#pragma mark - 一键支付 生物验证信息 keychain

/**
 存储生物验证信息

 @param evaluatedPolicyDomainState NSDate
 */
- (void)storeQuickPayEvaluatedPolicyDomainState:(NSData *)evaluatedPolicyDomainState;

/**
 删除存储的生物验证信息
 */
- (void)deleteQuickPayEvaluatedPolicyDomainStateIfExist;

/**
 获取存储的生物验证信息

 @return 生物验证信息
 */
- (NSData *)getQuickPayEvaluatedPolicyDomainState;



@end
