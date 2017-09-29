//
//  NotificationsViewController.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

typedef enum{
    
    eTypeRequests           = 0,
    eTypeSearch             = 1,
    eTypeContacts           = 2,
    
    
}SegmentType;

#import <UIKit/UIKit.h>

@interface FriendRequestManager : UIViewController

@property (nonatomic,assign) SegmentType menuType;

-(void)enableFriendRequestTabFromNotifications;


@end
