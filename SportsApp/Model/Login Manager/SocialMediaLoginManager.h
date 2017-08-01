//
//  SocialMediaLoginManager.h
//  SportsApp
//
//  Created by Purpose Code on 06/06/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SocialMediaLoginDelegate <NSObject>


/*!
 *This method is invoked when user close  view.
 */

-(void)socialMediaLoginWithName:(NSString*)fname email:(NSString*)email fbiD:(NSString*)fbID;

@end


@interface SocialMediaLoginManager : NSObject

@property (nonatomic,weak)  id<SocialMediaLoginDelegate>delegate;

-(void)doFBLoginFromViewController:(UIViewController*)viewcontroller;
-(void)doGoogleLoginFromViewController:(UIViewController*)viewcontroller;

@end
