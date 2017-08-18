//
//  InviteOthersCell.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "UserCell.h"
#import "UserCollectionViewCell.h"

@interface UserCell(){
    
    IBOutlet UIButton *btnNext;
    IBOutlet UIButton *btnPrev;
    float frameWidth;
    int totalPages;
    int _currentPage;
    NSArray *players;
    NSInteger selectedIndex;
    
}

@end

@implementation UserCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
  
    // Initialization code
}

-(void)setDataSourceWithArray:(NSArray*)source{

    players = source;
    [_collectionView reloadData];
    
   
}

-(void)setUpPagingWithFrame:(float)width{
    
    btnNext.enabled = false;
    btnPrev.enabled = false;
    frameWidth = width;
    float collectionViewWidth = frameWidth - 30 - 80;
    float pages = floor ((players.count * 60 + players.count * 5) / collectionViewWidth) + 1;
    _currentPage = 0;
    totalPages = pages;
    if (pages > 1) {
        btnNext.enabled = true;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)_collectionView numberOfItemsInSection:(NSInteger)section
{
    return players.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.row < players.count) {
        NSDictionary *userInfo = players[indexPath.row];
        cell.imgBall.hidden = [[userInfo objectForKey:@"turn"] boolValue] ? false : true;
        cell.imgUser.layer.borderColor = [UIColor colorWithRed:0.97 green:0.89 blue:0.82 alpha:1.0].CGColor;
        [[cell indicator] startAnimating];
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   [[cell indicator] stopAnimating];
                                  
                               }];
        if (_selectedIndex == indexPath.row) {
              cell.imgUser.layer.borderColor = [UIColor redColor].CGColor;
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(60, 50);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _selectedIndex = indexPath.row;
    [collectionView reloadData];
    [[self delegate]userSelectedWithIndex:indexPath.row];
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = frameWidth - 30 - 80;
    float currentPage = _collectionView.contentOffset.x / pageWidth;
    int curentPage = 0;
    
    if (0.0f != fmodf(currentPage, 1.0f))
    {
        curentPage = currentPage + 1;
    }
    else
    {
        curentPage = currentPage;
    }
    btnNext.enabled = true;
    if (curentPage >= totalPages - 1) {
        btnNext.enabled = false;
    }
    btnPrev.enabled = false;
    if (curentPage > 0) {
        btnPrev.enabled = true;
    }
    _currentPage = curentPage;
    
}


-(IBAction)gotoNextOrPrevousPage:(UIButton*)sender{
    
    btnNext.enabled = true;
    btnPrev.enabled = true;
    int nextPage = _currentPage;
    if (sender.tag == 1) {
        nextPage = _currentPage + 1;
        if (nextPage >= totalPages){
            btnNext.enabled = false;
            return;
        }else{
            _currentPage ++;
        }
    }else{
        
        nextPage = _currentPage - 1;
        if (nextPage < 0){
            btnPrev.enabled = false;
            return;
        }else{
            _currentPage --;
        }
    }
    
    [self setButtonAvailability];
    float width = frameWidth - 30 - 80;
    CGRect frame = CGRectMake(40, 0, width, 50);
    frame.origin.x = frame.size.width * nextPage;
    [_collectionView scrollRectToVisible:frame animated:YES];
    
}

-(void)setButtonAvailability{
    
    btnNext.enabled = true;
    if (_currentPage >= totalPages - 1) {
        btnNext.enabled = false;
    }
    btnPrev.enabled = false;
    if (_currentPage > 0) {
        btnPrev.enabled = true;
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
