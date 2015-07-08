//
//  ServiceURLProvider.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "ServiceURLProvider.h"

#define base_url @"http://prolific-interview.herokuapp.com/559c0fe787ed0e000927063e"

@implementation ServiceURLProvider

+(NSString *)getURLForServiceWithKey:(NSString *)key
{
    NSString *returnString = [NSString stringWithFormat:@"%@%@",base_url,key];
    return returnString;
}


@end
