//
//  AlertViewController.h
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/11/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlertViewDismissProtocol <NSObject>

- (void)dismissAlertView:(NSInteger)buttonPressedValue withText:(NSString *)textString;

@end

@interface AlertViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (weak, nonatomic) IBOutlet UIView *alertView;

@property (nonatomic, weak) id<AlertViewDismissProtocol> alertDelegate;

- (void)performAnimation;

@end
