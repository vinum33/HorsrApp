//
//  AwarenessHeader.h
//  PurposeColor
//
//  Created by Purpose Code on 03/04/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeopleListHeader : UIView

@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UILabel *lblRegDate;
@property (nonatomic,weak) IBOutlet UIView *vwRegHolder;
@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *imgHeight;

@end
