//
//  PlayReqTableViewCell.m
//  SportsApp
//
//  Created by Purpose Code on 18/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "FriendRequestsCell.h"

@implementation FriendRequestsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
    _btnConfirm.clipsToBounds = YES;
    _btnConfirm.layer.cornerRadius = 5.f;
    _btnConfirm.layer.borderWidth = 1.f;
    _btnConfirm.layer.borderColor = [UIColor clearColor].CGColor;
    
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 25.f;
    _imgUser.layer.borderWidth = 1.f;
    _imgUser.backgroundColor = [UIColor whiteColor];
    _imgUser.layer.borderColor = [UIColor clearColor].CGColor;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
