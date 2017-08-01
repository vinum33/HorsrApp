//
//  RegistrationPageCustomTableViewCell.m
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "RegistrationPageCustomTableViewCell.h"

@implementation RegistrationPageCustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _btnFemale.layer.borderColor = [[UIColor getThemeColor] CGColor];
    _btnFemale.layer.borderWidth = 1.0f;
    _btnFemale.layer.cornerRadius = 25.0f;
    
    _btnMale.layer.borderColor = [[UIColor getThemeColor] CGColor];
    _btnMale.layer.borderWidth = 1.0f;
    _btnMale.layer.cornerRadius = 25.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
