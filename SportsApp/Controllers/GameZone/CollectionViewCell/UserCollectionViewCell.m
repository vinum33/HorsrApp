//
//  CollectionViewCell.m
//  SportsApp
//
//  Created by Purpose Code on 27/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "UserCollectionViewCell.h"

@implementation UserCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 25.f;
    _imgUser.layer.borderWidth = 2.f;
    _imgUser.backgroundColor = [UIColor clearColor];
    _imgUser.layer.borderColor = [UIColor colorWithRed:0.97 green:0.89 blue:0.82 alpha:1.0].CGColor;
    
    
    
    // Initialization code
}




@end
