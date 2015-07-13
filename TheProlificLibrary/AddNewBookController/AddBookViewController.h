//
//  AddBookViewController.h
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddBookProtocol <NSObject>

- (void)bookAdded;

@end

@interface AddBookViewController : UIViewController

@property (nonatomic, weak) id<AddBookProtocol> addBookDelegate;

@end
