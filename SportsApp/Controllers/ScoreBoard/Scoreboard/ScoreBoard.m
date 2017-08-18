//
//  AwarenessHeader.m
//  PurposeColor
//
//  Created by Purpose Code on 03/04/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "ScoreBoard.h"

@interface ScoreBoard(){
    
    IBOutlet UIView *vwGB;

    
    
    
}

@end

@implementation ScoreBoard

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    
    [super awakeFromNib];
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 50.f;
    _imgUser.layer.borderWidth = 1.f;
    _imgUser.layer.borderColor = [UIColor clearColor].CGColor;
    
    vwGB.clipsToBounds = YES;
    vwGB.layer.cornerRadius = 5.f;
    vwGB.layer.borderWidth = 1.f;
    vwGB.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    

    
}


 


@end
