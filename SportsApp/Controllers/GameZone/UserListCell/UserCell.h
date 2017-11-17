//
//  InviteOthersCell.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

@protocol UserCellDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)userSelectedWithIndex:(NSInteger)index;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

-(void)skipUserWithIndex:(NSInteger)index;


@end

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,weak)  id<UserCellDelegate>delegate;
@property (nonatomic,assign)  NSInteger selectedIndex;
@property (nonatomic,strong)  NSString *trickOwnerID;

-(void)setDataSourceWithArray:(NSArray*)source;
-(void)setUpPagingWithFrame:(float)width;



@end
