//
//  PlayReqTableViewCell.h
//  SportsApp
//
//  Created by Purpose Code on 18/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerReqListCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIView *vwBG;
@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UIImageView *imgThumb;
@property (nonatomic,weak) IBOutlet UILabel *lblKey;
@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UILabel *lblLocation;
@property (nonatomic,weak) IBOutlet UILabel *lblDateTime;
@property (nonatomic,weak) IBOutlet UIButton *btnPlayVideo;
@property (nonatomic,weak) IBOutlet UIButton *btnAcceptInvite;
@property (nonatomic,weak) IBOutlet UIButton *btnRejectInvite;
@property (nonatomic,weak) IBOutlet UIButton *btnShare;
@property (nonatomic,weak) IBOutlet UIButton *btnProfile;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *trailingForButton;

-(void)closeExpandedMenu;

@end
