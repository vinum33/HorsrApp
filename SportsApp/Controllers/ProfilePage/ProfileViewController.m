//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "ProfileViewController.h"
#import "Constants.h"
#import "ProfileCell.h"
#import "ChangePasswordPopUp.h"
#import "EditProfileViewController.h"

@interface ProfileViewController () <ChangePasswordPopUpDelegate,EditProfileDelegate>{
    
    ChangePasswordPopUp *changePwdPopUp;
    
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
    
}

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
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
    [APIMapper getUserProfileWithUserID:_strUserID OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    NSInteger rows = 3;
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
        cell.lblName.text = strUserName;
        cell.lblEmail.text = [userInfo objectForKey:@"email"];
        cell.lblRegStatus.text = [NSString stringWithFormat:@"Member since %@",[self getDayFromSeconds:[[userInfo objectForKey:@"reg_date"] doubleValue]]];
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];

        return cell;
    }
    else if (indexPath.row == 1){
        static NSString *CellIdentifier = @"ChangePWD";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 2){
        static NSString *CellIdentifier = @"StatusMessage";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([[cell contentView] viewWithTag:1]) {
            UILabel *lblStatus = (UILabel*)[[cell contentView] viewWithTag:1];
            lblStatus.text = strStatusMsg;
        }
        return cell;
    }
        
    return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 1) {
        [self changePassowrd];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row == 1) {
        if (![_strUserID isEqualToString:[User sharedManager].userId]) {
             return 0;
        }
       
    }
    return UITableViewAutomaticDimension;
}




#pragma mark - IBActions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    EditProfileViewController *vc = segue.destinationViewController;
    vc.delegate = self;
}

-(void)sholdRefresh{
    
    [self getUserProfile];
}

-(IBAction)editProfile{
    
    
}

-(IBAction)changePassowrd{
    if (!changePwdPopUp) {
        
        changePwdPopUp = [ChangePasswordPopUp new];
        [self.view addSubview:changePwdPopUp];
        changePwdPopUp.delegate = self;
        changePwdPopUp.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.7];;
        changePwdPopUp.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[changePwdPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(changePwdPopUp)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[changePwdPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(changePwdPopUp)]];
        
        changePwdPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            changePwdPopUp.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
        
    }
    
    [self.view endEditing:YES];
    [changePwdPopUp setUp];
    
}

-(void)closeForgotPwdPopUpAfterADelay:(float)delay{
    
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        changePwdPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [changePwdPopUp removeFromSuperview];
        changePwdPopUp = nil;
    }];
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
