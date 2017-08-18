//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

typedef enum{
    
    eCellUserInfo    = 0,
    eCellDescription  = 1,
    eCellVideo      = 2,
    eCellLocation = 3,
    eCellFriends = 4,
    
    
}eMenuType;

#import "ShareGameViewController.h"
#import "Constants.h"
#import "ShareUserCell.h"
#import "ShareVideoCell.h"
#import "InviteOthersViewController.h"
#import "AHTag.h"
#import <GooglePlaces/GooglePlaces.h>
#import "AHTagTableViewCell.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ShareGameViewController ()<InviteUserDeleagte,GMSAutocompleteViewControllerDelegate> {
        
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    NSMutableArray *arrInvites;
    NSString *strCity;
    NSMutableString *strFriends;
    NSString *strMessage;
    NSMutableString *strAddress;
    UIView *inputAccView;
    
}

@end

@implementation ShareGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createInputAccessoryView];
    [self setUp];
    // Do any additional setup after loading the view.
}


-(void)setUp{
    
    strAddress = [NSMutableString new];
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
    
    [inputAccView addSubview:btnDone];
}

-(void)doneTyping{
    
    [self.view endEditing:YES];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 5;
   
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case eCellUserInfo:
            cell = [self congigureUserInfoCell];
            break;
            
        case eCellDescription:
            cell = [self congigureDescriptionCell];
            break;
            
        case eCellVideo:
            cell = [self congigureVideoCell];
            break;
            
        case eCellLocation:
            cell = [self congigureLocationCell];
            break;
            
        case eCellFriends:
            cell = [self congigureFriendsCellForIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
   
    
}



- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == eCellLocation) {
        [self showLocationPikcer];
    }
    if (indexPath.row == eCellVideo) {
        [self playRecordedVideo:nil];
    }
    
}


-(ShareUserCell*)congigureUserInfoCell{
    
    static NSString *CellIdentifier = @"ShareUserCell";
    ShareUserCell *cell = (ShareUserCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.lblName.text =  [_userInfo objectForKey:@"name"];
    [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[_userInfo objectForKey:@"profileurl"]]
                     placeholderImage:[UIImage imageNamed:@"NoImage"]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                
                            }];
    
    
    
    

    return cell;
}
-(UITableViewCell*)congigureDescriptionCell{
    
    static NSString *CellIdentifier = @"DescriptionCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([[cell contentView] viewWithTag:1]) {
        UITextView *txtView = (UITextView*)[[cell contentView] viewWithTag:1];
        txtView.text = strMessage;
    }
    return cell;
}
-(ShareVideoCell*)congigureVideoCell{
    
    static NSString *CellIdentifier = @"ShareVideoCell";
    ShareVideoCell *cell = (ShareVideoCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSArray *videos = [_userInfo objectForKey:@"video"];
    if (videos.count) {
        NSDictionary *video = [videos lastObject];
        float width = [[video objectForKey:@"width"] integerValue];
        float height = [[video objectForKey:@"height"] integerValue];;
        float ratio = width / height;
        float imageHeight = (self.view.frame.size.width - 30) / ratio;
        cell.constraintForHeight.constant = imageHeight;
        [cell.imgThumb sd_setImageWithURL:[NSURL URLWithString:[video objectForKey:@"imageurl"]]
                         placeholderImage:[UIImage imageNamed:@"NoImage"]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    
                                }];
    }
    return cell;
}

-(UITableViewCell*)congigureLocationCell{
    
    static NSString *CellIdentifier = @"LocationCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([cell.contentView viewWithTag:1]) {
        UILabel *lblLoc = (UILabel*)[cell.contentView viewWithTag:1];
        lblLoc.text = @"Add Location";
        if (strAddress.length)lblLoc.text = strAddress;
    }
    return cell;
}

-(UITableViewCell*)congigureFriendsCellForIndexPath:(NSIndexPath*)indexPath{
    
    if (arrInvites.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaggedFriends" forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        static NSString *CellIdentifier = @"FriendsCell";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        return cell;
    }

   
}

- (void)configureCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    if (![object isKindOfClass:[AHTagTableViewCell class]]) {
        return;
    }
    AHTagTableViewCell *cell = (AHTagTableViewCell *)object;
    cell.label.tags = arrInvites;
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

-(void)getTextFromStatusField:(UITextView*)textView{
    
    strMessage = textView.text;
    [tableView reloadData];
}

#pragma mark - VIDOEO PLAY

-(IBAction)playRecordedVideo:(id)sender{
    
    NSArray *videos = [_userInfo objectForKey:@"video"];
    if (videos.count) {
        NSDictionary *video = [videos lastObject];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:[NSURL URLWithString:[video objectForKey:@"videourl"]]];
        [playerViewController.player play];
        [self presentViewController:playerViewController animated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[playerViewController.player currentItem]];
    }
  
    
}


- (void)videoDidFinish:(id)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //fade out / remove subview
}


#pragma mark - Search Invites


-(void)userInvitedWithList:(NSMutableArray*)users{
    
    arrInvites = [NSMutableArray new];
    NSMutableArray *names = [NSMutableArray new];
    for (NSDictionary *dict in users) {
        AHTag *tag = [AHTag new];
        tag.title = [dict objectForKey:@"name"];
        tag.userID = [dict objectForKey:@"user_id"];
        [arrInvites addObject:tag];
        [names addObject:[dict objectForKey:@"name"]];
    }
    strFriends = [NSMutableString stringWithString:[names componentsJoinedByString:@","]];
    [tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSMutableArray *arrIDS = [NSMutableArray new];
    for (AHTag *tag in arrInvites) {
        [arrIDS addObject:tag.userID];
    }
    InviteOthersViewController *vc = segue.destinationViewController;
    vc.isFromTagFriends = YES;
    vc.delegate = self;
    vc.selectedUsers = arrIDS;
}


#pragma mark - Location Picker

-(IBAction)showLocationPikcer{
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor getBlackTextColor]}];
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
    [strAddress setString:@""];
    strCity = place.name;
    [strAddress appendString:strCity];
    for (GMSAddressComponent *comp in [place addressComponents]) {
        if ([comp.type isEqualToString:@"locality"]) {
            [strAddress appendString:[NSString stringWithFormat:@",%@",comp.name]];
        }
        if ([comp.type isEqualToString:@"administrative_area_level_1"]) {
            [strAddress appendString:[NSString stringWithFormat:@",%@",comp.name]];
        }
    }
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

#pragma mark - POST METHODS

-(IBAction)shareVideo:(id)sender{
    
    [self.view endEditing:YES];
    [Utility showLoadingScreenOnView:self.view withTitle:@"Posting.."];
    NSArray *videos = [_userInfo objectForKey:@"video"];
    if (videos.count) {
        NSDictionary *video = [videos lastObject];
        NSMutableArray *arrIDS = [NSMutableArray new];
        for (AHTag *tag in arrInvites) {
            [arrIDS addObject:tag.userID];
        }
        
        [APIMapper shareVideoWithVideoID:[video objectForKey:@"video_id"] location:strCity address:strAddress message:strMessage frieds:arrIDS success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [Utility hideLoadingScreenFromView:self.view];
            if ([responseObject objectForKey:@"text"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SHARE VIDEO"
                                                                message:[responseObject objectForKey:@"text"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self goBack:nil];
            }
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            [Utility hideLoadingScreenFromView:self.view];
            if (task.responseData) [self displayErrorMessgeWithDetails:task.responseData];
            else [self showAlertWithMessage:error.localizedDescription];
            
        }];

    }
    
        
        
}

-(void)displayErrorMessgeWithDetails:(NSData*)responseData{
    if (responseData.length) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                               error:&error];
        if (NULL_TO_NIL([json objectForKey:@"text"]))
            [self showAlertWithMessage:[json objectForKey:@"text"]];
        
        
    }
    
}

-(void)showAlertWithMessage:(NSString*)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SHARE VIDEO"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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
