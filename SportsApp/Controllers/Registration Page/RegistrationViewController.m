//
//  RegistrationViewController.m
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define StatusSucess 201

#import "RegistrationViewController.h"
#import "RegistrationPageCustomTableViewCell.h"
#import "Constants.h"
#import "LoginViewController.h"
#import <GooglePlaces/GooglePlaces.h>

typedef enum{
    
    eFieldName = 0,
    eFieldEmail = 1,
    eFieldPhoneNumber = 2,
    eFieldLocation = 3,
    eFieldGender = 4,
    eFieldPasword = 5,
   
    
    
}ERegistrationField;


#define kHeightForHeader    50;
#define kHeightForFooter    120;
#define kTotalFields        6;
#define kCellHeight         50;


@interface RegistrationViewController () <GMSAutocompleteViewControllerDelegate>{
    
    IBOutlet UITableView *tableView;
    
    ERegistrationField registrationField;
    NSString *name;
    NSString *email;
    NSString *phoneNumber;
    NSString *gender;
    NSString *password;
    NSString *city;
    NSInteger indexForTextFieldNavigation;
    NSInteger totalRequiredFieldCount;
    UIView *inputAccView;
    
}

@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    
    // Do any additional setup after loading the view.
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView setContentInset:UIEdgeInsetsMake(0,0,50,0)];

    name = [NSString new];
    email = [NSString new];
    gender = [NSString new] ;
    phoneNumber = [NSString new];
    password = [NSString new];
    gender = @"1";
    totalRequiredFieldCount = kTotalFields;
    
    
    
    /*
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(0, 0)];
    [bezierPath addLineToPoint:CGPointMake(100, 0)];
    [bezierPath addLineToPoint:CGPointMake(0, 120)];
    CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
    [progressLayer setPath:bezierPath.CGPath];
    [progressLayer setFillColor:[UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0].CGColor];
    [self.view.layer addSublayer:progressLayer];
    
    float deviceWidth = self.view.frame.size.width;
    float deviceHeight = self.view.frame.size.height;
    bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(deviceWidth, deviceHeight)];
    [bezierPath addLineToPoint:CGPointMake(deviceWidth, deviceHeight - 150)];
    [bezierPath addLineToPoint:CGPointMake(deviceWidth - 150, deviceHeight)];
    progressLayer = [[CAShapeLayer alloc] init];
    [progressLayer setPath:bezierPath.CGPath];
    [progressLayer setFillColor:[UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0].CGColor];
    [self.view.layer addSublayer:progressLayer];
    */

}

#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return kTotalFields;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    RegistrationPageCustomTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    cell.vwGenderSelection.hidden = true;
    cell.entryField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cell.entryField.keyboardType = UIKeyboardTypeDefault;
    cell.entryField.secureTextEntry = false;
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    _tableView.backgroundColor = [UIColor clearColor];
    cell.borderBG.layer.borderColor = [[UIColor getBorderColor] CGColor];
    cell.borderBG.layer.borderWidth = 1.0f;
    cell.borderBG.layer.cornerRadius = 20.0f;
    
    NSInteger row = indexPath.row;
    switch (row) {
        case eFieldName:
            cell.entryField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            cell.entryField.tag = eFieldName;
            cell.entryField.text = name;
            cell.imgIcon.image = [UIImage imageNamed:@"Icon_Name"];
            break;
            
        case eFieldEmail:
             cell.entryField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
             cell.entryField.tag = eFieldEmail;
             cell.entryField.text = email;
             cell.imgIcon.image = [UIImage imageNamed:@"Icon_Email"];
             cell.entryField.keyboardType = UIKeyboardTypeEmailAddress;
             break;
            
        case eFieldPhoneNumber:
            cell.entryField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Phone Number" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            cell.entryField.tag = eFieldPhoneNumber;
            cell.entryField.text = phoneNumber;
            cell.entryField.keyboardType = UIKeyboardTypeNumberPad;
             cell.imgIcon.image = [UIImage imageNamed:@"Icon_Phone"];
            break;
            
        
            
        case eFieldLocation:
            cell.entryField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Location" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            cell.entryField.tag = eFieldLocation;
            cell.entryField.clearButtonMode = UITextFieldViewModeNever;
            cell.entryField.text = city;
            cell.imgIcon.image = [UIImage imageNamed:@"Icon_Location"];
            break;
        
            
        case eFieldGender:
            cell.entryField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Gender" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            cell.entryField.tag = eFieldGender;
            cell.entryField.clearButtonMode = UITextFieldViewModeNever;
            cell.vwGenderSelection.hidden = false;
            [cell.btnFemale setImage:[UIImage imageNamed:@"Radio_Inactive"] forState:UIControlStateNormal];
            [cell.btnMale setImage:[UIImage imageNamed:@"Radio_Inactive"] forState:UIControlStateNormal];
            cell.btnMale.backgroundColor = [UIColor clearColor];
            cell.btnFemale.layer.borderColor = [UIColor clearColor].CGColor;
            cell.btnMale.layer.borderColor = [UIColor clearColor].CGColor;
            cell.imgIcon.image = [UIImage imageNamed:@"Icon_Gender"];
            if ([gender isEqualToString:@"1"])
                [cell.btnMale setImage:[UIImage imageNamed:@"Radio_Active"] forState:UIControlStateNormal];
            else
                 [cell.btnFemale setImage:[UIImage imageNamed:@"Radio_Active"] forState:UIControlStateNormal];
            break;
            
        case eFieldPasword:
            cell.entryField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            cell.entryField.tag = eFieldPasword;
            cell.entryField.text = password;
            cell.entryField.secureTextEntry = true;
            cell.imgIcon.image = [UIImage imageNamed:@"Icon_Pwd"];
            break;

        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return  kHeightForFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeightForHeader;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor clearColor];
    
    UILabel *lblTitle = [UILabel new];
    lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblTitle];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    lblTitle.text = @"Sign Up";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont fontWithName:CommonFontBold size:18];
    lblTitle.textColor = [UIColor whiteColor];
    
    return vwHeader;
}



- (nullable UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section{
    
    UIView *vwFooter = [UIView new];
    vwFooter.backgroundColor = [UIColor clearColor];
    
    UIButton* btnRegister = [UIButton new];
    btnRegister.backgroundColor = [UIColor getThemeColor];
    btnRegister.translatesAutoresizingMaskIntoConstraints = NO;
    [btnRegister setTitle:@"SIGN UP" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRegister.titleLabel.font = [UIFont fontWithName:CommonFontBold size:15];
    [btnRegister addTarget:self action:@selector(tapToRegister:) forControlEvents:UIControlEventTouchUpInside];
    [vwFooter addSubview:btnRegister];
    btnRegister.layer.borderColor = [[UIColor clearColor] CGColor];
    btnRegister.layer.borderWidth = 1.0f;
    btnRegister.layer.cornerRadius = 20.0f;
    btnRegister.clipsToBounds = YES;
    
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
                                                          constant:25]];
    
    NSArray *horizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[btnRegister]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnRegister)];
    [vwFooter addConstraints:horizontalConstraints];
    
    float width = aTableView.frame.size.width - 10;
    UIColor *topColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.16 alpha:1.0];
    UIColor * bottomColor = [UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, width, 40);
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);



    [btnRegister.layer addSublayer:gradient];
    [btnRegister.layer insertSublayer:gradient atIndex:0];
    
    UIButton* btnLogin = [UIButton new];
    btnLogin.backgroundColor = [UIColor clearColor];
    btnLogin.translatesAutoresizingMaskIntoConstraints = NO;
    [btnLogin setTitle:@"Already have an Account? Login" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnLogin.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnLogin addTarget:self action:@selector(showLoginScreen) forControlEvents:UIControlEventTouchUpInside];
    [btnLogin setTitleEdgeInsets:UIEdgeInsetsMake(0, -16, 0, 0)];//set ur title insects
    [vwFooter addSubview:btnLogin];
    
    [btnLogin addConstraint:[NSLayoutConstraint constraintWithItem:btnLogin
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:40]];
    
    [btnLogin addConstraint:[NSLayoutConstraint constraintWithItem:btnLogin
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:200]];
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnLogin
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:btnRegister
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0]];
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnLogin
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:btnRegister
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0]];
    

    
    
    return vwFooter;
}

-(IBAction)setAgeOfUser:(UIButton*)sender{
    gender = @"1";
    if (sender.tag == 2) {
        gender = @"2";
    }
    [tableView reloadData];
}

#pragma mark - TextField Delegates


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
        RegistrationPageCustomTableViewCell *cell = (RegistrationPageCustomTableViewCell*)textField.superview.superview;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromField:cell.entryField];
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self createInputAccessoryView];
    [textField setInputAccessoryView:inputAccView];
    // activeTextField = textField;
    NSIndexPath *indexPath;
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        indexForTextFieldNavigation = indexPath.row;
    }
    
    if (indexForTextFieldNavigation == eFieldGender) {
        return NO;
    }
    if (indexForTextFieldNavigation == eFieldLocation) {
        [self showLocationPikcer];
        return NO;
    }
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
     /*! Gender selection !*/
    
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL allowed = YES;
    // Prevent invalid character input, if keyboard is numberpad
    if (textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            // BasicAlert(@"", @"This field accepts only numeric entries.");
            allowed =  NO;
        }
    }
    
    return allowed;
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Registration Methods


-(void)createInputAccessoryView{
    
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    
    UIButton *btnPrev = [UIButton buttonWithType: UIButtonTypeCustom];
    [btnPrev setFrame: CGRectMake(0.0, 1.0, 80.0, 38.0)];
    [btnPrev setTitle: @"PREVIOUS" forState: UIControlStateNormal];
    [btnPrev setBackgroundColor: [UIColor getHeaderOffBlackColor]];
    btnPrev.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    btnPrev.layer.cornerRadius = 5.f;
    btnPrev.layer.borderWidth = 1.f;
    btnPrev.layer.borderColor = [UIColor clearColor].CGColor;
    [btnPrev addTarget: self action: @selector(gotoPrevTextfield) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setFrame:CGRectMake(85.0f, 1.0f, 80.0f, 38.0f)];
    [btnNext setTitle:@"NEXT" forState:UIControlStateNormal];
    [btnNext setBackgroundColor:[UIColor getHeaderOffBlackColor]];
    btnNext.layer.cornerRadius = 5.f;
    btnNext.layer.borderWidth = 1.f;
    btnNext.layer.borderColor = [UIColor clearColor].CGColor;
    btnNext.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnNext addTarget:self action:@selector(gotoNextTextfield) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    [inputAccView addSubview:btnPrev];
    [inputAccView addSubview:btnNext];
    [inputAccView addSubview:btnDone];
}

-(void)gotoPrevTextfield{
    
    if (indexForTextFieldNavigation - 1 < 0) indexForTextFieldNavigation = 0;
    else{
        indexForTextFieldNavigation -= 1;
        if (indexForTextFieldNavigation == eFieldGender) {
            indexForTextFieldNavigation -= 1;
        }
    }
    
    [self gotoTextField];
    
}

-(void)gotoNextTextfield{
    
    if (indexForTextFieldNavigation + 1 < totalRequiredFieldCount){
        indexForTextFieldNavigation += 1;
        if (indexForTextFieldNavigation == eFieldGender) {
            indexForTextFieldNavigation += 1;
        }
    }
    
    [self gotoTextField];
}

-(void)gotoTextField{
    
    RegistrationPageCustomTableViewCell *nextCell = (RegistrationPageCustomTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0]];
    if (!nextCell) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        nextCell = (RegistrationPageCustomTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0]];
        
    }
    [nextCell.entryField becomeFirstResponder];
    
}

-(void)doneTyping{
    [self.view endEditing:YES];
    
}


-(void)getTextFromField:(UITextField*)textField{
   
    NSString *string = textField.text;
    NSInteger tag = textField.tag;
    switch (tag) {
        case eFieldName:
            name = string;
            break;
        case eFieldEmail:
            email = string;
            break;
        case eFieldPhoneNumber:
            phoneNumber = string;
            break;
        case eFieldGender:
            gender = string;
            break;
        case eFieldPasword:
            password = string;
            break;
       
            break;
        default:
            break;
    }
   
}

-(IBAction)showLoginScreen{
    
      [self gotoLoginPage];
}

#pragma mark - Location Picker

-(IBAction)showLocationPikcer{
    
    [self.view endEditing:YES];
     [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor getBlackTextColor]}];
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    acController.autocompleteFilter.type = kGMSPlacesAutocompleteTypeFilterCity;
    [self presentViewController:acController animated:YES completion:nil];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    city = place.name;
    [tableView reloadData];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
   [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



-(IBAction)tapToRegister:(id)sender{
    
    [self.view endEditing:YES];
    [self checkAllFieldsAreValid:^{
        
        [self showLoadingScreen];
        [APIMapper registerUserWithName:name userEmail:email phoneNumber:phoneNumber gender:gender location:city userPassword:password
                                success:^(AFHTTPRequestOperation *operation, id responseObject){
            
                                    NSDictionary *responds = (NSDictionary*)responseObject;
                                    if ( NULL_TO_NIL( [responds objectForKey:@"text"]))
                                         [self showAlertWithMessage:[responds objectForKey:@"text"] title:@"SignUp"];
                                    [self gotoLoginPage];
                                    [self hideLoadingScreen];
                           
                                }
         
                                failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                    
                                 [self showAlertWithMessage:[error localizedDescription] title:@"SignUp"];
                                 [self hideLoadingScreen];
                                    
                                }];

        
    } failure:^(NSString *error) {
        
        // Field validation error block
        
        [self showAlertWithMessage:error title:@"SignUp"];
        
    }];
    

}

-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;

}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
}
-(void)checkAllFieldsAreValid:(void (^)())success failure:(void (^)(NSString *error))failure{
    
    NSString *errorMessage;
    BOOL isValid = false;
    if ((name.length) && (email.length) && (gender.length) && (phoneNumber.length) && (city.length) && (password.length) > 0){
        isValid = [email isValidEmail] ? YES : NO;
        errorMessage = @"Please enter a valid Email address";
        
    }else{
        
        errorMessage = @"Please fill all the fields";
    }
    if (isValid)success();
    else failure(errorMessage);

}

-(void)showAlertWithMessage:(NSString*)alertMessage title:(NSString*)alertTitle{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)gotoLoginPage{
    if (!_isFromWelcomePage) {
         [[self navigationController]popViewControllerAnimated:YES];
    }else{
        LoginViewController *loginPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForLogin Identifier:StoryBoardIdentifierForLoginPage];
        [self.navigationController pushViewController:loginPage animated:YES];
        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
        if (navigationArray.count >= 2) {
            [navigationArray removeObjectAtIndex:navigationArray.count - 2];
            self.navigationController.viewControllers = navigationArray;

        }
    }
   
    [self.view endEditing:YES];
}

-(IBAction)goBack:(id)sender{
    
    [[self navigationController]popViewControllerAnimated:YES];
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
