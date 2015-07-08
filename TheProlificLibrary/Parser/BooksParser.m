//
//  BooksParser.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "BooksParser.h"
#import "Book.h"

@interface BooksParser ()

+ (Book *)bookParser:(NSDictionary *)bookDetails;

@end

@implementation BooksParser

+ (NSArray *)getBookObjects:(NSArray *)responseBooks
{
    NSMutableArray *booksArray = [[NSMutableArray alloc] init];
    for(NSDictionary *bookDict in responseBooks)
    {
        Book *book = [BooksParser bookParser:bookDict];
        [booksArray addObject:book];
    }
    
    return booksArray;
}

+ (Book *)bookParser:(NSDictionary *)bookDetails
{
    Book *book = [[Book alloc] init];
    
    book.author = [bookDetails objectForKey:@"author"];
    book.categories = [bookDetails objectForKey:@"categories"];
    book.bookID = [[bookDetails objectForKey:@"id"] integerValue];
    
    if([bookDetails objectForKey:@"lastCheckedOut"] != [NSNull null])
        book.lastCheckedOut = [bookDetails objectForKey:@"lastCheckedOut"];
    else
        book.lastCheckedOut = nil;
    
    if([bookDetails objectForKey:@"lastCheckedOutBy"] != [NSNull null])
        book.lastCheckedOutBy = [bookDetails objectForKey:@"lastCheckedOutBy"];
    else
        book.lastCheckedOutBy = @"";
    book.publisher = [bookDetails objectForKey:@"publisher"];
    book.title = [bookDetails objectForKey:@"title"];
    book.url = [bookDetails objectForKey:@"url"];
    
    return book;
}


@end
