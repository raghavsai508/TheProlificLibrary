//
//  Book.h
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

/* These are the properties of the Book object. */
@property (nonatomic, strong) NSString      *author;
@property (nonatomic, strong) NSString      *categories;
@property (nonatomic, assign) NSInteger     bookID;
@property (nonatomic, strong) NSString      *lastCheckedOut;
@property (nonatomic, strong) NSString      *lastCheckedOutBy;
@property (nonatomic, strong) NSString      *publisher;
@property (nonatomic, strong) NSString      *title;
@property (nonatomic, strong) NSString      *url;

@end
