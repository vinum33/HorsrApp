//
//  NotificationDisplayView.h
//  Moza
//
//  Created by Purpose Code on 16/05/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GenderAndDOBViewDelegate <NSObject>


/*!
 *This method is invoked when user close  view.
 */

-(void)genderAndDOBSelectedByGender:(NSString*)gender andDOB:(long)_dob;

@end


@interface GenderAndDOBPicker : UIView


@property (nonatomic,weak)  id<GenderAndDOBViewDelegate>delegate;
-(void)intialiseView;

@end
