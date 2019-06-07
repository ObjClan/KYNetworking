//
//  KYHTTPManager.m
//  KYNetworking
//
//  Created by Key on 16/04/2019.
//  Copyright © 2019 Key. All rights reserved.
//

#import "KYHTTPManager.h"
#import "NSString+KYNetworking.h"
#import "KYHttpResponseModel.h"
#import "KYHTTPGlobalManager.h"
@interface KYHTTPManager ()
@property (nonatomic, strong, readwrite)AFHTTPSessionManager *sessionManager;
@end
@implementation KYHTTPManager

+ (instancetype)manager
{
    return [[[self class] alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _method = KYHTTPMethodGET;
        _requestTimeout = 20.0f;
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer = [self requestSerializer];
        NSDictionary *httpHeaderField = [self httpHeaderField];
        for (NSString *key in httpHeaderField.allKeys) {
            NSString *value = httpHeaderField[key];
            [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
        }
        _sessionManager.requestSerializer.timeoutInterval = _requestTimeout;
        _sessionManager.responseSerializer = [self responseSerializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = [self allowInvalidCertificates];
        _sessionManager.securityPolicy.validatesDomainName = [self validatesDomainName];
        NSSet *acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript",@"application/javascript", @"text/json",@"text/html",@"text/css", nil];
        _sessionManager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    }
    return self;
}

#pragma mark ------------发送请求，不传参数，不做其他操作-------------------
- (void)sendRequestWithUrl:(NSString *)url callBack:(KYHTTPCallBack)callBack
{
    [self sendRequestWithUrl:url
                  parameters:@{}
                    progress:nil
                       cache:NO
                cacheTimeout:0
                denyRepeated:NO
                    callBack:nil
              originCallBack:callBack
     ];
}
#pragma mark ------------发送请求，只传参数，不做其他操作-------------------
- (void)sendRequestWithUrl:(NSString *)url parameters:(id)parameters callBack:(KYHTTPCallBack)callBack
{
    [self sendRequestWithUrl:url
                  parameters:parameters
                    progress:nil
                       cache:NO
                cacheTimeout:0
                denyRepeated:NO
                    callBack:nil
              originCallBack:callBack
     ];
}
#pragma mark ------------发送请求，可禁止重复请求-------------------
- (void)sendRequestWithUrl:(NSString *)url
                parameters:(id)parameters
              denyRepeated:(BOOL)denyRepeated
                  callBack:(KYHTTPCallBack)callBack
{
    [self sendRequestWithUrl:url
                  parameters:parameters
                    progress:nil
                       cache:NO
                cacheTimeout:0
                denyRepeated:denyRepeated
                    callBack:nil
              originCallBack:callBack
     ];
}
#pragma mark ------------发送请求，可使用缓存-------------------
- (void)sendRequestWithUrl:(NSString *)url
                parameters:(id)parameters cache:(BOOL)cache
              cacheTimeout:(NSTimeInterval)cacheTimeout
                  callBack:(KYHTTPUseCacheCallBack)callBack
            originCallBack:(KYHTTPCallBack)originCallBack
{
    [self sendRequestWithUrl:url
                  parameters:parameters
                    progress:nil
                       cache:cache
                cacheTimeout:cacheTimeout
                denyRepeated:NO
                    callBack:callBack
              originCallBack:originCallBack
     ];
}
#pragma mark ------------发送请求，可使用缓存，可设置禁止重复请求-------------------
- (void)sendRequestWithUrl:(NSString *)url
                parameters:(id)parameters cache:(BOOL)cache
              cacheTimeout:(NSTimeInterval)cacheTimeout
              denyRepeated:(BOOL)denyRepeated
                  callBack:(KYHTTPUseCacheCallBack)callBack
            originCallBack:(KYHTTPCallBack)originCallBack
{
    [self sendRequestWithUrl:url
                  parameters:parameters
                    progress:nil
                       cache:cache
                cacheTimeout:cacheTimeout
                denyRepeated:denyRepeated
                    callBack:callBack
              originCallBack:originCallBack
     ];
}
#pragma mark ------------发送请求,有进度，可使用缓存，可设置禁止重复请求-------------------
- (void)sendRequestWithUrl:(NSString *)url
                parameters:(id)parameters
                  progress:(void (^)(NSProgress * _Nonnull))progress
                     cache:(BOOL)cache
              cacheTimeout:(NSTimeInterval)cacheTimeout
              denyRepeated:(BOOL)denyRepeated
                  callBack:(nullable KYHTTPUseCacheCallBack)callBack
            originCallBack:(KYHTTPCallBack)originCallBack
{
    id params = [self extendedParameters:parameters url:url];
    if (denyRepeated && [[KYHTTPGlobalManager shareManager] hasSameUrl:url]) {
        NSLog(@"\n----重复的请求，url:%@,该接口不允许同时存在多个请求！\n",url);
        return;
    }
    NSString *cacheKey = [self getCacheKeyWithUrl:url parameters:params];
//    NSString *timeStamp = [NSString stringWithFormat:@"%.lf",[[NSDate date] timeIntervalSince1970]];
//    NSString *requestId = [cacheKey stringByAppendingString:timeStamp];
    BOOL hasCache = NO;
    if (cache) {
        NSString *sql = [NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"cacheKey"),bg_sqlValue(cacheKey)];
        NSArray *array = [KYHttpResponseModel bg_find:nil where:sql];
        if (array && array.count > 0) {
            KYHttpResponseModel *model = array.firstObject;
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
            if (callBack && ((time - model.time) < cacheTimeout)) {
                hasCache = YES;
                callBack(YES ,model.response, nil);
            }
        }
    }
    NSURLSessionTask *task = [self sendRequestWithUrl:url parameters:params progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable response) {
        id resultObj = [self analysisObjectFromResponse:response url:url];
        if (!hasCache && callBack) {
            callBack(NO ,resultObj, nil);
        }
        if (originCallBack) {
            originCallBack(resultObj, nil);
        }
        if (cache && [self shouldSaveResponseToCache:resultObj]) {
            KYHttpResponseModel *model = [[KYHttpResponseModel alloc] init];
            model.cacheKey = cacheKey;
            model.response = resultObj;
            model.time = [[NSDate date] timeIntervalSince1970];
            [model bg_saveOrUpdate];
        }
        [[KYHTTPGlobalManager shareManager] removeTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (!hasCache && callBack) {
            callBack(NO ,nil, error);
        }
        if (originCallBack) {
            originCallBack(nil, error);
        }
        [[KYHTTPGlobalManager shareManager] removeTask:task];
    }];
}
- (NSURLSessionTask *)sendRequestWithUrl:(NSString *)url
                parameters:(id)parameters
                  progress:(void (^)(NSProgress * _Nonnull))progress
                   success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                   failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    NSString *fullUrl = [NSString stringWithFormat:@"%@%@",[self baseURL],url];
    NSURLSessionTask *task = nil;
    switch (self.method) {
        case KYHTTPMethodGET:
            task = [self.sessionManager GET:fullUrl parameters:parameters progress:progress success:success failure:failure];
            break;
        case KYHTTPMethodPOST:
            task = [self.sessionManager POST:fullUrl parameters:parameters progress:progress success:success failure:failure];
            break;
        case KYHTTPMethodPUT:
            task = [self.sessionManager PUT:fullUrl parameters:parameters success:success failure:failure];
            break;
        case KYHTTPMethodPATCH:
            task = [self.sessionManager PATCH:fullUrl parameters:parameters success:success failure:failure];
            break;
        case KYHTTPMethodDELETE:
            task = [self.sessionManager DELETE:fullUrl parameters:parameters success:success failure:failure];
            break;
        case KYHTTPMethodHEAD: {
            task = [self.sessionManager HEAD:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task) {
                if (success) {
                    success(task,nil);
                }
            } failure:failure];
            break;
        }
        default:
            break;
    }
    [[KYHTTPGlobalManager shareManager] addTask:task];
    return task;
}

- (NSString *)baseURL
{
    return nil;
}
- (NSDictionary *)httpHeaderField
{
    return nil;
}
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}
- (KYRequestSerializerType)requestSerializerType
{
    return KYRequestSerializerTypeHTTP;
}
- (KYResponseSerializerType)responseSerializerType
{
    return KYResponseSerializerTypeHTTP;
}
- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer
{
    switch ([self requestSerializerType]) {
        case KYRequestSerializerTypeJSON:
            return [AFJSONRequestSerializer serializer];
        default:
            return [AFHTTPRequestSerializer serializer];
    }
}
- (AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializer
{
    switch ([self responseSerializerType]) {
        case KYResponseSerializerTypeJSON:
            return [AFJSONResponseSerializer serializer];
        case KYResponseSerializerTypeXML:
            return [AFXMLParserResponseSerializer serializer];
        default:
            return [AFHTTPResponseSerializer serializer];
    }
}

- (BOOL)allowInvalidCertificates
{
    return NO;
}
- (BOOL)validatesDomainName
{
    return YES;
}
- (BOOL)shouldSaveResponseToCache:(id)response
{
    return YES;
}
- (id)extendedParameters:(id)parameters url:(NSString *)url
{
    return parameters;
}
- (id)analysisObjectFromResponse:(id)response url:(NSString *)url
{
    return response;
}
- (NSString *)getCacheKeyWithUrl:(NSString *)url parameters:(id)parameters
{
    NSString *result = @"";
    if ([parameters isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in parameters) {
            result = [NSString stringWithFormat:@"%@%@%@",result,(result.length > 0 ? @"&" : @""),[self appendingURLParametersWithDictionary:dict]];
        }
    } else if ([parameters isKindOfClass:[NSDictionary class]]) {
        result = [self appendingURLParametersWithDictionary:parameters];
    }
    NSString *fullUrl = url;
    if ([self cacheKeyContainsBaseUrl]) {
        fullUrl = [NSString stringWithFormat:@"%@%@",[self baseURL],url];
    }
    result = [NSString stringWithFormat:@"%@%@%@",result,(result.length > 0 ? @"&" : @""), fullUrl];
    return [result KYN_MD5];
}
- (BOOL)cacheKeyContainsBaseUrl
{
    return YES;
}
//字典转url参数字符串
- (NSString *)appendingURLParametersWithDictionary:(NSDictionary *)dict
{
    NSString *result = @"";
    NSArray *sortKeys = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return ([obj1 integerValue] < [obj2 integerValue]) ? NSOrderedAscending : NSOrderedDescending;
  
    }];
    for (NSString *key in sortKeys) {
        NSString *separate = result.length > 0 ? @"&" : @"";
        result = [NSString stringWithFormat:@"%@%@%@=%@",result,separate,key,dict[key]];
    }
    return result;
}

- (void)cancelTastWithUrl:(NSString *)url
{
    [[KYHTTPGlobalManager shareManager] cancelTastWithUrl:url];
}

@end
