//
//  InviteOthersCell.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;

-(void)setDataSourceWithArray:(NSArray*)source;
-(void)setUpPagingWithFrame:(float)width;



@end
