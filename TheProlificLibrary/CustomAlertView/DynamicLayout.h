//
//  DynamicLayout.h
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/12/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DynamicLayout : NSObject<UIDynamicItem>

@property(nonatomic, readonly) CGRect bounds;
@property(nonatomic, readwrite) CGPoint center;
@property(nonatomic, readwrite) CGAffineTransform transform;

+(instancetype)with:(UIView *)view;


@end
