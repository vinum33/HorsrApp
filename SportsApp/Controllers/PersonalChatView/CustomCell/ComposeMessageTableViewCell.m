//
//  ComposeMessageTableViewCell.m
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "ComposeMessageTableViewCell.h"

@implementation ComposeMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 20.f;
    _imgUser.layer.borderWidth = 1.f;
    _imgUser.backgroundColor = [UIColor whiteColor];
    _imgUser.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
