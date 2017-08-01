//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "EditProfileViewController.h"
#import "Constants.h"
#import "ProfileCell.h"
#import <GooglePlaces/GooglePlaces.h>
#import "CustomeImagePicker.h"

@interface EditProfileViewController () <GMSAutocompleteViewControllerDelegate,CustomeImagePickerDelegate>{
    
    
    IBOutlet UISearchBar *searchBar;
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    IBOutlet UIButton* btnEdit;
    BOOL isDataAvailable;
    NSString *strAPIErrorMsg;
    NSDictionary *userInfo;
    UIView *inputAccView;
    
    NSString *strUserName;
    NSString *strLocation;
    NSString *strStatusMsg;
    UIImage *imgProfilePic;
    BOOL isUpdated;
    
}

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self createInputAccessoryView];
    [self getUserProfile];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    tableView.hidden = true;
    btnEdit.hidden = true;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    tableView.clipsToBounds = YES;
    tableView.layer.cornerRadius = 5.f;
    tableView.layer.borderWidth = 1.f;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    float width = 720;
    float height = 460;
    float ratio = width / height;
    float imageHeight = (self.view.frame.size.width) / ratio;
    constraintForNavBg.constant = imageHeight;
}

-(void)getUserProfile{
    
    [Utility showLoadingScreenOnView:self.view withTitle:@"Loading"];
    [APIMapper getUserProfileWithUserID:[User sharedManager].userId OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        btnEdit.hidden = false;
        tableView.hidden = false;
        [self showProfileWith:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        tableView.hidden = false;
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        [tableView reloadData];
        
        [Utility hideLoadingScreenFromView:self.view];

    }];
    
}

-(void)showProfileWith:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        userInfo =  [responds objectForKey:@"data"];
    if (userInfo) isDataAvailable = true;
    strLocation = [userInfo objectForKey:@"location"];
    strUserName = [userInfo objectForKey:@"name"];
    strStatusMsg = [userInfo objectForKey:@"status_msg"];
    if ([_strUserID isEqualToString:[User sharedManager].userId]) {
        btnEdit.hidden = false;
    }
    [tableView reloadData];
    
    
}



#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 2;
    if (!isDataAvailable) {
        rows = 1;
    }
    return rows;

}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (!isDataAvailable) {
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strAPIErrorMsg];
        return cell;
    }
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"PorfileInfo";
        ProfileCell *cell = (ProfileCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.lblLoc.text = strLocation;
        cell.txtField.text = strUserName;
        cell.lblEmail.text = [userInfo objectForKey:@"email"];
        cell.lblRegStatus.text = [NSString stringWithFormat:@"Member since %@",[self getDayFromSeconds:[[userInfo objectForKey:@"reg_date"] doubleValue]]];
        if (!imgProfilePic) {
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"profileurl"]]
                             placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                        
                                    }];

        }else{
            cell.imgUser.image = imgProfilePic;
        }
        return cell;
    }
    else if (indexPath.row == 1){
        static NSString *CellIdentifier = @"StatusMessage";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([[cell contentView] viewWithTag:1]) {
            UITextView *txtView = (UITextView*)[[cell contentView] viewWithTag:1];
            txtView.text = strStatusMsg;
            txtView.layer.cornerRadius = 5.f;
            txtView.layer.borderWidth = 1.f;
            txtView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
        }
        return cell;
    }
        
    return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}


#pragma mark - UITextView delegate methods


-(void)textViewDidEndEditing:(UITextView *)textField
{
    [textField resignFirstResponder];
    
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}


-(BOOL)textViewShouldEndEditing:(UITextView *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromStatusField:textField];
    }
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textField {
    
     [textField setInputAccessoryView:inputAccView];
    NSIndexPath *indexPath;
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
    
    return YES;
    
}

-(void)textViewDidBeginEditing:(UITextView *)textField {
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
}

#pragma mark - UITextField delegate methods


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromNameField:textField];
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [textField setInputAccessoryView:inputAccView];
    NSIndexPath *indexPath;
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
    
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
}

-(void)createInputAccessoryView{
    
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    [inputAccView setAlpha:1];
    
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
    
    [inputAccView addSubview:btnDone];
}

-(void)doneTyping{
    
    [self.view endEditing:YES];
}

-(void)getTextFromNameField:(UITextField*)textView{
    
    strUserName = textView.text;
    [tableView reloadData];
}

-(void)getTextFromStatusField:(UITextView*)textView{
    
    strStatusMsg = textView.text;
    [tableView reloadData];
}

#pragma mark - Location Picker

-(IBAction)showLocationPikcer{
    
    [self.view endEditing:YES];
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    acController.autocompleteFilter.type = kGMSPlacesAutocompleteTypeFilterCity;
    [self presentViewController:acController animated:YES completion:nil];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    strLocation = place.name;
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

#pragma mark - Image Picker


-(IBAction)showImagePicker{
    
    [self.view endEditing:YES];
    CustomeImagePicker *cip = [[CustomeImagePicker alloc] init];
    cip.delegate = self;
    cip.isPhotos = YES;
    [cip setHideSkipButton:NO];
    [cip setHideNextButton:NO];
    [cip setMaxPhotos:MAX_ALLOWED_PICK];
    
    [self presentViewController:cip animated:YES completion:^{
    }];
    
}



-(void)imageSelected:(NSArray*)arrayOfGallery isPhoto:(BOOL)isPhoto;
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utility showLoadingScreenOnView:self.view withTitle:@"Loading"];
        }); // Main Queue to Display the Activity View
        __block NSInteger imageCount = 0;
        __block NSInteger videoCount = 0;
        
        for(NSString *imageURLString in arrayOfGallery)
        {
            // Asset URLs
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary assetForURL:[NSURL URLWithString:imageURLString] resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                if (isPhoto) {
                    
                    // IMAGE
                    
                    CGImageRef imageRef = [representation fullScreenImage];
                    UIImage *image = [UIImage imageWithCGImage:imageRef];
                    if (imageRef) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imgProfilePic = image;
                        });
                        imageCount ++;
                        
                        if (imageCount + videoCount == arrayOfGallery.count) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                 [Utility hideLoadingScreenFromView:self.view];
                                [self performSelector:@selector(reloadTable) withObject:self afterDelay:0];
                            });
                        }
                    }
                }
                // Valid Image URL
            } failureBlock:^(NSError *error) {
            }];
        } // All Images I got
        
        
    });
    
    
}

-(void)reloadTable{
    
    [tableView reloadData];
}

-(NSString*)getDayFromSeconds:(double)timeInSeconds{
    
    NSDate * today = [NSDate date];
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:refDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:today];
    //    NSDateComponents *difference = [calendar components:NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute
    //                                               fromDate:fromDate toDate:toDate options:0];
    NSString *msgDate;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy"];
    msgDate = [dateformater stringFromDate:refDate];
    return msgDate;
    
}

#pragma mark - Submit Methods

-(IBAction)submitDetails{
    
    
    [self uploadMediaOnsuccess:^(NSDictionary *responds) {
        
        NSString *mediaFileName;
        if ([responds objectForKey:@"data"]) {
            NSDictionary *data = [responds objectForKey:@"data"];
            mediaFileName = [data objectForKey:@"media_file"];
        }
        [APIMapper updateProfileWithUserID:[User sharedManager].userId name:strUserName statusMsg:strStatusMsg city:strLocation gender:0 mediaFileName:mediaFileName success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [Utility hideLoadingScreenFromView:self.view];
            [self updateUserData:responseObject];
            if ([responseObject objectForKey:@"text"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UPDATE PROFILE"
                                                                message:[responseObject objectForKey:@"text"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                isUpdated = true;
            }
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [Utility hideLoadingScreenFromView:self.view];
            
        }];
        
    } failure:^{
        
    }];
}

-(void)updateUserData:(NSDictionary*)_userInfo{
    
    if ( NULL_TO_NIL([_userInfo objectForKey:@"data"])) {
        NSDictionary *userDetails = [_userInfo objectForKey:@"data"];
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
        NSString *location = [userDetails objectForKey:@"location"];
        if (location.length) {
            [User sharedManager].location  = [userDetails objectForKey:@"location"];
        }
       
        [Utility saveUserObject:[User sharedManager] key:@"USER"];
        /*!............ Saving user to NSUserDefaults.............!*/
    }
   
}


-(void)uploadMediaOnsuccess:(void (^)(NSDictionary *responds ))success failure:(void (^)())failure{
    
    if (strLocation && strUserName && strStatusMsg) {
        if (imgProfilePic) {
            [Utility showLoadingScreenOnView:self.view withTitle:@"Updating.."];
            [APIMapper uploadGameMediasWith:nil thumbnail:imgProfilePic type:@"profile" Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                success(responseObject);
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [Utility hideLoadingScreenFromView:self.view];
                failure();
            }];
        }else{
            // No Media to uplaod
             [Utility showLoadingScreenOnView:self.view withTitle:@"Updating.."];
            success(nil);
        }
        
    }else{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Update Profile"
                                                                       message:@"Fill all the fields"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              }];
        
        [alert addAction:firstAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void)displayErrorMessgeWithDetails:(NSData*)responseData{
    if (responseData.length) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                               error:&error];
        if (NULL_TO_NIL([json objectForKey:@"text"]))
            strAPIErrorMsg = [json objectForKey:@"text"];
        
        isDataAvailable = false;
        
    }
    
}

-(IBAction)goBack:(id)sender{
    
    if (isUpdated) [[self delegate]sholdRefresh];
    [self.view endEditing:YES];
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
