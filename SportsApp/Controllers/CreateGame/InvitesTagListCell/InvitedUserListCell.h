//
//  PlayReqTableViewCell.h
//  SportsApp
//
//  Created by Purpose Code on 18/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol UserTagListCellDelegate <NSObject>


@optional

-(void)tagListCellHeight:(float)height;


@end


@interface InvitedUserListCell : UITableViewCell{
    
    
}

@property (nonatomic,weak)  id<UserTagListCellDelegate>delegate;

@end
