//
//  CustomBookCell.m
//  TheProlificLibrary
//
//  Created by Raghav Sai Cheedalla on 7/7/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import "CustomBookCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomBookCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(NSString *)bookTitle andAuthor:(NSString *)bookAuthor andImageNum:(int)imageNum;
{
    self.lblBookTitle.text = bookTitle;
    self.lblBookAuthor.text = bookAuthor;
    [self designUI];
    self.bookImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"image%d.jpg",imageNum]];
//    self.bookImage.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)designUI
{
    self.bookDetailsView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.bookDetailsView.layer.shadowRadius = 2.0f;
}

- (void)prepareForReuse
{
    self.lblBookAuthor.text = @"";
    self.lblBookTitle.text = @"";
    self.bookImage.image = nil;
}


@end
