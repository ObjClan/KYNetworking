//
//  HttpManager.m
//  KYNetworking
//
//  Created by Key on 25/04/2019.
//  Copyright © 2019 Key. All rights reserved.
//

#import "HttpManager.h"
@implementation HttpManager
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    static HttpManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        _manager = [[HttpManager alloc] init];
    });
    return _manager;
}
- (KYHTTPMethod)httpMethod
{
    return KYHTTPMethodGET;
}
- (NSString *)baseURL
{
    return @"https://www.baifubao.com/";
}
- (NSDictionary *)httpHeaderField
{
    return nil;
}
- (KYRequestSerializerType)requestSerializerType
{
    return KYRequestSerializerTypeHTTP;
}
- (KYResponseSerializerType)responseSerializerType
{
    return KYResponseSerializerTypeHTTP;
}
- (NSTimeInterval)requestTimeout
{
    return 20.0f;
}
- (BOOL)allowInvalidCertificates
{
    return NO;
}
- (BOOL)validatesDomainName
{
    return YES;
}
- (id)extendedParameters:(id)parameters url:(nonnull NSString *)url
{
    id params = parameters;
    NSLog(@"%@,请求参数:\n%@",url,params);
    return params;
}
- (BOOL)shouldSaveResponseToCache:(id)response
{
    if ([response isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)response;
        if ([str containsString:@"area"]) {
            return YES;
        }
    }
    return NO;
}
- (id)analysisObjectFromResponse:(id)response url:(NSString *)url
{
    NSString *resultStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    return resultStr;
}
- (NSString *)getCacheKeyWithUrl:(NSString *)url parameters:(id)parameters
{
    NSMutableDictionary *params = ((NSDictionary *)parameters).mutableCopy;
    if ([url isEqualToString:@"user/login"]) {
        params[@"timestamp"] = nil;
    }
    return [super getCacheKeyWithUrl:url parameters:params.copy];
}
- (BOOL)cacheKeyContainsBaseUrl
{
    return NO;
}
- (void)sendRequestWithUrl:(NSString *)url
                parameters:(id)parameters
                  progress:(void (^)(NSProgress * _Nonnull))progress
                     cache:(BOOL)cache
              cacheTimeout:(NSTimeInterval)cacheTimeout
              denyRepeated:(BOOL)denyRepeated
                  callBack:(KYHTTPUseCacheCallBack)callBack
            originCallBack:(KYHTTPCallBack)originCallBack
{
    [super sendRequestWithUrl:url
                               parameters:parameters
                                 progress:progress
                                    cache:cache
                             cacheTimeout:cacheTimeout
                             denyRepeated:denyRepeated
                         callBack:^(BOOL isCache, id  _Nullable response, NSError * _Nullable error)
     {
         if (cache) {
             if (isCache) {
                 NSLog(@"%@,从缓存返回:\n%@",url,response);
             } else {
                 NSLog(@"%@,无缓存，从远程返回:\n%@",url,response);
             }
             if (callBack) {
                 callBack(isCache, response, error);
             }
         }
     }
                           originCallBack:^(id  _Nullable response, NSError * _Nullable error)
     {
         if (error) {
             NSLog(@"%@,请求失败:\n%@", url,error);
         } else {
             NSLog(@"%@,从远程返回:\n%@",url,response);
         }
         if (originCallBack) {
             originCallBack(response, error);
         }
     }];
}

@end
