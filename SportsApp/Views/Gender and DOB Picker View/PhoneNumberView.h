//
//  NotificationDisplayView.h
//  Moza
//
//  Created by Purpose Code on 16/05/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhoneNumberViewDelegate <NSObject>


/*!
 *This method is invoked when user close  view.
 */

-(void)closePopUpWithPhoneNumber:(NSString*)phoneNumber;

@end


@interface PhoneNumberView : UIView


@property (nonatomic,weak)  id<PhoneNumberViewDelegate>delegate;
-(void)intialiseViewWithPhoneNumber:(NSString*)phoneNumber;

@end
