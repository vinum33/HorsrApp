//
//  PlayReqTableViewCell.h
//  SportsApp
//
//  Created by Purpose Code on 18/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerListTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIButton *btnAddFrnd;
@property (nonatomic,weak) IBOutlet UIButton *btnCancel;
@property (nonatomic,weak) IBOutlet UIButton *btnAcept;

@property (nonatomic,weak) IBOutlet UIButton *btnCancelReq;
@property (nonatomic,weak) IBOutlet UIButton *btnReject;

@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UILabel *lblLocation;
@property (nonatomic,weak) IBOutlet UIView *vwCancelReq;
@property (nonatomic,weak) IBOutlet UIView *vwCreatereq;
@property (nonatomic,weak) IBOutlet UIView *vwConfirmation;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *contrsintForCreateReq;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *contrsintForCancelReq;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *contrsintForConfirmation;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *contrsintForEnd;

@end
