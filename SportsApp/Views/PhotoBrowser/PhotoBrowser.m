//
//  PhotoBrowser.m
//  PurposeColor
//
//  Created by Purpose Code on 08/09/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "PhotoBrowser.h"
#import "PhotoBrowserCell.h"

@interface PhotoBrowser(){
    
    IBOutlet UICollectionView *collectionView;
    IBOutlet UILabel *lblTitle;
    NSArray *arrDataSource;
    UIImage *activeImage;
    IBOutlet UIButton *btnDownload;
}

@end

@implementation PhotoBrowser

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setUpWithImages:(NSArray*)images{
    
    arrDataSource = images;
    [collectionView registerNib:[UINib nibWithNibName:@"PhotoBrowserCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoBrowserCell"];
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView reloadData];
    btnDownload.hidden = true;
    
}



#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
     return  1;
}

-(NSInteger)collectionView:(UICollectionView *)_collectionView numberOfItemsInSection:(NSInteger)section
{
    lblTitle.text = [NSString stringWithFormat:@"%d/%lu",1,(unsigned long)arrDataSource.count];
    return  arrDataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    btnDownload.hidden = false;
    PhotoBrowserCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoBrowserCell" forIndexPath:indexPath];
    if (indexPath.row < arrDataSource.count) {
        [cell.indicator stopAnimating];
        [cell resetCell];
        id urlType = arrDataSource[indexPath.row];
        if ([urlType isKindOfClass:[NSString class]]) {
            NSString *strURL = arrDataSource[indexPath.row];
            [cell.indicator startAnimating];
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:strURL]
                              placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         activeImage = image;
                                         cell.image = image;
                                         [cell setup];
                                         [cell.indicator stopAnimating];
                                         
                                         
                                     }];
        }else if ([urlType isKindOfClass:[UIImage class]]){
            
            UIImage *galleryImage = (UIImage*) arrDataSource[indexPath.row];
            cell.imageView.image = galleryImage;
            activeImage = galleryImage;
            cell.image = galleryImage;
            [cell setup];
        }
        
    }
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float width = _collectionView.bounds.size.width;
    float height = _collectionView.bounds.size.height;
    
    return CGSizeMake(width, height);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    lblTitle.text = [NSString stringWithFormat:@"%ld/%lu",(long)page + 1,(unsigned long)arrDataSource.count];
}





-(IBAction)sharewImage:(id)sender{
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *nav;
        nav = (UINavigationController*) delegate.window.rootViewController;
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSArray *objectsToShare = @[activeImage];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
   // [delegate.window.rootViewController presentViewController:activityVC animated:YES completion:nil];
     [app.revealController presentViewController:activityVC animated:YES completion:^{}];
    
    
}

-(IBAction)saveImage:(id)sender{
    
   
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *nav;
    nav = (UINavigationController*) delegate.window.rootViewController;
       UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save"
                                                                   message:@"Do you want to save image to gallery ?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"YES"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                  UIImageWriteToSavedPhotosAlbum(activeImage, nil, nil, nil);
                                                              });
                                                              [ALToastView toastInView:self withText:@"Saved image to gallery"];
                                                              
                                                          }];
    UIAlertAction *second = [UIAlertAction actionWithTitle:@"NO"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     }];
    
    [alert addAction:firstAction];
    [alert addAction:second];
    [nav presentViewController:alert animated:YES completion:nil];
    
   
    
}
-(IBAction)closePopUp:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(closePhotoBrowserView)]) {
        [self.delegate closePhotoBrowserView];
    }
    
}

-(void)dealloc{
    
}

@end
