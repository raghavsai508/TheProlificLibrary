//
//  CustomBookCell.h
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBookCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblBookTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBookAuthor;
@property (weak, nonatomic) IBOutlet UIImageView *bookImage;
@property (weak, nonatomic) IBOutlet UIView *bookDetailsView;


- (void)configureCell:(NSString *)bookTitle andAuthor:(NSString *)bookAuthor andImageNum:(int)imageNum;

@end
