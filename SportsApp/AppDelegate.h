//
//  AppDelegate.h
//  Moza
//
//  Created by Purpose Code on 23/01/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "HomeViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) User *currentUser;
@property (nonatomic,strong) HomeViewController *homeVC;
@property (nonatomic,strong) UINavigationController *navOutOfTab;
@property (nonatomic,strong)SWRevealViewController *revealController;


-(void)enablePushNotification;
- (void)showHomeScreen;
-(void)checkUserStatus;
-(void)logoutSinceUnAuthorized:(NSDictionary*)notification;

@end

