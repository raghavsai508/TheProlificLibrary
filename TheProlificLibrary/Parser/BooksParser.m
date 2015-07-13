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
+ (NSString *)parseDate:(NSString *)dateString;


@end

@implementation BooksParser

/* This method is retreives the number of Book objects. */
+ (NSMutableArray *)getBookObjects:(NSArray *)responseBooks
{
    NSMutableArray *booksArray = [[NSMutableArray alloc] init];
    for(NSDictionary *bookDict in responseBooks)
    {
        Book *book = [BooksParser bookParser:bookDict];
        [booksArray addObject:book];
    }
    
    return booksArray;
}

/* This method is reponsible for parsing the book details got from the server. */
+ (Book *)bookParser:(NSDictionary *)bookDetails
{
    Book *book = [[Book alloc] init];
    
    book.author = [bookDetails objectForKey:@"author"];
    book.categories = [bookDetails objectForKey:@"categories"];
    book.bookID = [[bookDetails objectForKey:@"id"] integerValue];
    
    if([bookDetails objectForKey:@"lastCheckedOut"] != [NSNull null])
    {
        book.lastCheckedOut = [self parseDate:[bookDetails objectForKey:@"lastCheckedOut"]];
    }
    else
        book.lastCheckedOut = nil;
    
    if([bookDetails objectForKey:@"lastCheckedOutBy"] != [NSNull null])
    {
        book.lastCheckedOutBy = [NSString stringWithFormat:@"%@ @ %@",[bookDetails objectForKey:@"lastCheckedOutBy"],book.lastCheckedOut];
    }
    else
        book.lastCheckedOutBy = @"";
    book.publisher = [bookDetails objectForKey:@"publisher"];
    book.title = [bookDetails objectForKey:@"title"];
    book.url = [bookDetails objectForKey:@"url"];
    
    return book;
}

/* This method converts date into month name, date and time format. */
+ (NSString *)parseDate:(NSString *)dateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormat dateFromString:dateString];
    NSLog(@"%@",[dateFormat dateFromString:dateString]);
    [dateFormat setDateStyle:NSDateFormatterLongStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    
    NSLog(@"%@",[dateFormat stringFromDate:date]);
    return [dateFormat stringFromDate:date];
}

@end
