//
//  PlayReqTableViewCell.h
//  SportsApp
//
//  Created by Purpose Code on 18/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationCellDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)profileBtnClickedWithRow:(NSInteger)row andColumn:(NSInteger)row;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end


@interface NotificationsCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblDate;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UIButton *btnProfile;
@property (nonatomic,weak)  id<NotificationCellDelegate>delegate;

@end
