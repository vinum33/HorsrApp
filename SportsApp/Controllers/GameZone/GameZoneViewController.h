//
//  NotificationsViewController.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

@protocol GameZoneDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)gameZoneCompleted;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end

#import <UIKit/UIKit.h>

@interface GameZoneViewController : UIViewController

@property (nonatomic,strong) NSString *strGameID;
@property (nonatomic,weak)  id<GameZoneDelegate>delegate;

-(void)getGameZoneDetails;
-(void)showToastWithMessage:(NSString*)strMesage;

@end
