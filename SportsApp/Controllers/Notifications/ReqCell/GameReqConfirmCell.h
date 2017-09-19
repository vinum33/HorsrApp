//
//  PlayReqTableViewCell.h
//  SportsApp
//
//  Created by Purpose Code on 18/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

@protocol RequestCellDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)cellClickedWithColumn:(NSInteger)column row:(NSInteger)row type:(NSInteger)type;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end

#import <UIKit/UIKit.h>

@interface GameReqConfirmCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UILabel *lblMessage;
@property (nonatomic,weak) IBOutlet UILabel *lblStatusMessage;
@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UIButton *btnConfirm;
@property (nonatomic,weak) IBOutlet UIButton *btnCancel;
@property (nonatomic,assign) NSInteger column;
@property (nonatomic,assign) NSInteger row;

@property (nonatomic,weak)  id<RequestCellDelegate>delegate;

@end
