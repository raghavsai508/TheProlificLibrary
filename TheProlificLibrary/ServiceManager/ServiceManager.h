//
//  ServiceManager.h
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServiceProtocol

@optional

- (void)serviceCallCompletedWithResponseObject:(id)response withResponseCode:(NSInteger)responseStatusCode;
- (void)serviceCallCompletedWithError:(NSError *)error;

@end

@interface ServiceManager : NSObject

+ (ServiceManager *)defaultManager;

- (void)serviceCallWithURL:(NSString *)URL andParameters:(NSDictionary *)params andRequestMethod:(NSString *)requestMethod;
- (void)getBooks;

@property (nonatomic,weak) id<ServiceProtocol> serviceDelegate;


@end
