//
//  ServiceManager.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "ServiceManager.h"
#import "AFNetworking.h"

@interface ServiceManager()

@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSMutableArray *requestQueue;
@property (nonatomic, assign) SecTrustResultType trustResult;


@end

@implementation ServiceManager


+ (ServiceManager *)defaultManager
{
    static ServiceManager *defaultManager;
    @synchronized(self)
    {
        if (!defaultManager)
            defaultManager = [[ServiceManager alloc] init];
        return defaultManager;
    }
}

- (NSMutableArray *)requestQueue
{
    if(!_requestQueue)
        _requestQueue = [[NSMutableArray alloc] init];
    
    return _requestQueue;
}

- (AFHTTPRequestOperationManager *)manager
{
    if(!_manager)
    {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.securityPolicy.allowInvalidCertificates = YES;
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",nil];
    }
    
    return _manager;
}

- (void)getRequestCallWithURL:(NSString *)URL
{
    [self.manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.serviceDelegate serviceCallCompletedWithResponseObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.serviceDelegate serviceCallCompletedWithError:error];
    }];
}

- (void)serviceCallWithURL:(NSString *)URL andParameters:(NSDictionary *)params
{
    if(params)
        [self postRequestCallWithURL:URL andParameters:params];
    else
        [self getRequestCallWithURL:URL];
}

- (void)postRequestCallWithURL:(NSString *)URL andParameters:(NSDictionary *)params
{
    [self.manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.serviceDelegate serviceCallCompletedWithResponseObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.serviceDelegate serviceCallCompletedWithError:error];
    }];
}



@end
