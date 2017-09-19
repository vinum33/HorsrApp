//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"
#import "ProfileCell.h"

@interface SettingsViewController () {
        
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    BOOL isDataAvailable;
    NSString *strAPIErrorMsg;
    NSDictionary *userInfo;
    
    BOOL canNotify;
    BOOL canInvite;
    
    
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getUserProfile];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    tableView.hidden = true;
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
    
    [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    [APIMapper getUserProfileWithUserID:[User sharedManager].userId OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        [self showProfileWith:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
       [Utility hideLoadingScreenFromView:self.view];
        tableView.hidden = false;
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        [tableView reloadData];
    }];
    
}

-(void)showProfileWith:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        userInfo =  [responds objectForKey:@"data"];
    canNotify = [[userInfo objectForKey:@"notify_status"] boolValue];
    canInvite = [[userInfo objectForKey:@"invite_status"] boolValue];
    if (userInfo) isDataAvailable = true;
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
        cell.lblLoc.text = [userInfo objectForKey:@"location"];
        cell.lblName.text = [userInfo objectForKey:@"name"];
        cell.lblEmail.text = [userInfo objectForKey:@"email"];
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        

        return cell;
    }
    else if (indexPath.row == 1){
        static NSString *CellIdentifier = @"Settings";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([[cell contentView] viewWithTag:1]) {
            UISwitch *swtch = (UISwitch*)[[cell contentView] viewWithTag:1];
            [swtch setOn:canNotify];
        }
        if ([[cell contentView] viewWithTag:2]) {
            UISwitch *swtch = (UISwitch*)[[cell contentView] viewWithTag:2];
            [swtch setOn:canInvite];
        }
        return cell;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}
- (nullable UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section{
    
    if (!isDataAvailable) {
        return nil;
    }
    UIView *vwFooter = [UIView new];
    vwFooter.backgroundColor = [UIColor clearColor];
    
    UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [vwFooter addSubview:btnSend];
    btnSend.translatesAutoresizingMaskIntoConstraints = NO;
    [btnSend addTarget:self action:@selector(saveSettings)
      forControlEvents:UIControlEventTouchUpInside];
    btnSend.layer.borderColor = [UIColor clearColor].CGColor;
    btnSend.titleLabel.font = [UIFont fontWithName:CommonFontBold size:15];
    [btnSend setTitle:@"SAVE SETTINGS" forState:UIControlStateNormal];
    [btnSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[btnSend]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnSend)]];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[btnSend]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnSend)]];
    btnSend.layer.borderColor = [[UIColor clearColor] CGColor];
    btnSend.layer.borderWidth = 1.0f;
    btnSend.layer.cornerRadius = 20.0f;
    btnSend.clipsToBounds = YES;
    
    float width = aTableView.frame.size.width - 20;
    UIColor *topColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.16 alpha:1.0];
    UIColor * bottomColor = [UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, width, 40);
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);

    [btnSend.layer addSublayer:gradient];
    [btnSend.layer insertSublayer:gradient atIndex:0];
    
    return vwFooter;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (!isDataAvailable) {
        return 0;
    }
    return 60;
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

-(IBAction)switchChanged:(UISwitch*)sender{
    
    if (sender.tag == 1) {
        canNotify = false;
        if ([sender isOn]) {
            canNotify = true;
        }
    }
    else if(sender.tag == 2) {
        canInvite = false;
        if ([sender isOn]) {
            canInvite = true;
        }
    }
   // [tableView reloadData];
}

-(void)saveSettings{
    
    [Utility showLoadingScreenOnView:self.view withTitle:@"Saving.."];
    
    [APIMapper updateUserSettingsWithNotifyValue:canNotify inviteStatus:canInvite Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Utility hideLoadingScreenFromView:self.view];
        if ([responseObject objectForKey:@"text"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UPDATE SETTINGS"
                                                            message:[responseObject objectForKey:@"text"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }

        
    }failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [Utility hideLoadingScreenFromView:self.view];
    }];


    
    
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
