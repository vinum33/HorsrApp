//
//  InviteOthersCell.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "ScoreBoardCell.h"
#import "ScoreCollectionViewCell.h"

@interface ScoreBoardCell(){
    
    float frameWidth;
    NSArray *arrPlayers;
}

@end

@implementation ScoreBoardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

-(void)setDataSourceWithArray:(NSArray*)source{
    
    arrPlayers = source;
    [_collectionView reloadData];
    if (_selectedIndex < arrPlayers.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
   
}

-(void)setUpPagingWithFrame:(float)width{
    
    frameWidth = width;
    
    
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)_collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrPlayers.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ScoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ScoreCollectionViewCell" forIndexPath:indexPath];
    [cell setUpBgWithFrame:frameWidth];
    if (indexPath.row < arrPlayers.count) {
        NSDictionary *userInfo = arrPlayers[indexPath.row];
        [cell setScoreWithLetters:[userInfo objectForKey:@"score"] andGameType:[[userInfo objectForKey:@"gametype_id"] integerValue]];
        cell.imgUser.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.lblUserName.text = [userInfo objectForKey:@"name"];
        [[cell indicator] startAnimating];
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   [[cell indicator] stopAnimating];
                                   
                               }];
        
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(frameWidth, 80);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [[self delegate]scoreBoardSelectedWithIndex:indexPath.row];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



@end
