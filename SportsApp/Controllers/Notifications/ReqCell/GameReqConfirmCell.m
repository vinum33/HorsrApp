//
//  PlayReqTableViewCell.m
//  SportsApp
//
//  Created by Purpose Code on 18/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "GameReqConfirmCell.h"

@implementation GameReqConfirmCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   
    
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 25.f;
    _imgUser.layer.borderWidth = 1.f;
    _imgUser.backgroundColor = [UIColor whiteColor];
    _imgUser.layer.borderColor = [UIColor clearColor].CGColor;
    
    _btnConfirm.clipsToBounds = YES;
    _btnConfirm.layer.cornerRadius = 5.f;
    _btnConfirm.layer.borderWidth = 1.f;
    _btnConfirm.layer.borderColor = [UIColor clearColor].CGColor;
    
}
-(IBAction)showProfile:(UIButton*)sender{
    
    [self.delegate profileButtonClickedWithColumn:_column row:_row];
    
}

-(IBAction)acceptOrRejectRequest:(UIButton*)sender{
    
    [self.delegate cellClickedWithColumn:_column row:_row type:sender.tag];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
