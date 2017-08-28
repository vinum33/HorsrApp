//
//  RegistrationPageCustomTableViewCell.h
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistrationPageCustomTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UITextField *entryField;
@property (nonatomic,weak) IBOutlet UIView *borderBG;
@property (nonatomic,weak) IBOutlet UIView *vwGenderSelection;
@property (nonatomic,weak) IBOutlet UIButton *btnMale;
@property (nonatomic,weak) IBOutlet UIButton *btnFemale;
@property (nonatomic,weak) IBOutlet UIImageView *imgIcon;
@property (nonatomic,weak) IBOutlet UILabel *lblDialCode;

@end
