//
//  ViewController.m
//  SignSpot
//
//  Created by Purpose Code on 09/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

typedef enum{
    
    eUserName = 0,
    ePasword = 1,
    
    
}eLogInfo;



#define StatusSucess            200

#define kCellHeight             50;
#define kHeightForHeader        50;
#define kHeightForFooter        225;
#define kMaxReviewLength        150
#define kMaxReviewTitleLength   50

#import "LoginViewController.h"
#import "RegistrationViewController.h"
#import "ForgotPasswordPopUp.h"
#import "Constants.h"
#import "CustomCellForLogin.h"
#import "SocialMediaLoginManager.h"
#import <Google/SignIn.h>
#import "PhoneNumberView.h"
#import "LocationAutoSearchViewController.h"

@interface LoginViewController () <UIAlertViewDelegate,GIDSignInUIDelegate,GIDSignInDelegate,PhoneNumberViewDelegate,SocialMediaLoginDelegate,SearchLocationDelegate>{
    
    IBOutlet UITableView *tableView;
    
    UIView *inputAccView;
    NSInteger indexForTextFieldNavigation;
    NSString *password;
    NSString *userName;
    NSInteger totalRequiredFieldCount;
    
    ForgotPasswordPopUp *forgotPwdPopUp;
    
    IBOutlet UIButton *btnFb;
    IBOutlet UIButton *btnGoogle;
    PhoneNumberView *phoneNumberPicker;
    
    NSString *socialMediaName;
    NSString *socialMediaEmail;
    NSString *fbID;
    NSString *googleID;
    NSURL *socialMediaProfileImageurl;
    LocationAutoSearchViewController *vwLocationWindow;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
   
       
    // Do any additional setup after loading the view, typically from a nib.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}




-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
}
-(void)setUp{
    
    totalRequiredFieldCount = 2;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.allowsSelection = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    btnFb.layer.borderWidth = 1.f;
    btnFb.layer.borderColor = [UIColor clearColor].CGColor;
    btnFb.layer.cornerRadius = 5;
    
    btnGoogle.layer.borderWidth = 1.f;
    btnGoogle.layer.borderColor = [UIColor clearColor].CGColor;
    btnGoogle.layer.cornerRadius = 5;
    
    
//    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
//    [bezierPath moveToPoint: CGPointMake(0, 0)];
//    [bezierPath addLineToPoint:CGPointMake(180, 0)];
//    [bezierPath addLineToPoint:CGPointMake(0, 220)];
//    CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
//    [progressLayer setPath:bezierPath.CGPath];
//    [progressLayer setFillColor:[UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0].CGColor];
//    [self.view.layer addSublayer:progressLayer];
//    
//    float deviceWidth = self.view.frame.size.width;
//    float deviceHeight = self.view.frame.size.height;
//    bezierPath = [UIBezierPath bezierPath];
//    [bezierPath moveToPoint: CGPointMake(deviceWidth, deviceHeight)];
//    [bezierPath addLineToPoint:CGPointMake(deviceWidth, deviceHeight - 150)];
//    [bezierPath addLineToPoint:CGPointMake(deviceWidth - 150, deviceHeight)];
//    progressLayer = [[CAShapeLayer alloc] init];
//    [progressLayer setPath:bezierPath.CGPath];
//    [progressLayer setFillColor:[UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0].CGColor];
//    [self.view.layer addSublayer:progressLayer];
    
    
    
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.frame = self.view.frame;
//    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:193.0/255.0 green:13.0/255.0 blue:13.0/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:247.0/255.0 green:166.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:194.0/255.0 green:157.0/255.0 blue:206.0/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:188.0/255.0 green:154.0/255.0 blue:199.0/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:167.0/255.0 green:129.0/255.0 blue:185.0/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:158.0/255.0 green:107.0/255.0 blue:171.0/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:149.0/255.0 green:86.0/255.0 blue:174.0/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:139.0/255.0 green:74.0/255.0 blue:151.0/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:129.0/255.0 green:38.0/255.0 blue:140.0/255.0 alpha:1.0].CGColor ];
//    gradientLayer.startPoint = CGPointMake(0,0.1);
//    gradientLayer.endPoint = CGPointMake(0.5,0.2);
//    [self.view.layer addSublayer:gradientLayer];
//    gradientLayer.mask = progressLayer;
    
}



#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return totalRequiredFieldCount;
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"reuseIdentifier";
    CustomCellForLogin *cell = (CustomCellForLogin *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.txtField.keyboardType = UIKeyboardTypeDefault;
    cell.txtField.tag = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell = [self configureCellWithCaseValue:indexPath.row cell:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeightForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return  kHeightForFooter;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor clearColor];
    
    UILabel *lblTitle = [UILabel new];
    lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblTitle];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    lblTitle.text = @"Login";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont fontWithName:CommonFontBold size:18];
    lblTitle.textColor = [UIColor whiteColor];
    
    return vwHeader;
}
- (nullable UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section{
    
    UIView *vwFooter = [UIView new];
    vwFooter.backgroundColor = [UIColor clearColor];
    
    UIButton* btnLogin = [UIButton new];
    btnLogin.backgroundColor = [UIColor clearColor];
    btnLogin.translatesAutoresizingMaskIntoConstraints = NO;
    [btnLogin setTitle:@"LOGIN" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnLogin.titleLabel.font = [UIFont fontWithName:CommonFontBold size:15];
    [btnLogin addTarget:self action:@selector(tapToLogin:) forControlEvents:UIControlEventTouchUpInside];
    [vwFooter addSubview:btnLogin];
    btnLogin.clipsToBounds = YES;
    btnLogin.layer.borderColor = [[UIColor clearColor] CGColor];
    btnLogin.layer.borderWidth = 1.0f;
    btnLogin.layer.cornerRadius = 20.0f;
    
    
    [btnLogin addConstraint:[NSLayoutConstraint constraintWithItem:btnLogin
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                         constant:40]];
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnLogin
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:70]];
    
     NSArray *horizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[btnLogin]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnLogin)];
    [vwFooter addConstraints:horizontalConstraints];
    
    
    float width = aTableView.frame.size.width - 10;
    UIColor *topColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.16 alpha:1.0];
    UIColor * bottomColor = [UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, width, 40);
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);

    [btnLogin.layer addSublayer:gradient];
    [btnLogin.layer insertSublayer:gradient atIndex:0];
    
    UIButton* btnForgotPwd = [UIButton new];
    btnForgotPwd.backgroundColor = [UIColor clearColor];
    btnForgotPwd.translatesAutoresizingMaskIntoConstraints = NO;
    [btnForgotPwd setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [btnForgotPwd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnForgotPwd.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnForgotPwd addTarget:self action:@selector(tappedForgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [vwFooter addSubview:btnForgotPwd];
    
    [btnForgotPwd addConstraint:[NSLayoutConstraint constraintWithItem:btnForgotPwd
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0
                                                          constant:40]];
    
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnForgotPwd
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0]];
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnForgotPwd
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:5]];
    
    
    
    
    UIButton* btnRegister = [UIButton new];
    btnRegister.backgroundColor = [UIColor clearColor];
    btnRegister.translatesAutoresizingMaskIntoConstraints = NO;
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    NSMutableAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"New User? SignUp"]];
    [myText addAttribute:NSFontAttributeName value:[UIFont fontWithName:CommonFontBold size:14.0] range:NSMakeRange(10,6)];
    [myText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,myText.length)];
    [btnRegister setAttributedTitle:myText forState:UIControlStateNormal];
    [btnRegister addTarget:self action:@selector(tappedRegisterAccount:) forControlEvents:UIControlEventTouchUpInside];
    [vwFooter addSubview:btnRegister];
    [btnRegister addConstraint:[NSLayoutConstraint constraintWithItem:btnRegister
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:40]];
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnRegister
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0]];
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnRegister
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:-5]];
    return vwFooter;
}


#pragma mark - UITextfield delegate methods


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromField:textField];
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self createInputAccessoryView];
    [textField setInputAccessoryView:inputAccView];
    NSIndexPath *indexPath;
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        indexForTextFieldNavigation = indexPath.row;
    }
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height );
    [tableView setContentOffset:contentOffset animated:YES];
    
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
}



-(CustomCellForLogin*)configureCellWithCaseValue:(NSInteger)position cell:(CustomCellForLogin*)cell{
    cell.txtField.secureTextEntry = YES;
    cell.imgIcon.image = [UIImage imageNamed:@"Icon_Pwd"];
    if ([cell.txtField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        cell.txtField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
        
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    if(position == eUserName){
        cell.imgIcon.image = [UIImage imageNamed:@"Icon_Email"];
        cell.txtField.secureTextEntry = NO;
        cell.txtField.keyboardType = UIKeyboardTypeEmailAddress;
        if ([cell.txtField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            UIColor *color = [UIColor whiteColor];
            cell.txtField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
        } else {
            NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
            // TODO: Add fall-back code to set placeholder color.
        }
    }
    
    return cell;
    
}

#pragma mark - Login Actions


-(void)getTextFromField:(UITextField*)textField{
    
    NSString *string = textField.text;
    NSInteger tag = textField.tag;
    switch (tag) {
        case eUserName:
            userName = string;
            break;
        case ePasword:
            password = string;
            break;
            
            default:
            break;
    }
    
}

-(void)createInputAccessoryView{
    
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(inputAccView.frame.size.width - 85, 1.0f, 85.0f, 38.0f)];
    [btnDone setTitle:@"DONE" forState:UIControlStateNormal];
    [btnDone setBackgroundColor:[UIColor getThemeColor]];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone.layer.cornerRadius = 5.f;
    btnDone.layer.borderWidth = 1.f;
    btnDone.layer.borderColor = [UIColor clearColor].CGColor;
    btnDone.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
    [inputAccView addSubview:btnDone];}

-(void)gotoPrevTextfield{
    
    if (indexForTextFieldNavigation - 1 < 0) indexForTextFieldNavigation = 0;
    else indexForTextFieldNavigation -= 1;
    
    [self gotoTextField];
    
}

-(void)gotoNextTextfield{
    
    if (indexForTextFieldNavigation + 1 < totalRequiredFieldCount) indexForTextFieldNavigation += 1;
    [self gotoTextField];
}

-(void)gotoTextField{
    
    CustomCellForLogin *nextCell = (CustomCellForLogin *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0]];
    if (!nextCell) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        nextCell = (CustomCellForLogin *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0]];
        
    }
    [nextCell.txtField becomeFirstResponder];
    
}

-(void)doneTyping{
    [self.view endEditing:YES];
    
}

#pragma mark - Textfield Delegates


-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)tapToLogin:(id)sender{
    
  // [self byPassLogin];
  //return;
    
    [self.view endEditing:YES];
    [self checkAllFieldsAreValid:^{
         [self showLoadingScreen];
        [APIMapper loginUserWithUserName:userName userPassword:password
                                 success:^(AFHTTPRequestOperation *operation, id responseObject){
                                     NSDictionary *responds = (NSDictionary*)responseObject;
                                     
                                     if ([operation.response statusCode] == StatusSucess) {
                                         
                                        [self createUserWithInfo:responds];
                                         AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                         [appDelegate showHomeScreen];
                                         
                                     }else{
                                         
                                         if ( NULL_TO_NIL( [responds  objectForKey:@"text"]))
                                             [self showAlertWithMessage:[responds objectForKey:@"text"] title:@"Login"];
                                     }
                                     
                                     [self hideLoadingScreen];
                                     
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                     
                                     [self hideLoadingScreen];
                                     if (operation.responseData)
                                         [self displayErrorMessgeWithDetails:operation.responseData];
                                     else
                                         [self showAlertWithMessage:error.localizedDescription title:@"Login"];
                                     
                                 }];
        
    } failure:^(NSString *errorMsg) {
        
         [self showAlertWithMessage:errorMsg title:@"Login"];
    }];
    
    
   
    
}

-(void)byPassLogin{
    
    [self.view endEditing:YES];
    [self showLoadingScreen];
    [APIMapper loginUserWithUserName:@"vinayan@purposecodes.com" userPassword:@"123"
                             success:^(AFHTTPRequestOperation *operation, id responseObject){
                                 NSDictionary *responds = (NSDictionary*)responseObject;
                                 
                                 if ([operation.response statusCode] == StatusSucess) {
                                     
                                     [self createUserWithInfo:responds];
                                     AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                     [appDelegate showHomeScreen];
                                     
                                 }else{
                                     
                                     if ( NULL_TO_NIL( [responds  objectForKey:@"text"]))
                                         [self showAlertWithMessage:[responds objectForKey:@"text"] title:@"Login"];
                                 }

                                 [self hideLoadingScreen];
                                 
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                 
                                 [self hideLoadingScreen];
                                 if (operation.responseData)
                                     [self displayErrorMessgeWithDetails:operation.responseData];
                                 else
                                     [self showAlertWithMessage:error.localizedDescription title:@"Login"];
                                 
                             }];

    
}

-(void)checkAllFieldsAreValid:(void (^)())success failure:(void (^)(NSString *errorMsg))failure{
    
    BOOL isValid = false;
    NSString *errorMsg;
    if ((userName.length) && (password.length) > 0) {
        isValid = true;
        if (![userName isValidEmail]) {
            
            errorMsg = @"Enter a valid Email address.";
            isValid = false;
        }
    }else{
        errorMsg = @"Enter Email and Password.";
    }
    if (isValid)success();
    else failure(errorMsg);
    
}


#pragma mark - Google Signin Process

-(IBAction)doGoogleSignIn:(id)sender{
    
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    SocialMediaLoginManager *loginManager = [SocialMediaLoginManager new];
    [loginManager doGoogleLoginFromViewController:self];
   
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error) return;
    [self showLoadingScreen];
    fbID = nil;
    googleID = user.userID;                  // For client-side use only!
    socialMediaName = user.profile.name;
    socialMediaEmail = user.profile.email;
    if ([user.profile hasImage]) socialMediaProfileImageurl = [user.profile imageURLWithDimension:200];
    [self showPhoneNumberPicker];
    
}


#pragma mark - FB Signin Process

-(IBAction)doFBSignIn:(id)sender{
    
    SocialMediaLoginManager *loginManager = [SocialMediaLoginManager new];
    loginManager.delegate = self;
    [loginManager doFBLoginFromViewController:self];
    
}

-(void)socialMediaLoginWithName:(NSString*)fname email:(NSString*)email fbiD:(NSString*)_fbID;{
    
    googleID = nil;
    socialMediaEmail = email;
    socialMediaName = fname;
    fbID = _fbID;
    
    [self showPhoneNumberPicker];
}



#pragma mark - Gender AND DOB Picker

-(void)showPhoneNumberPicker{
    
    if (!phoneNumberPicker) {
        
        phoneNumberPicker = [[[NSBundle mainBundle] loadNibNamed:@"PhoneNumberView" owner:self options:nil] objectAtIndex:0];
        [self.view addSubview:phoneNumberPicker];
        phoneNumberPicker.delegate = self;
        phoneNumberPicker.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[phoneNumberPicker]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(phoneNumberPicker)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[phoneNumberPicker]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(phoneNumberPicker)]];
        
        phoneNumberPicker.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            phoneNumberPicker.transform = CGAffineTransformIdentity;
            [phoneNumberPicker intialiseViewWithPhoneNumber:@""];
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
        
    }
    
    [self.view endEditing:YES];
    
}

-(void)closePopUpWithPhoneNumber:(NSString*)phoneNumber{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        phoneNumberPicker.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [phoneNumberPicker removeFromSuperview];
        phoneNumberPicker = nil;
        [self doRegisterUserWithFirstName:socialMediaName profileImg:socialMediaProfileImageurl fbID:fbID googleID:googleID email:socialMediaEmail phoneNumber:phoneNumber];
    }];
    
    
    
}

#pragma mark - SignUp Methods


-(void)doRegisterUserWithFirstName:(NSString*)name profileImg:(NSURL*)profileurl fbID:(NSString*)_fbID googleID:(NSString*)_googleID email:(NSString*)email phoneNumber:(NSString*)phoneNumber {
    
    [self showLoadingScreen];
    [APIMapper socialMediaRegistrationnWithFirstName:name profileImage:[profileurl absoluteString] fbID:_fbID googleID:_googleID email:email phoneNumber:phoneNumber success:^(AFHTTPRequestOperation *operation, id responds) {
        if ([operation.response statusCode] == StatusSucess) {
            BOOL shouldGoToHome = [self createUserWithInfo:responds];
            if (shouldGoToHome) {
                AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate showHomeScreen];
            }
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

-(BOOL)createUserWithInfo:(NSDictionary*)userInfo{
    
    BOOL shouldLogin = true;
    
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
        if (NULL_TO_NIL([userDetails objectForKey:@"dob"])) {
            [User sharedManager].age  = [userDetails objectForKey:@"dob"];
        }
        if (NULL_TO_NIL([userDetails objectForKey:@"gender"])) {
            [User sharedManager].gender  = [userDetails objectForKey:@"gender"];
        }
        if ([userDetails objectForKey:@"token_id"]) {
            [User sharedManager].token  = [userDetails objectForKey:@"token_id"];
        }
        BOOL loc = false;
        NSString *location = [userDetails objectForKey:@"location"];
        if (location.length) {
            [User sharedManager].location  = [userDetails objectForKey:@"location"];
            loc = true;
        }
        [Utility saveUserObject:[User sharedManager] key:@"USER"];
        if (!loc) {
            vwLocationWindow =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GeneralStoryBoard Identifier:StoryBoardIdentifierForLocationDisplayWindow];
            [[self navigationController] pushViewController:vwLocationWindow animated:YES];
            vwLocationWindow.delegate = self;
            shouldLogin = false;
        }
       
        /*!............ Saving user to NSUserDefaults.............!*/
        
        
    }else{
        shouldLogin = false;
    }
    return shouldLogin;
    
}

-(void)locationSearchedWithInfo:(NSString*)city address:(NSString*)address latitude:(double)latitude longitude:(double)longitude{
    
    [self showLoadingScreen];
    [APIMapper updateProfileWithUserID:[User sharedManager].userId name:nil statusMsg:nil city:city gender:0 mediaFileName:nil phoneNumber:nil   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([operation.response statusCode] == StatusSucess) {
            BOOL shouldGoToHome = [self createUserWithInfo:responseObject];
            if (shouldGoToHome) {
                AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [appDelegate showHomeScreen];
            }
        }else{
            if ( NULL_TO_NIL( [responseObject  objectForKey:@"text"]))
                [self showAlertWithMessage:[responseObject objectForKey:@"text"] title:@"Login"];
        }
        
        
        [self hideLoadingScreen];
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



-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}


-(IBAction)tappedRegisterAccount:(id)sender{
    
    RegistrationViewController *registerPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForLogin Identifier:StoryBoardIdentifierForRegistrationPage];
    if (registerPage) {
        
        [[self navigationController]pushViewController:registerPage animated:YES];
    }
    
}

#pragma mark - Forgot Password Methods and Delegates


-(IBAction)tappedForgetPassword:(id)sender{
    
    if (!forgotPwdPopUp) {
        
        forgotPwdPopUp = [ForgotPasswordPopUp new];
        [self.view addSubview:forgotPwdPopUp];
        forgotPwdPopUp.delegate = self;
        forgotPwdPopUp.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[forgotPwdPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(forgotPwdPopUp)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[forgotPwdPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(forgotPwdPopUp)]];
        
        forgotPwdPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            forgotPwdPopUp.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
        
    }
    
    [self.view endEditing:YES];
    [forgotPwdPopUp setUp];
}



-(void)closeForgotPwdPopUpAfterADelay:(float)delay{
    
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        forgotPwdPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [forgotPwdPopUp removeFromSuperview];
        forgotPwdPopUp = nil;
    }];
}




-(IBAction)goBack:(id)sender{
    
    [[self navigationController]popViewControllerAnimated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}




@end
