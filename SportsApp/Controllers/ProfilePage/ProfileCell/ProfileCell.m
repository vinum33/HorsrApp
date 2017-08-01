//
//  InviteOthersCell.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "ProfileCell.h"

@implementation ProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 40.f;
    _imgUser.layer.borderWidth = 5.f;
    _imgUser.backgroundColor = [UIColor clearColor];
    _imgUser.layer.borderColor =[UIColor colorWithRed:0.97 green:0.89 blue:0.82 alpha:1.0].CGColor;
    
    _vwReg.layer.cornerRadius = 13.f;
    _vwReg.layer.borderWidth = 1.f;
    _vwReg.layer.borderColor =[UIColor clearColor].CGColor;
    
    _txtField.layer.cornerRadius = 15.f;
    _txtField.layer.borderWidth = 1.f;
    _txtField.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    
    _vwLocation.layer.cornerRadius = 5.f;
    _vwLocation.layer.borderWidth = 1.f;
    _vwLocation.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    
    
    
    

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
