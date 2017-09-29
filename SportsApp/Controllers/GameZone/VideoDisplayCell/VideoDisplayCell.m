//
//  InviteOthersCell.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "VideoDisplayCell.h"

@implementation VideoDisplayCell

- (void)awakeFromNib {
    [super awakeFromNib];
       
    _btnRecord.clipsToBounds = YES;
    _btnRecord.layer.cornerRadius = 17.5f;
    _btnRecord.layer.borderWidth = 1.f;
    _btnRecord.layer.borderColor =[UIColor clearColor].CGColor;
    
    _vwNextTurn.clipsToBounds = YES;
    _vwNextTurn.layer.cornerRadius = 5.f;
    _vwNextTurn.layer.borderWidth = 1.f;
    _vwNextTurn.layer.borderColor = [UIColor clearColor].CGColor;
    _lblNextTurnName.text = @"Its your turn";
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
