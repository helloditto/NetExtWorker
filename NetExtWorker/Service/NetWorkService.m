//
//  NetWorkService.m
//  NetExtWorker
//
//  Created by Xuan Liu on 6/30/16.
//  Copyright © 2016 App Annie. All rights reserved.
//

#import "NetWorkService.h"
#import "AFNetworking.h"

@implementation NetWorkService

+(instancetype)sharedInstance {
    static NetWorkService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetWorkService alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Used sharedInstance or use NETWorkServiceClient macro" userInfo:nil];
}

-(void)GET:(nonnull NSString *)urlString success:(nullable successHandler)success failure:(nullable failureHandler)failure {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (success)
            success(result);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure)
            failure(error);
    }];
}

@end
