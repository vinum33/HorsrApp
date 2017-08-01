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
    

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
