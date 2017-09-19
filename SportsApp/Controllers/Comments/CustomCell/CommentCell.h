//
//  ComposeMessageTableViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblTime;
@property (nonatomic,weak) IBOutlet UILabel *lblMessage;
@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UIButton *btnRemove;





@end
