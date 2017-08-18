//
//  NotificationsViewController.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InviteUserDeleagte <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)userInvitedWithList:(NSMutableArray*)users;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end



@interface InviteOthersViewController : UIViewController

@property (nonatomic,weak)  id<InviteUserDeleagte>delegate;
@property (nonatomic,strong) NSArray *selectedUsers ;
@property (nonatomic,assign) BOOL isFromTagFriends ;

@end
