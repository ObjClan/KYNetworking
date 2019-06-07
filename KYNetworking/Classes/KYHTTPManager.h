//
//  KYHTTPManager.h
//  KYNetworking
//
//  Created by Key on 16/04/2019.
//  Copyright © 2019 Key. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^KYHTTPCallBack)(id _Nullable response, NSError * _Nullable error);
typedef void(^KYHTTPUseCacheCallBack)(BOOL isCache,id _Nullable response, NSError * _Nullable error);
typedef NS_ENUM(NSInteger, KYHTTPMethod) {
    KYHTTPMethodGET = 0,
    KYHTTPMethodPOST,
    KYHTTPMethodPUT,
    KYHTTPMethodPATCH,
    KYHTTPMethodDELETE,
    KYHTTPMethodHEAD,
};
typedef NS_ENUM(NSInteger, KYRequestSerializerType) {
    KYRequestSerializerTypeHTTP,
    KYRequestSerializerTypeJSON,
};
typedef NS_ENUM(NSInteger, KYResponseSerializerType) {
    KYResponseSerializerTypeHTTP,
    KYResponseSerializerTypeJSON,
    KYResponseSerializerTypeXML
};

@interface KYHTTPManager : NSObject
/**
 请求方法，默认GET
 */
@property (nonatomic, assign) KYHTTPMethod method;
/**
 请求超时，默认20秒
 */
@property (nonatomic, assign) NSTimeInterval requestTimeout;
/**
 获取实例对象
 */
+ (instancetype)manager;


/**
 Scheme+host
 */
- (NSString *)baseURL;

/**
 初始化一组header
 */
- (NSDictionary *)httpHeaderField;

/**
 添加一个header键值对
 @param value value
 @param field field
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 请求参数序列化方式，默认AFHTTPRequestSerializer
 */
- (KYRequestSerializerType)requestSerializerType;

/**
 响应数据反序列化方式,默认AFHTTPResponseSerializer
 */
- (KYResponseSerializerType)responseSerializerType;

/**
 HTTPS是否允许无效证书，默认为NO不允许
 */
- (BOOL)allowInvalidCertificates;

/**
 HTTPS是否需要域名校验，默认为YES需要
 */
- (BOOL)validatesDomainName;

/**
 扩展参数
 需要在所有接口的参数中统一作处理(如参数签名)，需要重写此方法
 @param parameters 原参数
 @param url path
 @return 处理后的参数
 */
- (id)extendedParameters:(id)parameters url:(NSString *)url;
/**
 需要将响应结果保存到缓存的条件,这里的resonse是经过analysisObjectFromResponse:url:方法处理过的
 由子类重写，根据respone的内容判断是否保存,因为http响应状态为200只能说明与服务端连通
 如response为@{“status” : 1，@“data” : @{@"token" : @"1111"}},需要根据status的状态确定是否保存
 @param response 响应结果
 @return YES保存，NO不保存
 */
- (BOOL)shouldSaveResponseToCache:(id)response;

/**
 根据url和参数生成缓存key,可以在子类中重写过滤掉不需的参数
 @param url path
 @param parameters 参数
 */
- (NSString *)getCacheKeyWithUrl:(NSString *)url parameters:(id)parameters;

/**
 缓存的key是否包含baseUrl，默认为YES包含
 */
- (BOOL)cacheKeyContainsBaseUrl;
/**
 响应结果转换，默认回调原数据,转换后回调转换后的数据。
 如:返回的原数据为data类型想要转化为NSDictionary
 @param response 原response
 @param url path
 @return 转换后的response
 */
- (id)analysisObjectFromResponse:(id)response url:(NSString *)url;

/**
 发送请求,有进度,可使用缓存,可设置禁止重复请求

 @param url url descriptionpath
 @param parameters 参数
 @param progress 进度
 @param cache 是否使用缓存
 @param cacheTimeout 缓存超时时间
 @param denyRepeated 是否禁止重复请求
 @param callBack 如果使用缓存且缓存存在，则回调中isCache为真，此时数据来自缓存，否则为假，数据来自远程
 @param originCallBack 数据来自远程服务端的回调
 */
- (void)sendRequestWithUrl:(NSString *)url
                parameters:(id)parameters
                  progress:(nullable void (^)(NSProgress *))progress
                     cache:(BOOL)cache
              cacheTimeout:(NSTimeInterval)cacheTimeout
              denyRepeated:(BOOL)denyRepeated
                  callBack:(nullable KYHTTPUseCacheCallBack)callBack
            originCallBack:(nullable KYHTTPCallBack)originCallBack;

/**
 发送请求,，不传参数，不做其他操作

 @param url url
 @param callBack 回调
 */
- (void)sendRequestWithUrl:(NSString *)url callBack:(nullable KYHTTPCallBack)callBack;

/**
 发送请求,只传参数,不做其他操作

 @param url path
 @param parameters 参数
 @param callBack 回调
 */
- (void)sendRequestWithUrl:(NSString *)url parameters:(id)parameters callBack:(nullable KYHTTPCallBack)callBack;

/**
 发送请求,可禁止重复请求,不做其他操作
 
 @param url path
 @param parameters 参数
 @param denyRepeated YES禁止，NO不禁止
 @param callBack 回调
 */
- (void)sendRequestWithUrl:(NSString *)url
                parameters:(id)parameters
              denyRepeated:(BOOL)denyRepeated
                  callBack:(nullable KYHTTPCallBack)callBack;

/**
 发送请求,可以使用缓存,不做其他操作

 @param url path
 @param parameters 参数
 @param cache 是否使用缓存
 @param cacheTimeout 缓存超时时间
 @param callBack 如果使用缓存且缓存存在，则回调中isCache为真，此时数据来自缓存，否则为假，数据来自远程
 @param originCallBack 数据来自远程服务端的回调
 */
- (void)sendRequestWithUrl:(NSString *)url
                parameters:(id)parameters
                     cache:(BOOL)cache
              cacheTimeout:(NSTimeInterval)cacheTimeout
                  callBack:(nullable KYHTTPUseCacheCallBack)callBack
            originCallBack:(nullable KYHTTPCallBack)originCallBack;
/**
 发送请求,可以使用缓存,可禁止重复请求
 
 @param url path
 @param parameters 参数
 @param cache 是否使用缓存
 @param cacheTimeout 缓存超时时间
 @param denyRepeated YES禁止，NO不禁止
 @param callBack 如果使用缓存且缓存存在，则回调中isCache为真，此时数据来自缓存，否则为假，数据来自远程
 @param originCallBack 数据来自远程服务端的回调
 */
- (void)sendRequestWithUrl:(NSString *)url
                parameters:(id)parameters cache:(BOOL)cache
              cacheTimeout:(NSTimeInterval)cacheTimeout
              denyRepeated:(BOOL)denyRepeated
                  callBack:(KYHTTPUseCacheCallBack)callBack
            originCallBack:(KYHTTPCallBack)originCallBack;

/**
 取消正在执行的请求

 @param url path
 */
- (void)cancelTastWithUrl:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
