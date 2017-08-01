//
//  SocialMediaLoginManager.m
//  SportsApp
//
//  Created by Purpose Code on 06/06/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "SocialMediaLoginManager.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Constants.h"
#import <Google/SignIn.h>

@interface SocialMediaLoginManager() <FBSDKLoginButtonDelegate>{
    
    UIViewController *vcPresented;
    FBSDKLoginButton *btnFBSignin;
    
}

@end
@implementation SocialMediaLoginManager

-(void)doFBLoginFromViewController:(UIViewController*)viewcontroller{
    
    btnFBSignin = [[FBSDKLoginButton alloc] init];
    btnFBSignin.delegate = self;
    btnFBSignin.hidden = true;
    vcPresented = viewcontroller;
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [self getFacebookData];
        
    }else{
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        login.loginBehavior = FBSDKLoginBehaviorSystemAccount;
        [login logInWithReadPermissions:@[@"public_profile",@"email"] fromViewController:viewcontroller handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            
            if (!error)[self getFacebookData];
            
        }];
        
    }

    
}

- (void)getFacebookData{
    if ([FBSDKAccessToken currentAccessToken]) {
        [self showLoadingScreen];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"first_name, last_name, picture.type(large), email, name, id, gender, birthday"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             [self hideLoadingScreen];
             if (!error) {
                 NSString *email;
                 NSString *fname;
                 NSString *fbID;
                 NSString *gender;
                 if (NULL_TO_NIL([result objectForKey:@"email"])) {
                     email = [result objectForKey:@"email"];
                 }
                 if (NULL_TO_NIL([result objectForKey:@"name"])) {
                     fname = [result objectForKey:@"name"];
                 }
                 if (NULL_TO_NIL([result objectForKey:@"id"])) {
                     fbID = [result objectForKey:@"id"];
                 }
                 
                  [[self delegate] socialMediaLoginWithName:fname email:email fbiD:fbID];
                 
             }
         }];
    }
}



-(void)doGoogleLoginFromViewController:(UIViewController*)viewcontroller{
    
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    NSString *driveScope = @"https://www.googleapis.com/auth/userinfo.profile";
    NSArray *currentScopes = [GIDSignIn sharedInstance].scopes;
    [GIDSignIn sharedInstance].scopes = [currentScopes arrayByAddingObject:driveScope];
    [[GIDSignIn sharedInstance] signIn];
}






-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vcPresented.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:vcPresented.view animated:YES];
    
}


@end
