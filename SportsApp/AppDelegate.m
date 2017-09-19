//
//  AppDelegate.m
//  Moza
//
//  Created by Purpose Code on 23/01/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#define NOTIFICATION_TYPE_GAME_UPLOAD               @"game_upload"
#define NOTIFICATION_TYPE_GROUP_CHAT                @"chat"
#define NOTIFICATION_TYPE_PRIVATE_CHAT              @"privatechat"
#define NOTIFICATION_TYPE_FRIEND_REQ                @"friend"


typedef enum{
    
    eMenuEvents    = 0,
    eMenuCalendar  = 1,
    eMenuGroups  = 2,
    eMenuMessages = 3,
    EMenuLogout = 7
    
    
}eMenuType;

#define FACEBOOK_SCHEME  @"fb1390913077668061"

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "MenuViewController.h"
#import "Constants.h"
#import "WelcomeViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Google/SignIn.h>
#import "JCNotificationCenter.h"
#import "JCNotificationBannerPresenterIOSStyle.h"
#import "LoginViewController.h"
#import "Reachability.h"

@interface AppDelegate () <UITabBarControllerDelegate,SWRevealViewControllerDelegate,UIAlertViewDelegate>{
    
    BOOL isAlertInProgress;
    UITabBarController *tabBarController;
    UIButton *btnSlideMenu;
    Reachability *internetReachability;

}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
     [self reachability];
    [Utility setUpGoogleMapConfiguration];
    [self checkUserStatus];
    [self configureGoogleLoginIn];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
       
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    
    if ([[url scheme] isEqualToString:FACEBOOK_SCHEME]){
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }else
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    
}

-(void)configureGoogleLoginIn{
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
}


-(void)checkUserStatus{
    
    BOOL userExists = [self loadUserObjectWithKey:@"USER"];
    if (userExists) [self showHomeScreen];
    else            [self loginScreen];
    
}

/*!.........Check Availability of User !...........*/

- (BOOL )loadUserObjectWithKey:(NSString *)key {
    BOOL isUserExists = false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:key]) {
        NSData *encodedObject = [defaults objectForKey:key];
        if (encodedObject) {
            User *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
            if (object)isUserExists = true;
            [self createUserObject:object];
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.purposecodes.sportsapp"];
            [sharedDefaults setObject: [User sharedManager].token forKey:@"TOKEN"];
             [sharedDefaults setObject: [User sharedManager].name forKey:@"name"];
             [sharedDefaults setObject: [User sharedManager].profileurl forKey:@"profileurl"];
            [sharedDefaults synchronize];
        }

    }
    return isUserExists;
}

-(void)createUserObject:(User*)user{
    
    // Creating singleton user object with Decoded data from NSUserDefaults
    
    [User sharedManager].userId = user.userId;
    [User sharedManager].name = user.name;
    [User sharedManager].email = user.email;
    [User sharedManager].regDate = user.regDate;
    [User sharedManager].profileurl = user.profileurl;
    [User sharedManager].gender = user.gender;
    [User sharedManager].age = user.age;
    [User sharedManager].phoneNumber = user.phoneNumber;
    [User sharedManager].token = user.token;
    [User sharedManager].location = user.location;

    
}

-(void)loginScreen{
    
    LoginViewController *loginPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForLogin Identifier:StoryBoardIdentifierForLoginPage];
    UINavigationController *navMenu = [[UINavigationController alloc] initWithRootViewController:loginPage];
    navMenu.navigationBarHidden = true;
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ self.window.rootViewController = navMenu; }
                    completion:nil];
    
}

-(void)showWelcomeScreen{
    
    WelcomeViewController *welcomeVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForWelcome];
    UINavigationController *navMenu = [[UINavigationController alloc] initWithRootViewController:welcomeVC];
    navMenu.navigationBarHidden = true;
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ self.window.rootViewController = navMenu; }
                    completion:nil];
}


- (void)showHomeScreen {
    
    // Show home screen once login is successful.

     HomeViewController *homeVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForHomePage];
    _homeVC = homeVC;
    _navOutOfTab = [[UINavigationController alloc] initWithRootViewController:homeVC];
    _navOutOfTab.navigationBarHidden = true;
    MenuViewController *menuVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForMenuPage];
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:menuVC frontViewController:_navOutOfTab];
    _revealController = revealController;
    revealController.delegate = self;
    revealController.rearViewController = menuVC;
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ self.window.rootViewController = revealController; }
                    completion:nil];

}


-(void)logoutSinceUnAuthorized:(NSDictionary*)notification{
    if(isAlertInProgress) return;
    BOOL userExists = [self loadUserObjectWithKey:@"USER"];
    if (!userExists) return;
    isAlertInProgress = true;
    NSString *text = @"Invalid authentication token!";
    if (notification) {
        NSDictionary *dict  = notification;
        text = [dict objectForKey:@"text"];
    }
    [_homeVC clearUserSessions];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout"
                                                    message:text
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    alert.tag = 111;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 111){
        isAlertInProgress = false;
        return;
    }

}

-(void)enablePushNotification{
    
    UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self updateTokenToWebServerWithToken:token];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error %@",err);
}

-(void)updateTokenToWebServerWithToken:(NSString*)token{
    
    BOOL userExists = [self loadUserObjectWithKey:@"USER"];
    if (!userExists) return;
    if ((token.length) && [User sharedManager].userId.length)
        [APIMapper setPushNotificationTokenWithUserID:[User sharedManager].userId token:token success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
    }];
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self resetBadgeCount];
   // [_homeVC updateNotificationIcon];
    BOOL userExists = [self loadUserObjectWithKey:@"USER"];
    if (!userExists) return;
    if(application.applicationState == UIApplicationStateInactive) {
        [self handleNotificationWith:userInfo isBackground:YES];
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else if (application.applicationState == UIApplicationStateBackground) {
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else {
        [self handleNotificationWith:userInfo isBackground:NO];
        completionHandler(UIBackgroundFetchResultNewData);
        
    }

}

-(void)handleNotificationWith:(NSDictionary*)userInfo isBackground:(BOOL)isBackground{
     BOOL userExists = [self loadUserObjectWithKey:@"USER"];
     if (userExists) {
        if (NULL_TO_NIL([userInfo objectForKey:@"data"])) {
            if ([[[userInfo objectForKey:@"data"] objectForKey:@"notification_type"] isEqualToString:NOTIFICATION_TYPE_GAME_UPLOAD]){
                [_homeVC refreshGameZoneWithInfo:userInfo];
            }
            else if ([[[userInfo objectForKey:@"data"] objectForKey:@"notification_type"] isEqualToString:NOTIFICATION_TYPE_GROUP_CHAT]){
                [_homeVC manageGroupChatInfoFromForeGround:[userInfo objectForKey:@"data"] isBBg:isBackground];
            }
            else if ([[[userInfo objectForKey:@"data"] objectForKey:@"notification_type"] isEqualToString:NOTIFICATION_TYPE_PRIVATE_CHAT]){
                [_homeVC managePrivateChatInfoFromForeGround:[userInfo objectForKey:@"data"] isBBg:isBackground];
            }
            else if ([[[userInfo objectForKey:@"data"] objectForKey:@"notification_type"] isEqualToString:NOTIFICATION_TYPE_FRIEND_REQ]){
                [_homeVC manageFriendReqNotificatinWith:userInfo isBBg:isBackground];
            }else{
                [_homeVC manageOtherNotificationsWith:userInfo isBBg:isBackground];
            }
        }
    }
    
}


#pragma mark - Reachability

-(void)reachability{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
}

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    NSString* statusString = @"";
    switch (netStatus)
    {
        case NotReachable:        {
            statusString = @"The internet is down.";
            break;
        }
            
        case ReachableViaWWAN:        {
            statusString = @"The internet is working via WWAN.";
            break;
        }
        case ReachableViaWiFi:        {
            statusString= @"The internet is working via WIFI.";
            break;
        }
    }
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Internet"
                                  message:statusString
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                             
                         }];
    [alert addAction:ok];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
    
}

-(void)resetBadgeCount{
    
    BOOL userExists = [self loadUserObjectWithKey:@"USER"];
    if (!userExists) return;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if ([User sharedManager].userId.length) [self enablePushNotification];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
