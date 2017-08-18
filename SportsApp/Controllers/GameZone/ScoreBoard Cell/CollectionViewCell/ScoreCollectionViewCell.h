//
//  CollectionViewCell.h
//  SportsApp
//
//  Created by Purpose Code on 27/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreCollectionViewCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UILabel *lblUserName;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,weak) IBOutlet UILabel *lblScore;
@property (nonatomic,weak) IBOutlet UIView *vwBG;

-(void)setUpBgWithFrame:(float)frame;
-(void)setScoreWithLetters:(NSString*)letters andGameType:(NSInteger)gameType;

@end
