//
//  ChatComposeViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kSectionCount               1
#define kMinimumCellCount           1



#import "CreatedGameSummaryViewController.h"
#import "Constants.h"
#import "CommentCell.h"
#import "HPGrowingTextView.h"
#import "ProfileViewController.h"

@interface CreatedGameSummaryViewController () {
    
    IBOutlet UIView *vwBG;
    IBOutlet UITableView *tableView;
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    
    NSMutableArray *arrMessages;
    UIButton *btnDone;;
    
    BOOL isPageRefresing;
    NSInteger totalPages;
    HPGrowingTextView *textView;
    UIView *containerView;
    NSInteger currentPage;
    BOOL isDataAvailable;
    NSString *strAPIErrorMsg;
}

@end

@implementation CreatedGameSummaryViewController

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
    isDataAvailable = false;
    currentPage = 1;
    arrMessages = [NSMutableArray new];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    tableView.clipsToBounds = YES;
    vwBG.layer.cornerRadius = 5.f;
    vwBG.layer.borderWidth = 1.f;
    vwBG.backgroundColor = [UIColor whiteColor];
    vwBG.layer.borderColor = [UIColor clearColor].CGColor;
    tableView.hidden = true;
    
    
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}



#pragma mark - UITableViewDataSource Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable) {
        return 1;
    }
    return arrMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDataAvailable) {
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strAPIErrorMsg];
        return cell;
    }
    CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    if (indexPath.row < arrMessages.count ) {
        
        NSDictionary *comment = (NSDictionary *) [arrMessages objectAtIndex:indexPath.row];
        cell.btnRemove.hidden = true;
        cell.btnRemove.tag = indexPath.row;
        cell.lblName.text = [comment objectForKey:@"firstname"];
        double serverTime = [[comment objectForKey:@"comment_datetime"] doubleValue];
        cell.lblTime.text = [Utility getDateDescriptionForChat:serverTime];
        cell.lblMessage.text = [comment objectForKey:@"comment_txt"];
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[comment objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        if ([[comment objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId]) {
            cell.btnRemove.hidden = false;
        }
        
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;

   
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    

    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}



#pragma mark - Generic Methods



-(void)displayErrorMessgeWithDetails:(NSData*)responseData{
    if (responseData.length) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                               error:&error];
        if (NULL_TO_NIL([json objectForKey:@"text"]))
            strAPIErrorMsg = [json objectForKey:@"text"];
        
        isDataAvailable = false;
        [tableView reloadData];
        
    }
    
}


-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(IBAction)showUserProfilePage:(UITapGestureRecognizer*)gesture{
    
//    if (NULL_TO_NIL([_chatUserInfo objectForKey:@"chatuser_id"])) {
//        ProfileViewController *profile =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GeneralStoryBoard Identifier:StoryBoardIdentifierForProfile];
//        profile.strUserID = [_chatUserInfo objectForKey:@"chatuser_id"];
//        [self.navigationController pushViewController:profile animated:YES];
//        
//    }
    
    
}




-(void)tableScrollToLastCell{
    
    if (arrMessages.count ) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:arrMessages.count - 1 inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:YES];
    }
    [self.view endEditing:YES];
    

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

-(IBAction)goBack:(id)sender{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
