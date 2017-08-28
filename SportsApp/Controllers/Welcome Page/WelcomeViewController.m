//
//  WelcomeViewController.m
//  Moza
//
//  Created by Purpose Code on 24/01/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//
#define StatusSucess            200

#import "WelcomeViewController.h"
#import "WelcomeCustomCell.h"
#import "LoginViewController.h"
#import "Constants.h"
#import "RegistrationViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Google/SignIn.h>

@interface WelcomeViewController () <FBSDKLoginButtonDelegate,GIDSignInDelegate,GIDSignInUIDelegate>{
    
    IBOutlet UICollectionView *collectionView;
    IBOutlet NSLayoutConstraint *leftForBubleSelctn;
    IBOutlet UITextView *txtView;
    FBSDKLoginButton *btnFBSignin;
}

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self enableGoogleAndFBSignIn];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)setUp{
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"We don't post anything to Facebook and Google.By signing in you agree with our terms of service and privacy policy" attributes:nil];
    NSRange linkRangeOne = NSMakeRange(attributedString.length - 14, 14); // for the word "link" in the string above
    NSRange linkRangeTwo = NSMakeRange(attributedString.length - 35, 16);
    [attributedString addAttribute: NSLinkAttributeName value:[NSString stringWithFormat:@"%@terms.php",ExternalWebURL] range: linkRangeTwo];
    [attributedString addAttribute: NSLinkAttributeName value:[NSString stringWithFormat:@"%@privacy_policy.php",ExternalWebURL] range:linkRangeOne];
    txtView.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.67 green:0.68 blue:0.68 alpha:1.0], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    txtView.attributedText = attributedString;
    txtView.textAlignment = NSTextAlignmentCenter;
    txtView.font = [UIFont fontWithName:CommonFont size:11];
    txtView.textColor = [UIColor colorWithRed:0.67 green:0.68 blue:0.68 alpha:1.0];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UINib *cellNib = [UINib nibWithNibName:@"WelcomeCustomCell" bundle:nil];
    [collectionView registerNib:cellNib forCellWithReuseIdentifier:@"WelcomeCustomCell"];

}

-(void)enableGoogleAndFBSignIn{
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    btnFBSignin = [[FBSDKLoginButton alloc] init];
    btnFBSignin.delegate = self;
    btnFBSignin.hidden = true;
    
}

-(IBAction)tappedRegisterAccount:(id)sender{
    
    RegistrationViewController *registerPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForLogin Identifier:StoryBoardIdentifierForRegistrationPage];
    if (registerPage) {
        registerPage.isFromWelcomePage = true;
        [[self navigationController]pushViewController:registerPage animated:YES];
    }
    
}

-(IBAction)showLoginPage{
    
    LoginViewController *loginPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForLogin Identifier:StoryBoardIdentifierForLoginPage];
    [self.navigationController pushViewController:loginPage animated:YES];
    
}

#pragma mark - Google Signin Process

-(IBAction)doGoogleSignIn:(id)sender{
    
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    NSString *driveScope = @"https://www.googleapis.com/auth/userinfo.profile";
    NSArray *currentScopes = [GIDSignIn sharedInstance].scopes;
    [GIDSignIn sharedInstance].scopes = [currentScopes arrayByAddingObject:driveScope];
    [[GIDSignIn sharedInstance] signIn];
}




- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error) return;
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *name = user.profile.name;
    NSString *email = user.profile.email;
    NSURL *profileurl;
    if ([user.profile hasImage]) profileurl = [user.profile imageURLWithDimension:200];
    /*
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/plus/v1/people/me?access_token=%@",token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *skillData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *gender;
        double dateInSeconds;
        if (NULL_TO_NIL([skillData objectForKey:@"gender"])) {
            gender = @"1";
            if ([[skillData objectForKey:@"gender"] isEqualToString:@"female"]) {
                 gender = @"2";
            }
        }
        if (NULL_TO_NIL([skillData objectForKey:@"birthday"])) {
            NSString *dob = [skillData objectForKey:@"birthday"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *dateFromString = [dateFormatter dateFromString:dob];
            dateInSeconds = [dateFromString timeIntervalSince1970];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideLoadingScreen];
            [self doRegisterUserWithFirstName:name profileImg:profileurl fbID:nil googleID:userId email:email gender:gender dob:dateInSeconds];
           
        });
    }];
    
    [dataTask resume];
     */
    
    [self doRegisterUserWithFirstName:name profileImg:profileurl fbID:nil googleID:userId email:email phoneNumber:@""];
    
}



#pragma mark - FB Signin Process

-(IBAction)doFBSignIn:(id)sender{
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [self getFacebookData];
        
    }else{
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        login.loginBehavior = FBSDKLoginBehaviorSystemAccount;
        [login logInWithReadPermissions:@[@"public_profile",@"email",@"user_birthday"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            
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
                 
                 if (NULL_TO_NIL([result objectForKey:@"email"])) {
                     email = [result objectForKey:@"email"];
                 }
                 if (NULL_TO_NIL([result objectForKey:@"name"])) {
                     fname = [result objectForKey:@"name"];
                 }
                 if (NULL_TO_NIL([result objectForKey:@"id"])) {
                     fbID = [result objectForKey:@"id"];
                 }
                 
                  [self doRegisterUserWithFirstName:fname profileImg:nil fbID:fbID googleID:nil email:email phoneNumber:@""];
            }
         }];
    }
}

#pragma mark - SignUp Methods

-(void)doRegisterUserWithFirstName:(NSString*)name profileImg:(NSURL*)profileurl fbID:(NSString*)fbID googleID:(NSString*)googleID email:(NSString*)email phoneNumber:(NSString*)phoneNumber {
    
    [self showLoadingScreen];
    [APIMapper socialMediaRegistrationnWithFirstName:name profileImage:[profileurl absoluteString] fbID:fbID googleID:googleID email:email phoneNumber:phoneNumber success:^(AFHTTPRequestOperation *operation, id responds) {
        
        if ([operation.response statusCode] == StatusSucess) {
            AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate showHomeScreen];
        }else{
            if ( NULL_TO_NIL( [responds  objectForKey:@"text"]))
                [self showAlertWithMessage:[responds objectForKey:@"text"] title:@"Login"];
        }
        
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self hideLoadingScreen];
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            [self showAlertWithMessage:error.localizedDescription title:@"Login"];
    }];
    
    
}

-(void)createUserWithInfo:(NSDictionary*)userInfo{
    
    
    if ( NULL_TO_NIL([userInfo objectForKey:@"data"])) {
        NSDictionary *userDetails = [userInfo objectForKey:@"data"];
        if (NULL_TO_NIL([userDetails objectForKey:@"user_id"])) {
            [User sharedManager].userId = [userDetails objectForKey:@"user_id"];
        }
        if (NULL_TO_NIL([userDetails objectForKey:@"name"])) {
            [User sharedManager].name  = [userDetails objectForKey:@"name"];
        }
        if (NULL_TO_NIL([userDetails objectForKey:@"email"])) {
            [User sharedManager].email  = [userDetails objectForKey:@"email"];
        }
        if (NULL_TO_NIL([userDetails objectForKey:@"reg_date"])) {
            [User sharedManager].regDate  = [userDetails objectForKey:@"reg_date"];
        }
        if (NULL_TO_NIL([userDetails objectForKey:@"profileurl"])) {
            [User sharedManager].profileurl  = [userDetails objectForKey:@"profileurl"];
        }
        if (NULL_TO_NIL([userDetails objectForKey:@"mobile"])) {
            [User sharedManager].phoneNumber  = [userDetails objectForKey:@"mobile"];
        }
        if (NULL_TO_NIL([userDetails objectForKey:@"age"])) {
            [User sharedManager].age  = [userDetails objectForKey:@"age"];
        }
        if (NULL_TO_NIL([userDetails objectForKey:@"gender"])) {
            [User sharedManager].gender  = [userDetails objectForKey:@"gender"];
        }
        
        if ([userDetails objectForKey:@"token_id"]) {
            [User sharedManager].token  = [userDetails objectForKey:@"token_id"];
        }
        [Utility saveUserObject:[User sharedManager] key:@"USER"];
       
        /*!............ Saving user to NSUserDefaults.............!*/
    }
    
    
}

-(void)locationSearchedWithInfo:(NSString*)city address:(NSString*)address latitude:(double)latitude longitude:(double)longitude{
    
    [self showLoadingScreen];
    [APIMapper updateProfileWithUserID:[User sharedManager].userId name:nil statusMsg:nil city:city gender:0 mediaFileName:nil phoneNumber:@"" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hideLoadingScreen];
        if ([responseObject objectForKey:@"text"])
            [self showAlertWithMessage:[responseObject objectForKey:@"text"] title:@"Location"];
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate showHomeScreen];
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            [self showAlertWithMessage:error.localizedDescription title:@"Location"];
        [self hideLoadingScreen];
        
    }];
    
    
}
-(void)showAlertWithMessage:(NSString*)alertMessage title:(NSString*)alertTitle{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:alertTitle
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

-(void)displayErrorMessgeWithDetails:(NSData*)responseData{
    
    if (responseData.length) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                               error:&error];
        if (NULL_TO_NIL([json objectForKey:@"text"]))
            [self showAlertWithMessage:[json objectForKey:@"text"] title:@"Login"];
            
    }
}



#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)_collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WelcomeCustomCell *cell=[_collectionView dequeueReusableCellWithReuseIdentifier:@"WelcomeCustomCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.imgWelcome.image = [UIImage imageNamed:@"DefaultScreen1.png"];
    }
    else if (indexPath.row == 1) {
        cell.imgWelcome.image = [UIImage imageNamed:@"DefaultScreen2.png"];
        
    }
    else if (indexPath.row == 2) {
        cell.imgWelcome.image = [UIImage imageNamed:@"DefaultScreen3.png"];
       
    }

    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    float displacement = 30;
    float factor = self.view.frame.size.width / displacement;
    leftForBubleSelctn.constant = scrollView.contentOffset.x / factor;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.0f animations:^{
        [self.view layoutIfNeeded];

    }];

}


- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float width = _collectionView.frame.size.width;
    float height = _collectionView.frame.size.height;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0; // This is the minimum inter item spacing, can be more
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0,0, 0);
}

-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
