//
//  CustomCellForLogin.m
//  SignSpot
//
//  Created by Purpose Code on 17/06/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "CustomCellForLogin.h"

@implementation CustomCellForLogin

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    _borderBG.layer.borderColor = [[UIColor getBorderColor] CGColor];
    _borderBG.layer.borderWidth = 1.0f;
    _borderBG.layer.cornerRadius = 20.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
