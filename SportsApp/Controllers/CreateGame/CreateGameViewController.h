//
//  NotificationsViewController.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateGamePopUpDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closeCreateGamePopUp;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end


@interface CreateGameViewController : UIViewController

@property (nonatomic,weak)  id<CreateGamePopUpDelegate>delegate;

@end
