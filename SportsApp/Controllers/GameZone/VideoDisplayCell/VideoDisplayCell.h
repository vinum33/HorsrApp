//
//  InviteOthersCell.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoDisplayCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imgThumb;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *constarintImgHeight;
@property (nonatomic,weak) IBOutlet UIButton *btnRecord;
@property (nonatomic,weak) IBOutlet UIButton *btnVideoPlay;

@property (nonatomic,weak) IBOutlet UIButton *btnSuccess;
@property (nonatomic,weak) IBOutlet UIButton *btnFailure;

@property (nonatomic,weak) IBOutlet UIView *vwNextTurn;
@property (nonatomic,weak) IBOutlet UILabel *lblNextTurnName;


@end
