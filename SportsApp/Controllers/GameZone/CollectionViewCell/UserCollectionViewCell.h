//
//  CollectionViewCell.h
//  SportsApp
//
//  Created by Purpose Code on 27/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCollectionViewCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UIImageView *imgBall;
@property (nonatomic,weak) IBOutlet UIImageView *imgHorseOrPig;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;

@end
