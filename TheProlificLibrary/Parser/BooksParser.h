//
//  BooksParser.h
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BooksParser : NSObject

+ (NSArray *)getBookObjects:(NSArray *)responseBooks;

@end
