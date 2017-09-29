//
//  ForgotPasswordPopUp.h
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StatisticsPopUpDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closeStatisticsPopUp;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end

@interface StatisticsPopUp : UIView{
    
    
}

@property (nonatomic,weak)  id<StatisticsPopUpDelegate>delegate;

-(void)setUp;
-(void)setUpPopWithName:(NSString*)name andScore:(NSString*)score;

@end
