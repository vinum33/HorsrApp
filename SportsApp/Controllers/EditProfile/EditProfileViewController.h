//
//  NotificationsViewController.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

@protocol EditProfileDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)sholdRefresh;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController
@property (nonatomic,strong) NSString *strUserID;
@property (nonatomic,weak)  id<EditProfileDelegate>delegate;

@end
