//
//  CollectionViewCell.h
//  SportsApp
//
//  Created by Purpose Code on 27/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabCollectionViewCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imgMenu;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblValue;
@property (nonatomic,weak) IBOutlet UIView *vwSeperator;

@end
