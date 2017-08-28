//
//  ForgotPasswordPopUp.h
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoPopUpDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closeInfoPopUp:(BOOL)shouldRefresh;



/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end

@interface InfoPopUp : UIView{
    
}

@property (nonatomic,weak)  id<InfoPopUpDelegate>delegate;
@property (nonatomic,strong) NSString *strGameID;

-(void)setUpWithTitle:(NSString*)title;

@end
