//
//  ForgotPasswordPopUp.h
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WinnerPopUpDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closeWinnerPopUp;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end

@interface WinnerPopUp : UIView{
    
    
}

@property (nonatomic,weak)  id<WinnerPopUpDelegate>delegate;

-(void)setUp;
-(void)setUpPopUpForOthersWithWinnerName:(NSString*)winnerName;

@end
