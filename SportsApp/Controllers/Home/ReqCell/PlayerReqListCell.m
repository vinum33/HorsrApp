//
//  PlayReqTableViewCell.m
//  SportsApp
//
//  Created by Purpose Code on 18/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "PlayerReqListCell.h"

@interface PlayerReqListCell(){
    
    BOOL isOpened;
    IBOutlet UIView *vwHolder;
}

@end

@implementation PlayerReqListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    isOpened = false;
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 25.f;
    _imgUser.layer.borderWidth = 1.f;
    _imgUser.backgroundColor = [UIColor whiteColor];
    _imgUser.layer.borderColor = [UIColor clearColor].CGColor;
    
    vwHolder.layer.cornerRadius = 5.f;
    vwHolder.layer.borderWidth = 1.f;
    vwHolder.backgroundColor = [UIColor whiteColor];
    vwHolder.layer.borderColor = [UIColor clearColor].CGColor;

    
    UIColor *topColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.16 alpha:1.0];
    UIColor * bottomColor = [UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, vwHolder.frame.size.width, vwHolder.frame.size.height);
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);

    [vwHolder.layer addSublayer:gradient];
    [vwHolder.layer insertSublayer:gradient atIndex:0];
    
}

-(IBAction)expandOrCollapseMenu:(id)sender{
    
    if (isOpened) {
        _trailingForButton.constant = 0.0f;
        isOpened = false;
    }else{
        _trailingForButton.constant = 80.0f;
         isOpened = true;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self layoutIfNeeded];
        
    }];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
