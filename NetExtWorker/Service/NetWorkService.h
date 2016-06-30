//
//  NetWorkService.h
//  NetExtWorker
//
//  Created by Xuan Liu on 6/30/16.
//  Copyright © 2016 App Annie. All rights reserved.
//

#define NETWorkServiceClient [NetWorkService sharedInstance]

#import <Foundation/Foundation.h>

typedef void (^successHandler)(id _Nullable result);
typedef void (^failureHandler)(NSError * _Nonnull error);
/**
 *    Use NETWorkServiceClient as convinient property to get the shared instance
 *
 */
@interface NetWorkService : NSObject

+(nonnull instancetype)sharedInstance;

-(void)GET:(nonnull NSString *)urlString success:(nullable successHandler)success failure:(nullable failureHandler)failure;

@end
