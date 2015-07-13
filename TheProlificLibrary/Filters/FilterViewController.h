//
//  FilterViewController.h
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/12/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterViewProtocol <NSObject>

- (void)resetAllFilterPressed;
- (void)filteredResults:(NSMutableArray *)filterResults;
- (void)deleteBooks;

@end

@interface FilterViewController : UIViewController

@property (nonatomic, weak) id<FilterViewProtocol> filterDelegate;

@property (nonatomic, strong) NSMutableArray *bookTempArray;

@end
