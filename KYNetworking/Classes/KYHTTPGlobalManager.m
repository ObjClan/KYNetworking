//
//  KYHTTPGlobalManager.m
//  KYNetworking
//
//  Created by Key on 06/06/2019.
//  Copyright © 2019 Key. All rights reserved.
//

#import "KYHTTPGlobalManager.h"

@interface KYHTTPGlobalManager ()
@property (nonatomic, strong) NSMutableArray<NSURLSessionTask *> *allTaskArray;
@property (nonatomic, strong) dispatch_semaphore_t taskLock;
@end
@implementation KYHTTPGlobalManager
@synthesize allTaskArray = _allTaskArray;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    static KYHTTPGlobalManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        _manager = [[KYHTTPGlobalManager alloc] init];
    });
    return _manager;
}
- (NSMutableArray<NSURLSessionTask *> *)allTaskArray
{
    if (!_allTaskArray) {
        _allTaskArray = [[NSMutableArray alloc] init];
    }
    return _allTaskArray;
}
- (void)setAllTaskArray:(NSMutableArray<NSURLSessionTask *> *)allTaskArray
{
    dispatch_semaphore_wait(self.taskLock, DISPATCH_TIME_FOREVER);
    _allTaskArray = allTaskArray;
    dispatch_semaphore_signal(self.taskLock);
}
- (dispatch_semaphore_t)taskLock
{
    if (!_taskLock) {
        _taskLock = dispatch_semaphore_create(1);
    }
    return _taskLock;
}
- (void)addTask:(NSURLSessionTask *)task
{
    dispatch_semaphore_wait(self.taskLock, DISPATCH_TIME_FOREVER);
    [self.allTaskArray addObject:task];
    dispatch_semaphore_signal(self.taskLock);
}
- (void)removeTask:(NSURLSessionTask *)task
{
    dispatch_semaphore_wait(self.taskLock, DISPATCH_TIME_FOREVER);
    [self.allTaskArray removeObject:task];
    dispatch_semaphore_signal(self.taskLock);
}
- (BOOL)hasSameUrl:(NSString *)url
{
    dispatch_semaphore_wait(self.taskLock, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < self.allTaskArray.count; i++) {
        NSURLSessionTask *task = self.allTaskArray[i];
        NSString *path = task.currentRequest.URL.path;
        if (![url hasPrefix:@"/"]) {
            path = [path substringFromIndex:1];
        }
        if ([url isEqualToString:path]) {
            dispatch_semaphore_signal(self.taskLock);
            return YES;
        }
    }
    dispatch_semaphore_signal(self.taskLock);
    return NO;
}
- (void)cancelTastWithUrl:(NSString *)url
{
    dispatch_semaphore_wait(self.taskLock, DISPATCH_TIME_FOREVER);
    for (int i = 0; i < self.allTaskArray.count; i++) {
        NSURLSessionTask *task = self.allTaskArray[i];
        NSString *path = task.currentRequest.URL.path;
        if ([url isEqualToString:path]) {
            [task cancel];
            break;
        }
    }
    dispatch_semaphore_signal(self.taskLock);
}
@end
