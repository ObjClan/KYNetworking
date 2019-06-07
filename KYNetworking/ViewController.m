//
//  ViewController.m
//  KYNetworking
//
//  Created by Key on 16/04/2019.
//  Copyright © 2019 Key. All rights reserved.
//

#import "ViewController.h"
#import "HttpManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"phone"] = @"13211111111";
    params[@"callback"] = @"phone";
    params[@"cmd"] = @"1059";
    HttpManager *manager = [HttpManager manager];
    //POST
    manager.method = KYHTTPMethodPOST;
    //使用缓存
    [manager sendRequestWithUrl:@"callback"
                                        parameters:params cache:YES
                                      cacheTimeout:10
                                          callBack:^(BOOL isCache, id  _Nullable response, NSError * _Nullable error) {
        
    } originCallBack:nil];
    // 默认GET
    //使用缓存
    [[HttpManager manager] sendRequestWithUrl:@"callback"
                     parameters:params cache:YES
                   cacheTimeout:10
                       callBack:^(BOOL isCache, id  _Nullable response, NSError * _Nullable error) {
                           
                       } originCallBack:nil];
    
    //不允许重复请求
    for (int i = 0; i < 100; i++) {
        [[HttpManager manager] sendRequestWithUrl:@"callback"
                                            parameters:params
                                          denyRepeated:YES
                                              callBack:^(id  _Nullable response, NSError * _Nullable error) {
            
        }];
    }
    
}


@end
