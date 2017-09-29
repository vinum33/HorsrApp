//
//  NotificationsViewController.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

typedef enum{
    
    eTypeNotifications      = 0,
    eTypeGameReq            = 1,
    eTypePending            = 2,
    
    
}eNotificationMenuType;

#import <UIKit/UIKit.h>

@interface NotificationsViewController : UIViewController

-(void)enableGameRequestTabByNotification;

@property (nonatomic,assign) eNotificationMenuType menuType;


@end
