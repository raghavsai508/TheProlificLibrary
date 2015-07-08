//
//  CustomBookCell.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "CustomBookCell.h"

@implementation CustomBookCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(NSString *)bookTitle andAuthor:(NSString *)bookAuthor;
{
    self.lblBookTitle.text = bookTitle;
    self.lblBookAuthor.text = bookAuthor;
}


@end
