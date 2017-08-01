//
//  PlayReqTableViewCell.m
//  SportsApp
//
//  Created by Purpose Code on 18/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "PlayerListTableViewCell.h"

@implementation PlayerListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _btnAddFrnd.clipsToBounds = YES;
    _btnAddFrnd.layer.cornerRadius = 5.f;
    _btnAddFrnd.layer.borderWidth = 1.f;
    _btnAddFrnd.layer.borderColor = [UIColor getBorderColor].CGColor;
    
    _btnCancel.clipsToBounds = YES;
    _btnCancel.layer.cornerRadius = 5.f;
    _btnCancel.layer.borderWidth = 1.f;
    _btnCancel.layer.borderColor = [UIColor clearColor].CGColor;
    
    _btnAcept.clipsToBounds = YES;
    _btnAcept.layer.cornerRadius = 5.f;
    _btnAcept.layer.borderWidth = 1.f;
    _btnAcept.layer.borderColor = [UIColor clearColor].CGColor;
    
    
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
