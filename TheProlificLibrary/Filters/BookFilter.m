//
//  BookFilter.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/12/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "BookFilter.h"
#import "Book.h"

@interface BookFilter ()

+(NSSortDescriptor *)setSortDescripter:(NSString *)field orderOfField:(BOOL)orderField;

@end

@implementation BookFilter

/* This method accepts a field to search on and also based on order and checkedout field. Order is ascending and descending order. CheckedOutStatus to eliminiate books if lastCheckoutBy is not presented. */
+ (NSMutableArray *)filterArray:(NSArray *)toBeFilteredArray basedOn:(NSString *)field orderOfField:(BOOL)orderField andCheckOutStatus:(BOOL)checkoutStatus
{
    NSSortDescriptor *sortDescriptor = [BookFilter setSortDescripter:field orderOfField:orderField];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [toBeFilteredArray sortedArrayUsingDescriptors:sortDescriptors];
    if(checkoutStatus)
    {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"lastCheckedOutBy.length > 0"];
        sortedArray = [sortedArray filteredArrayUsingPredicate:resultPredicate];
    }
    return [NSMutableArray arrayWithArray:sortedArray];
}

/* This method returns a sort descriptor for ordering the books based on field. */
+ (NSSortDescriptor *)setSortDescripter:(NSString *)field orderOfField:(BOOL)orderField
{
    NSSortDescriptor *sortDescriptor;
    if([field isEqualToString:@"title"])
       sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:orderField];
    else if ([field isEqualToString:@"author"])
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"author" ascending:orderField];
    return sortDescriptor;
}

@end
