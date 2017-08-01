//
//  AwarenessHeader.m
//  PurposeColor
//
//  Created by Purpose Code on 03/04/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "PeopleListHeader.h"

@implementation PeopleListHeader

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
    _imgUser.layer.cornerRadius = 40.f;
    _imgUser.layer.borderWidth = 3.f;
    _imgUser.backgroundColor = [UIColor whiteColor];
    _imgUser.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _vwRegHolder.clipsToBounds = YES;
    _vwRegHolder.layer.cornerRadius = 15.f;
    _vwRegHolder.layer.borderWidth = 1.f;
    _vwRegHolder.layer.borderColor = [UIColor clearColor].CGColor;
}

-(void)FDG{
    
    
}

@end
