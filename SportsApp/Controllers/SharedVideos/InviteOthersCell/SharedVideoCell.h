//
//  InviteOthersCell.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMEmojiableBtn.h"
#import "KILabel.h"

@interface SharedVideoCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UILabel *lblLoc;
@property (nonatomic,weak) IBOutlet UILabel *lblFriends;
@property (nonatomic,weak) IBOutlet UILabel *lblTime;

@property (nonatomic,weak) IBOutlet UILabel *lblCommenCount;
@property (nonatomic,weak) IBOutlet UILabel *lblShareCount;

@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UIButton *btnVideo;
@property (nonatomic,weak) IBOutlet UIButton *btnProfile;
@property (nonatomic,weak) IBOutlet UIButton *btnDelete;
@property (nonatomic,weak) IBOutlet UIButton *btnComment;
@property (nonatomic,weak) IBOutlet UIImageView *imgThumb;
@property (nonatomic,weak) IBOutlet UIImageView *imgMore;
@property (nonatomic,weak) IBOutlet UILabel *lblMediaCount;

@property (nonatomic,weak) IBOutlet UIButton *btnMoreGallery;
@property (nonatomic,weak) IBOutlet UIView *vwDescHolder;
@property (nonatomic,weak) IBOutlet UIView *vwLikeholder;
@property (nonatomic,weak) IBOutlet UIView *vwContainer;

@property (nonatomic,weak) IBOutlet UIButton *btnShare;
@property (nonatomic,weak) IBOutlet KILabel *lblDescription;

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *desrptionTopToImage;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *desrptionTopToView;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *constraintForHeight;

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *imageTopToProfile;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *imageTopToDescBottom;

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *trailingToChat;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *trailingToSuperView;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *topForImage;

@property (nonatomic,weak) IBOutlet UIButton *btnDisplayEmoji;
@property (nonatomic,weak) IBOutlet UIButton *btnDisplayComnt;

@property (nonatomic,weak) IBOutlet EMEmojiableBtn *btnEmoji;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;

@end
