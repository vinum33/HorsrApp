//
//  InviteOthersCell.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

@protocol ScoreBoardCellDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)scoreBoardSelectedWithIndex:(NSInteger)index;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end

#import <UIKit/UIKit.h>

@interface ScoreBoardCell : UITableViewCell


@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,weak)  id<ScoreBoardCellDelegate>delegate;
@property (nonatomic,assign)  NSInteger selectedIndex;

-(void)setDataSourceWithArray:(NSArray*)source;
-(void)setUpPagingWithFrame:(float)width;


@end
