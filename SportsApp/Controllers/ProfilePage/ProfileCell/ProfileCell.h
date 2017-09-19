//
//  InviteOthersCell.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIView *vwLocation;
@property (nonatomic,weak) IBOutlet UIView *vwReg;
@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UILabel *lblLoc;
@property (nonatomic,weak) IBOutlet UILabel *lblEmail;
@property (nonatomic,weak) IBOutlet UILabel *lblRegStatus;
@property (nonatomic,weak) IBOutlet UIButton *btnStatistics;

@property (nonatomic,weak) IBOutlet UITextField *txtField;


@end
