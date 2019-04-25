//
//  KYHttpResponseModel.m
//  KYNetworking
//
//  Created by Key on 23/04/2019.
//  Copyright © 2019 Key. All rights reserved.
//

#import "KYHttpResponseModel.h"

@implementation KYHttpResponseModel
/**
 忽略存储的键
 */
+ (NSArray *)bg_ignoreKeys
{
    return @[@"description"];
}
//唯一约束
+(NSArray *)bg_uniqueKeys{
    return @[@"cacheKey"];
}
@end
