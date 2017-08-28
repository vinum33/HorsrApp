//
//  InviteOthersCell.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMEmojiableBtn.h"

@interface SharedVideoCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UILabel *lblLoc;
@property (nonatomic,weak) IBOutlet UILabel *lblFriends;
@property (nonatomic,weak) IBOutlet UILabel *lblTime;
@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UIButton *btnVideo;
@property (nonatomic,weak) IBOutlet UIButton *btnProfile;
@property (nonatomic,weak) IBOutlet UIButton *btnDelete;
@property (nonatomic,weak) IBOutlet UIImageView *imgThumb;
@property (nonatomic,weak) IBOutlet UIButton *btnShare;
@property (nonatomic,weak) IBOutlet UILabel *lblDescription;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *constraintForHeight;
@property (nonatomic,weak) IBOutlet EMEmojiableBtn *btnEmoji;

@end
