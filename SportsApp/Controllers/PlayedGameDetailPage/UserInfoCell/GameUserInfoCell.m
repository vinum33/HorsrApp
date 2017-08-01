//
//  InviteOthersCell.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "GameUserInfoCell.h"

@implementation GameUserInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 25.f;
    _imgUser.layer.borderWidth = 3.f;
    _imgUser.backgroundColor = [UIColor whiteColor];
    _imgUser.layer.borderColor = [UIColor getSeperatorColor].CGColor;

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
