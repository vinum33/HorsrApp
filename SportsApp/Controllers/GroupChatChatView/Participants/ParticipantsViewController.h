//
//  ChatComposeViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ParticipantsPopUpDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closePopUp;

-(void)showChatPageWithInfo:(NSDictionary*)details;
/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end


@interface ParticipantsViewController : UIViewController

@property (nonatomic,weak)  id<ParticipantsPopUpDelegate>delegate;
@property (nonatomic,strong) NSString *strGroupID;


@end
