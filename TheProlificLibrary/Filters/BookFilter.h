//
//  BookFilter.h
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/12/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookFilter : NSObject

+ (NSMutableArray *)filterArray:(NSArray *)toBeFilteredArray basedOn:(NSString *)field orderOfField:(BOOL)orderField andCheckOutStatus:(BOOL)checkoutStatus;

@end
