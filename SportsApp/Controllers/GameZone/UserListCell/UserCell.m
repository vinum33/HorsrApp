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
    
}

@end

@implementation UserCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
  
    // Initialization code
}

-(void)setDataSourceWithArray:(NSArray*)source{

    [_collectionView reloadData];
    
   
}

-(void)setUpPagingWithFrame:(float)width{
    
    btnNext.enabled = false;
    btnPrev.enabled = false;
    frameWidth = width;
    float collectionViewWidth = frameWidth - 30 - 80;
    float pages = floor ((10*60 + 10*5) / collectionViewWidth) + 1;
    _currentPage = 0;
    totalPages = pages;
    if (pages > 0) {
        btnNext.enabled = true;
    }
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)_collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionViewCell" forIndexPath:indexPath];
    [[cell indicator] startAnimating];
    [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[User sharedManager].profileurl]
                    placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                               [[cell indicator] stopAnimating];
                           }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(60, 50);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
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
