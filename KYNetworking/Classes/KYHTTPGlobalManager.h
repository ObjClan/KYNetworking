//
//  KYHTTPGlobalManager.h
//  KYNetworking
//
//  Created by Key on 06/06/2019.
//  Copyright © 2019 Key. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYHTTPGlobalManager : NSObject

+ (instancetype)shareManager;
- (BOOL)hasSameUrl:(NSString *)url;
- (void)cancelTastWithUrl:(NSString *)url;
- (void)addTask:(NSURLSessionTask *)task;
- (void)removeTask:(NSURLSessionTask *)task;
@end

NS_ASSUME_NONNULL_END
