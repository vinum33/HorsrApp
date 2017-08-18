//
//  AwarenessHeader.h
//  PurposeColor
//
//  Created by Purpose Code on 03/04/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ScoreBoard : UIView

@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UILabel *lblLocation;
@property (nonatomic,weak) IBOutlet UILabel *lblScore;
@property (nonatomic,weak) IBOutlet UIButton *btnClick;
@property (nonatomic,assign)  NSInteger index;



@end
