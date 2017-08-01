//
//  InviteOthersCell.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "ScoreBoardCell.h"

@implementation ScoreBoardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    float width = self.contentView.frame.size.width - 20;
    UIColor *topColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.16 alpha:1.0];
    UIColor * bottomColor = [UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, width, 80);
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);

    [_vwScoreBG.layer addSublayer:gradient];
    [_vwScoreBG.layer insertSublayer:gradient atIndex:0];
    
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 25.f;
    _imgUser.layer.borderWidth = 2.f;
    _imgUser.backgroundColor = [UIColor clearColor];
    _imgUser.layer.borderColor =[UIColor colorWithRed:0.97 green:0.89 blue:0.82 alpha:1.0].CGColor;
    

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
