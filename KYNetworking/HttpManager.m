//
//  HttpManager.m
//  KYNetworking
//
//  Created by Key on 25/04/2019.
//  Copyright © 2019 Key. All rights reserved.
//

#import "HttpManager.h"
@implementation HttpManager

- (NSString *)baseURL
{
    return @"https://www.baifubao.com/";
}
- (NSDictionary *)httpHeaderField
{
    return @{@"token" : @"111111",@"pwd" : @"222222"};
}
- (KYRequestSerializerType)requestSerializerType
{
    return KYRequestSerializerTypeHTTP;
}
- (KYResponseSerializerType)responseSerializerType
{
    return KYResponseSerializerTypeHTTP;
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
    [self setValue:@"333333333333" forHTTPHeaderField:@"pid"];
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
