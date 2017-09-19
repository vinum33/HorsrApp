
//
//  HomeViewController.m
//  SignSpot
//
//  Created by Purpose Code on 12/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//


typedef enum{
    
    eMenuCreateGame    = 0,
    eMenuSharedVideo  = 1,
    eMenuAllGames  = 2,
    eMenuNotifications = 3,
    eMenuChatList = 4,
    eMenuSettings = 5,
    eMenuLogout = 6,
    eMenuProfile = 7,
    eMenuConatct = 8
    
    
}eMenuType;

typedef enum{
    
    eSectionUserInfo    = 0,
    eSectionPlayReq     = 1,
    eSectionPeople      = 2,
    
    
}eSectionType;

typedef enum{
    
    eTypeCreateReq       = 0,
    eTypeRequested       = 1,
    eTypeAccept          = 2,
    eTypeFriends       = 3,
    
}eReqType;




#define kPadding                10
#define kDefaultNumberOfCells   1
#define kCellHeight             250
#define kProductCellHeight      250
#define kProductCellWidth       250
#define kHeightForHeader        45
#define kHeightForFooter        5
#define kDefaultNumberOfCells   1
#define kDefaultNavHeight       105
#define kLimitReached           406

#import <AVFoundation/AVFoundation.h>
#import "HomeViewController.h"
#import "Constants.h"
#import "MenuViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Google/SignIn.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PlayerListTableViewCell.h"
#import "TableHeader.h"
#import "PeopleListHeader.h"
#import "PlayerReqListCell.h"
#import "ReqListHeader.h"
#import "ListGamesViewController.h"
#import "CreateGameViewController.h"
#import "SharedVideosViewController.h"
#import "SearchFriendsViewController.h"
#import <AVKit/AVKit.h>
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "PlayedGameDetailPageViewController.h"
#import "GameZoneViewController.h"
#import "NotificationsViewController.h"
#import "GroupChatComposeViewController.h"
#import "PrivateChatComposeViewController.h"
#import "JCNotificationCenter.h"
#import "JCNotificationBannerPresenterIOSStyle.h"
#import "ContactPickerViewController.h"
#import "FriendRequestsViewController.h"
#import "ChatListViewController.h"

@interface HomeViewController ()<SWRevealViewControllerDelegate,UITabBarControllerDelegate,RadialMenuDelegate,CreateGamePopUpDelegate>{
    
    IBOutlet UIView *vwOverLay;
    IBOutlet UIImageView *imgNotifn;
    IBOutlet UIButton* btnSlideMenu;
    IBOutlet UITableView* tableView;
    IBOutlet UIButton *btnCreateGame;
    NSMutableArray *arrPeople;
    NSArray *arrRecentGame;
    NSMutableArray *arrGameRequests;
    UIRefreshControl *refreshController;
    NSInteger bgImgHeight;
    NSDictionary *userInfo;
    NSString *strAPIErrorMsg;
    CreateGameViewController *createGame;
  
}


@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpInitials];
    [self customSetup];
    [self loadDashBoard];
    

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)setUpInitials{
    
    [tableView setContentInset:UIEdgeInsetsMake(0,0,60,0)];
    tableView.hidden = true;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 500;
    refreshController = [[UIRefreshControl alloc] init];
    [refreshController addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshController];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate enablePushNotification];
    float width = 720;
    float height = 480;
    float ratio = width / height;
    bgImgHeight = (self.view.frame.size.width) / ratio;
   
    btnCreateGame.clipsToBounds = YES;
    btnCreateGame.layer.cornerRadius = 5.f;
    btnCreateGame.layer.borderWidth = 1.f;
    btnCreateGame.backgroundColor = [UIColor getThemeColor];
    btnCreateGame.layer.borderColor = [UIColor clearColor].CGColor;

    
    
}

-(void)setUpNavigationView{
    
    self.navigationController.navigationBarHidden = false;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Nav-Menu"] style:UIBarButtonItemStylePlain target:self action:@selector(revealSlider)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Notification"] style:UIBarButtonItemStylePlain target:self action:@selector(revealSlider)];
    self.navigationItem.title = @"Sports App";
    UIView *navBarLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.navigationController.navigationBar.frame),
                                                                      CGRectGetWidth(self.navigationController.navigationBar.frame), 1)];
    navBarLineView.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addSubview:navBarLineView];
}

-(void)updateNotificationIcon{
    
    imgNotifn.hidden = false;
}


-(void)handleRefresh{
    
    [self loadDashBoard];
}
-(void)loadDashBoard{
    
    [Utility hideLoadingScreenFromView:self.view];
    [Utility showLoadingScreenOnView:self.view withTitle:@"Loading"];
    [APIMapper getDashboardOnsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        if ([responseObject objectForKey:@"data"]) userInfo = [responseObject objectForKey:@"data"];
        [Utility hideLoadingScreenFromView:self.view];
        [self parseResponds:responseObject];
        [refreshController endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        userInfo = nil;
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        tableView.hidden = false;
        [Utility hideLoadingScreenFromView:self.view];
        [refreshController endRefreshing];
        [tableView reloadData];
    }];
}

-(void)parseResponds:(NSDictionary*)responds{
    
    if ([[responds objectForKey:@"data"] objectForKey:@"people"]) {
        arrPeople = [NSMutableArray arrayWithArray:[[responds objectForKey:@"data"] objectForKey:@"people"]];
    }
    if ([[responds objectForKey:@"data"] objectForKey:@"people"]) {
        arrRecentGame = [[responds objectForKey:@"data"] objectForKey:@"recent"];
    }
    arrRecentGame = nil;
    if ([[responds objectForKey:@"data"] objectForKey:@"game_request"]) {
        arrGameRequests = [NSMutableArray arrayWithArray:[[responds objectForKey:@"data"] objectForKey:@"game_request"]];
    }
    
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    if (userInfo) {
        return 3;
    }
    return 1;
    
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if (!userInfo) {
        return 1;
    }
    NSInteger rows = 0;
    switch (section) {
        case eSectionUserInfo:
            rows = 0;
            break;
        case eSectionPlayReq:
            rows = arrGameRequests.count;
            break;
        case eSectionPeople:
            rows = arrPeople.count;
            break;
            
        default:
            break;
    }
    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (!userInfo) {
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strAPIErrorMsg];
        return cell;
    }
    
    if (indexPath.section == eSectionPeople) {
        
        static NSString *CellIdentifier = @"PlayerListTableViewCell";
        PlayerListTableViewCell *cell = (PlayerListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row < arrPeople.count) {
            
            cell.btnAddFrnd.tag = indexPath.row;
            cell.btnCancel.tag = indexPath.row;
            cell.btnAcept.tag = indexPath.row;
            
            cell.btnCancelReq.tag = indexPath.row;
            cell.btnReject.tag = indexPath.row;
            
            cell.contrsintForCancelReq.priority = 998;
            cell.contrsintForCreateReq.priority = 998;
            cell.contrsintForConfirmation.priority = 998;
            cell.contrsintForEnd.priority = 998;
            cell.vwCancelReq.hidden = true;
            cell.vwCreatereq.hidden = true;
            cell.vwConfirmation.hidden = true;
            NSDictionary *people = arrPeople[indexPath.row];
            cell.lblName.text = [people objectForKey:@"name"];
            cell.lblLocation.text = [people objectForKey:@"location"];
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[people objectForKey:@"profileurl"]]
                            placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       
                                   }];
            
            NSInteger reqType = [[people objectForKey:@"friend_status"] integerValue];
            switch (reqType) {
                case eTypeCreateReq:
                    [self configureCreateReqWithCell:cell];
                    break;
                case eTypeRequested:
                    [self configureRequestedCell:cell];
                    break;
                case eTypeAccept:
                    [self configureConfirmCell:cell];
                    break;
                case eTypeFriends:
                    [self configureConfirmedCell:cell];
                    break;
                    
                default:
                    break;
            }
            
            
            
            
        }
        return cell;
    }
    if (indexPath.section == eSectionPlayReq) {
        
        static NSString *CellIdentifier = @"PlayerReqListCell";
        PlayerReqListCell *cell = (PlayerReqListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row < arrGameRequests.count) {
            [cell.indicator startAnimating];
            [cell closeExpandedMenu];
            NSDictionary *game = arrGameRequests[indexPath.row];
            cell.btnPlayVideo.tag = indexPath.row;
            cell.btnReply.tag = indexPath.row;
            cell.btnAcceptInvite.tag = indexPath.row;
            cell.btnRejectInvite.tag = indexPath.row;
            cell.btnProfile.tag = indexPath.row;
            cell.lblKey.text = [Utility getDateDescriptionForChat:[[game objectForKey:@"request_date"] doubleValue]] ;
            cell.lblName.text = [game objectForKey:@"name"];
            cell.lblLocation.text = [game objectForKey:@"location"];
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[game objectForKey:@"profileurl"]]
                              placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         
                                     }];
            [cell.imgThumb sd_setImageWithURL:[NSURL URLWithString:[game objectForKey:@"imageurl"]]
                            placeholderImage:[UIImage imageNamed:@"NoImage"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       
                                       [cell.indicator stopAnimating];
                                   }];
        }
        return cell;
    }
    
   return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == eSectionPeople) {
        if (indexPath.row < arrPeople.count) {
            NSDictionary *user = arrPeople[indexPath.row];
                [self showProfilePageWithID:[user objectForKey:@"user_id"]];
        }
    }
}

- (nullable UIView *)tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!userInfo) {
        return nil;
    }
    if (section == eSectionUserInfo) {
        NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"TableHeader" owner:self options:nil];
        TableHeader *header = [viewArray objectAtIndex:0];
        header.delegate = self;
        header.lblName.text = [userInfo objectForKey:@"name"];
        header.lblRegDate.text = [NSString stringWithFormat:@"Member since %@",[self getDayFromSeconds:[[userInfo objectForKey:@"reg_date"] doubleValue]]];
        header.imgHeight.constant = bgImgHeight;
        [header.imgUser sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        header.vwRecentRight.hidden = false;
        header.vwRecentLeft.hidden = false;
        header.vwRecentItems.hidden = (arrRecentGame <= 0) ? true : false;
        header.recentWidth.constant = arrRecentGame.count == 1 ? 110 : 240;
        header.lblRecentTitle.hidden = (arrRecentGame <= 0) ? true : false;
        header.vwRecentRight.hidden = (arrRecentGame.count == 1) ? true : false;
        
        for (int i = 0 ; i < arrRecentGame.count ; i ++) {
            NSDictionary *details = arrRecentGame[i];
            if (i == 0) {
                [header.imgPrviewLeft sd_setImageWithURL:[NSURL URLWithString:[details objectForKey:@"imageurl"]]
                                        placeholderImage:[UIImage imageNamed:@"NoImage"]
                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                   
                                               }];
                header.lblPrevwTitlelft.text = [details objectForKey:@"gameId"];
            }else{
                [header.imgPrviewRight sd_setImageWithURL:[NSURL URLWithString:[details objectForKey:@"imageurl"]]
                                        placeholderImage:[UIImage imageNamed:@"NoImage"]
                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                   
                                               }];
                header.lblPrevwTitleRight.text = [details objectForKey:@"gameId"];
            }
        }
        
        
        

        return header;
    }
    if (section == eSectionPlayReq) {
        if (arrGameRequests.count <= 0) {
            return nil;
        }
        NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"ReqListHeader" owner:self options:nil];
        ReqListHeader *header = [viewArray objectAtIndex:0];
        return header;
    }
    if (section == eSectionPeople) {
        if (arrPeople.count <= 0) {
            return nil;
        }
        NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"PeopleListHeader" owner:self options:nil];
        PeopleListHeader *header = [viewArray objectAtIndex:0];
        return header;
    }
    return nil;
   
    
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section{
    
    if (!userInfo) {
        return 0;
    }
    if (section == eSectionUserInfo) {
        if (arrRecentGame.count <= 0) {
            return bgImgHeight;
        }
        return bgImgHeight + 110;
    }
    if (section == eSectionPlayReq) {
        if (arrGameRequests.count <= 0) {
            return 0;
        }
        return 40;
    }
    if (section == eSectionPeople) {
        if (arrPeople.count <= 0) {
            return 0;
        }
        return 40;
    }
    return 0;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01;
}


#pragma mark - Slider View Setup and Delegates Methods

-(void)showSelectedCategoryDetailsFromMenuList:(NSInteger)index{
    
    NSInteger tag = index;
    switch (tag) {
            
        case eMenuCreateGame:
            [self createGame];
            break;
            
        case eMenuSharedVideo:
            [self showSharedVideos];
            break;
            
        case eMenuAllGames:
            [self listAllGames];
            break;
       
        case eMenuNotifications:
            [self showNotifications];
            break;
            
        case eMenuSettings:
            [self showSettings];
            break;
            
        case eMenuProfile:
            [self showProfilePageWithID:[User sharedManager].userId];
            break;
            
        case eMenuLogout:
            [self logoutUser];
            break;
            
            
        case eMenuConatct:
            [self showContactPicker];
            break;
            
        case eMenuChatList:
            [self showChatList];
            break;
            
            
        default:
            break;
    }

}

-(void)listAllGames{
    
     ListGamesViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForListGames];
    [[self navigationController]pushViewController:games animated:YES];
}
-(IBAction)createGame{
    
    [self createGamePopUp];
    return;
    CreateGameViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForCreateGame];
    [[self navigationController]pushViewController:games animated:YES];
    
}
-(void)showSharedVideos{
    
    SharedVideosViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForSharedVideos];
    [[self navigationController]pushViewController:games animated:YES];
}

-(IBAction)showSearchFriendsPage{
    
    SearchFriendsViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForSearchFriends];
    [[self navigationController]pushViewController:games animated:YES];
}

-(IBAction)showChatList{
    
    ChatListViewController *chatList =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForChatList];
    [[self navigationController]pushViewController:chatList animated:YES];
}


-(IBAction)showProfilePageWithID:(id)sender{
    NSString *userID;
    if ([sender isKindOfClass:[UIButton class]]) {
        userID = [User sharedManager].userId;
    }else{
        userID = (NSString*)sender;
    }
    
    ProfileViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GeneralStoryBoard Identifier:StoryBoardIdentifierForProfile];
    [[self navigationController]pushViewController:games animated:YES];
    games.strUserID = userID;
    
    
}

-(IBAction)showSettings{
    
    SettingsViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GeneralStoryBoard Identifier:StoryBoardIdentifierForSettings];
    [[self navigationController]pushViewController:games animated:YES];
}

-(IBAction)showNotifications{
    
    imgNotifn.hidden = true;
    NotificationsViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForNotifications];
    [[self navigationController]pushViewController:games animated:YES];
}


-(IBAction)showContactPicker{
    
    ContactPickerViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForContactPicker];
    [[self navigationController]pushViewController:games animated:YES];
}


-(void)logoutUser{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Confirm Logout"
                                  message:@"Logout from the App?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self clearUserSessions];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)clearUserSessions{
    
    [self showLoadingScreen];
    [APIMapper logoutFromAccount:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[GIDSignIn sharedInstance] signOut];
            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
            [loginManager logOut];
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if (defaults && [defaults objectForKey:@"USER"])
                [defaults removeObjectForKey:@"USER"];
            [defaults synchronize];
            [delegate checkUserStatus];
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.purposecodes.sportsapp"];
            [sharedDefaults setObject: nil forKey:@"TOKEN"];
            [sharedDefaults synchronize];
        });
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Logout"
                                      message:[error localizedDescription]
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        
        [alert addAction:ok];
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.window.rootViewController presentViewController:alert animated:YES completion:nil];
        [self hideLoadingScreen];
    }];
    
}

#pragma mark - Chat manage

-(void)refreshGameZoneWithInfo:(NSDictionary*)info{
    
    BOOL isGameOpen = false;
    for (UIViewController*vc in [self.navigationController viewControllers]) {
        if ([vc isKindOfClass: [GameZoneViewController class]]){
            isGameOpen = true;
            GameZoneViewController *gameZone = (GameZoneViewController*)vc;
            if ([gameZone.strGameID isEqualToString:[[info objectForKey:@"data"] objectForKey:@"id"]]) {
                [gameZone getGameZoneDetails];
                [gameZone showToastWithMessage:[[info objectForKey:@"aps"] objectForKey:@"alert"]];
            }
            
            break;
        }
    }
    if (!isGameOpen) {
        if ([[info objectForKey:@"data"] objectForKey:@"game_id"]) {
             [self goToGameZoneWithGameID:[[info objectForKey:@"data"] objectForKey:@"game_id"]];
        }
       
    }
   
}

-(void)manageGroupChatInfoFromForeGround:(NSDictionary*)_userInfo isBBg:(BOOL)isBG{
    GroupChatComposeViewController *oldChatVC;
    NSMutableArray *viewcontrollers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in viewcontrollers) {
        if ([vc isKindOfClass:[GroupChatComposeViewController class]]) {
            oldChatVC = (GroupChatComposeViewController*)vc;
        }
    }
    if (isBG) {
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[GroupChatComposeViewController class]]) {
            
            /*! If the user standing in the  chat page !*/
            GroupChatComposeViewController *chatView = (GroupChatComposeViewController*)[self.navigationController.viewControllers lastObject];
            if ([chatView.strGameID isEqualToString:[_userInfo objectForKey:@"game_id"]]) {
                
                /*! If chat notification comes with a same user !*/
                
                [chatView newChatHasReceivedWithDetails:_userInfo];
                
            }else{
                
                /*! If chat notification comes with a defefrent user !*/
                
                GroupChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForGroupChatComposer];
                chatCompose.strGameID = [_userInfo objectForKey:@"game_id"];
                chatCompose.strChatCount = [NSString stringWithFormat:@"%d",[[_userInfo objectForKey:@"member_count"] integerValue]];
                [self.navigationController pushViewController:chatCompose animated:YES];
                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                [allViewControllers removeObjectAtIndex:allViewControllers.count - 2];
                self.navigationController.viewControllers = allViewControllers;
                
            }
            
        }else
        {
            /*! All other pages !*/
            
            if (oldChatVC) {
                [viewcontrollers removeObjectIdenticalTo:oldChatVC];
                self.navigationController.viewControllers = viewcontrollers;
            }
            
            GroupChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForGroupChatComposer];
            chatCompose.strGameID = [_userInfo objectForKey:@"game_id"];
             chatCompose.strChatCount = [NSString stringWithFormat:@"%d",[[_userInfo objectForKey:@"member_count"] integerValue]];
            [self.navigationController pushViewController:chatCompose animated:YES];
            
            
        }
        
    }else{
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[GroupChatComposeViewController class]]) {
            
            /*! If the user standing in the  chat page !*/
            GroupChatComposeViewController *chatView = (GroupChatComposeViewController*)[self.navigationController.viewControllers lastObject];
            if ([chatView.strGameID isEqualToString:[_userInfo objectForKey:@"game_id"]]) {
                
                /*! If chat notification comes with a same user !*/
                
                [chatView newChatHasReceivedWithDetails:_userInfo];
                
            }else{
                
                /*! If chat notification comes with a defefrent user !*/
                
                
                NSString *appName = PROJECT_NAME;
                NSString *message = [NSString stringWithFormat:@"%@ : %@",[_userInfo objectForKey:@"name"],[_userInfo objectForKey:@"msg"]];
                [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
                [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        GroupChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForGroupChatComposer];
                        chatCompose.strGameID = [_userInfo objectForKey:@"game_id"];
                        chatCompose.strChatCount = [NSString stringWithFormat:@"%d",[[_userInfo objectForKey:@"member_count"] integerValue]];
                        [self.navigationController pushViewController:chatCompose animated:YES];
                        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                        [allViewControllers removeObjectAtIndex:allViewControllers.count - 2];
                        self.navigationController.viewControllers = allViewControllers;
                    });
                    
                }];
                
            }
            
        }else
        {
            /*! All other pages !*/
            
            NSString *appName = PROJECT_NAME;
            NSString *message = [NSString stringWithFormat:@"%@ : %@",[_userInfo objectForKey:@"name"],[_userInfo objectForKey:@"msg"]];
            [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
            [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    if (oldChatVC) {
                        [viewcontrollers removeObjectIdenticalTo:oldChatVC];
                        self.navigationController.viewControllers = viewcontrollers;
                    }
                    
                    GroupChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForGroupChatComposer];
                    
                    chatCompose.strGameID = [_userInfo objectForKey:@"game_id"];
                    chatCompose.strChatCount = [NSString stringWithFormat:@"%d",[[_userInfo objectForKey:@"member_count"] integerValue]];
                    [self.navigationController pushViewController:chatCompose animated:YES];
                });
                
            }];
            
            
            
        }
    }
   
    
}

-(void)managePrivateChatInfoFromForeGround:(NSDictionary*)_userInfo isBBg:(BOOL)isBG{
    
    PrivateChatComposeViewController *oldChatVC;
    NSMutableArray *viewcontrollers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in viewcontrollers) {
        if ([vc isKindOfClass:[PrivateChatComposeViewController class]]) {
            oldChatVC = (PrivateChatComposeViewController*)vc;
        }
    }
    
    if (isBG) {
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[PrivateChatComposeViewController class]]) {
            
            /*! If the user standing in the  chat page !*/
            PrivateChatComposeViewController *chatView = (PrivateChatComposeViewController*)[self.navigationController.viewControllers lastObject];
            if ([chatView.strUserID isEqualToString:[_userInfo objectForKey:@"user_id"]]) {
                
                /*! If chat notification comes with a same user !*/
                
                [chatView newChatHasReceivedWithDetails:_userInfo];
                
            }else{
                
                /*! If chat notification comes with a defefrent user !*/
                
                PrivateChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForPrivateChatComposer];
                chatCompose.strUserID = [_userInfo objectForKey:@"user_id"];
                chatCompose.strUserName = [_userInfo objectForKey:@"name"];
                [self.navigationController pushViewController:chatCompose animated:YES];
                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                [allViewControllers removeObjectAtIndex:allViewControllers.count - 2];
                self.navigationController.viewControllers = allViewControllers;
                
            }
            
        }else
        {
            /*! All other pages !*/
            
            if (oldChatVC) {
                [viewcontrollers removeObjectIdenticalTo:oldChatVC];
                self.navigationController.viewControllers = viewcontrollers;
            }
            
            PrivateChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForPrivateChatComposer];
            chatCompose.strUserID = [_userInfo objectForKey:@"user_id"];
            chatCompose.strUserName = [_userInfo objectForKey:@"name"];
            [self.navigationController pushViewController:chatCompose animated:YES];
            
            
        }
        
    }else{
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[PrivateChatComposeViewController class]]) {
            
            /*! If the user standing in the  chat page !*/
            PrivateChatComposeViewController *chatView = (PrivateChatComposeViewController*)[self.navigationController.viewControllers lastObject];
            if ([chatView.strUserID isEqualToString:[_userInfo objectForKey:@"user_id"]]) {
                
                /*! If chat notification comes with a same user !*/
                
                [chatView newChatHasReceivedWithDetails:_userInfo];
                
            }else{
                
                /*! If chat notification comes with a defefrent user !*/
                
                
                NSString *appName = PROJECT_NAME;
                NSString *message = [NSString stringWithFormat:@"%@ : %@",[_userInfo objectForKey:@"name"],[_userInfo objectForKey:@"msg"]];
                [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
                [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        PrivateChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForPrivateChatComposer];
                        chatCompose.strUserID = [_userInfo objectForKey:@"user_id"];
                        chatCompose.strUserName = [_userInfo objectForKey:@"name"];
                        [self.navigationController pushViewController:chatCompose animated:YES];
                        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                        [allViewControllers removeObjectAtIndex:allViewControllers.count - 2];
                        self.navigationController.viewControllers = allViewControllers;
                    });
                    
                }];
                
            }
            
        }else
        {
            /*! All other pages !*/
            
            NSString *appName = PROJECT_NAME;
            NSString *message = [NSString stringWithFormat:@"%@ : %@",[_userInfo objectForKey:@"name"],[_userInfo objectForKey:@"msg"]];
            [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
            [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    if (oldChatVC) {
                        [viewcontrollers removeObjectIdenticalTo:oldChatVC];
                        self.navigationController.viewControllers = viewcontrollers;
                    }
                    
                    PrivateChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForPrivateChatComposer];
                    chatCompose.strUserName = [_userInfo objectForKey:@"name"];
                    chatCompose.strUserID = [_userInfo objectForKey:@"user_id"];
                    [self.navigationController pushViewController:chatCompose animated:YES];
                });
                
            }];
            
            
            
        }
    }
    
    
}

-(void)manageOtherNotificationsWith:(NSDictionary*)_userInfo isBBg:(BOOL)isBG{
    
    UIViewController *vc = [self.navigationController.viewControllers lastObject];
    NSString *message = [NSString stringWithFormat:@"%@",[[_userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
    [ALToastView toastInView:vc.view withText:message];
    [self handleRefresh];
    
    if (isBG) {
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[HomeViewController class]]) {
            
            
        }else
        {
            /*! All other pages !*/
           
            [self.navigationController popToRootViewControllerAnimated:YES];
           
        }
        
    }else{
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[HomeViewController class]]) {
            
           
            
        }else
        {
            /*! All other pages !*/
            
            NSString *appName = PROJECT_NAME;
            NSString *message = [NSString stringWithFormat:@"%@",[[_userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
            [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
            [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
                
            }];
            
        }
    }

    
}

-(void)manageFriendReqNotificatinWith:(NSDictionary*)_userInfo isBBg:(BOOL)isBG{
    
    UIViewController *vc = [self.navigationController.viewControllers lastObject];
    NSString *message = [NSString stringWithFormat:@"%@",[[_userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
    [ALToastView toastInView:vc.view withText:message];
    
    if (isBG) {
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[FriendRequestsViewController class]]) {
            FriendRequestsViewController *friendList = (FriendRequestsViewController*) [self.navigationController.viewControllers lastObject];
            [friendList refreshPage];
            
        }else
        {
            /*! All other pages !*/
            FriendRequestsViewController *friendList =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForFriendRequest];
            [self.navigationController pushViewController:friendList animated:YES];
            
            
        }
        
    }else{
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[FriendRequestsViewController class]]) {
            
            FriendRequestsViewController *friendList = (FriendRequestsViewController*) [self.navigationController.viewControllers lastObject];
            [friendList refreshPage];
            
        }else
        {
            /*! All other pages !*/
            
            NSString *appName = PROJECT_NAME;
            NSString *message = [NSString stringWithFormat:@"%@",[[_userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
            [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
            [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    FriendRequestsViewController *friendList =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForFriendRequest];
                    [self.navigationController pushViewController:friendList animated:YES];
                });
                
            }];
            
        }
    }

}

#pragma mark - Configure Cell

-(void)configureCreateReqWithCell:(PlayerListTableViewCell*)cell{
    
    cell.contrsintForCreateReq.priority = 999;
    cell.vwCreatereq.hidden = false;
    
}
-(void)configureRequestedCell:(PlayerListTableViewCell*)cell{
    
    cell.contrsintForCancelReq.priority = 999;
    cell.vwCancelReq.hidden = false;
}
-(void)configureConfirmCell:(PlayerListTableViewCell*)cell{
    
    cell.contrsintForConfirmation.priority = 999;
    cell.vwConfirmation.hidden = false;
}
-(void)configureConfirmedCell:(PlayerListTableViewCell*)cell{
    
    cell.contrsintForEnd.priority = 999;
    
}

#pragma mark - Radial Menu Methods

-(void)radialMenuClickedWithIndex:(NSInteger)index{
    
    [self showSelectedCategoryDetailsFromMenuList:index];
}


#pragma mark - IBActions

-(IBAction)replyToAGameReq:(UIButton*)sender{
    
    if (sender.tag < arrGameRequests.count) {
        NSDictionary *details = arrGameRequests[sender.tag];
        UIAlertController* alertController = [UIAlertController
                                              alertControllerWithTitle:@"GAME REQUEST"
                                              message:@"Join game"
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* item1 = [UIAlertAction actionWithTitle:@"Join now"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [alertController dismissViewControllerAnimated:YES completion:nil];
                                                         [self replyToAGameReqWithStatus:@"Join now" andReqID:[details objectForKey:@"request_id"] atIndex:sender.tag];
                                                     }];
        UIAlertAction* item2 = [UIAlertAction actionWithTitle:@"I can play in 15 min"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                        [self replyToAGameReqWithStatus:@"I can play in 15 min" andReqID:[details objectForKey:@"request_id"] atIndex:sender.tag];
                                                        [alertController dismissViewControllerAnimated:YES completion:nil];
                                                     }];
        UIAlertAction* item3 = [UIAlertAction actionWithTitle:@"I can play in 30 min"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                        [self replyToAGameReqWithStatus:@"I can play in 30 min" andReqID:[details objectForKey:@"request_id"] atIndex:sender.tag];
                                                        [alertController dismissViewControllerAnimated:YES completion:nil];
                                                      }];
        UIAlertAction* item4 = [UIAlertAction actionWithTitle:@"Sorry,I'll let you know when i can play later"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self replyToAGameReqWithStatus:@"Sorry,I'll let you know when i can play later" andReqID:[details objectForKey:@"request_id"] atIndex:sender.tag];
                                                          [alertController dismissViewControllerAnimated:YES completion:nil];
                                                      }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:item1];
        [alertController addAction:item2];
        [alertController addAction:item3];
        [alertController addAction:item4];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    
    }
}


-(IBAction)playRequestedVideos:(UIButton*)sender{
    
    NSURL *videoURL;
    if (sender.tag < arrGameRequests.count) {
        NSDictionary *details = arrGameRequests[sender.tag];
        videoURL = [NSURL URLWithString:[details objectForKey:@"videourl"]];
        if (videoURL) {
            AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
            playerViewController.player = [AVPlayer playerWithURL:videoURL];
            [playerViewController.player play];
            [self presentViewController:playerViewController animated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(videoDidFinish:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[playerViewController.player currentItem]];
        }
        
    }
    
}


-(IBAction)playRecentplyAddedVideo:(UIButton*)sender{

    if (sender.tag < arrRecentGame.count) {
        PlayedGameDetailPageViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForPlayedGameDetail];
        NSDictionary *details = arrRecentGame[sender.tag];
        games.strGameID = [details objectForKey:@"id"];
        
        [[self navigationController]pushViewController:games animated:YES];
    }
    
}

- (void)videoDidFinish:(id)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //fade out / remove subview
}



-(IBAction)addFriend:(UIButton*)sender{
    
    if (sender.tag < arrPeople.count) {
        NSDictionary *people = arrPeople[sender.tag];
        [Utility showLoadingScreenOnView:self.view withTitle:@"Requesting.."];
        [APIMapper addFriendWithFriendID:[people objectForKey:@"user_id"] OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [Utility hideLoadingScreenFromView:self.view];
            if ([[responseObject objectForKey:@"data"] objectForKey:@"request_id"]) {
                
                NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:people];
                [dictUpdated setObject:[[responseObject objectForKey:@"data"] objectForKey:@"request_id"] forKey:@"request_id"];
                [dictUpdated setObject:[NSNumber numberWithInteger:1] forKey:@"friend_status"];
                [arrPeople replaceObjectAtIndex:sender.tag withObject:dictUpdated];
                [tableView reloadData];
            }
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            [Utility hideLoadingScreenFromView:self.view];
            
        }];
        
    }
    
}

-(IBAction)cancelAlreadyGivenReq:(UIButton*)sender{
    
    if (sender.tag < arrPeople.count) {
        NSDictionary *people = arrPeople[sender.tag];
        [Utility showLoadingScreenOnView:self.view withTitle:@"Cancelling.."];
        [APIMapper updateFriendRequestWithReqID:[people objectForKey:@"request_id"] status:0 OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [Utility hideLoadingScreenFromView:self.view];
            NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:people];
            [dictUpdated setObject:[NSNumber numberWithInteger:0] forKey:@"friend_status"];
            [arrPeople replaceObjectAtIndex:sender.tag withObject:dictUpdated];
            [tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            [Utility hideLoadingScreenFromView:self.view];
        }];
        
    }
}

-(IBAction)acceptReq:(UIButton*)sender{
    
    if (sender.tag < arrPeople.count) {
        NSDictionary *people = arrPeople[sender.tag];
        [Utility showLoadingScreenOnView:self.view withTitle:@"Accepting.."];
        [APIMapper updateFriendRequestWithReqID:[people objectForKey:@"request_id"] status:1 OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [Utility hideLoadingScreenFromView:self.view];
            NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:people];
            [dictUpdated setObject:[NSNumber numberWithInteger:3] forKey:@"friend_status"];
            [arrPeople replaceObjectAtIndex:sender.tag withObject:dictUpdated];
            [tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            [Utility hideLoadingScreenFromView:self.view];
        }];
        
    }
    
}

-(IBAction)rejectRequest:(UIButton*)sender{
    
    if (sender.tag < arrPeople.count) {
        NSDictionary *people = arrPeople[sender.tag];
        [Utility showLoadingScreenOnView:self.view withTitle:@"Rejecting.."];
        [APIMapper updateFriendRequestWithReqID:[people objectForKey:@"request_id"] status:0 OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [Utility hideLoadingScreenFromView:self.view];
            NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:people];
            [dictUpdated setObject:[NSNumber numberWithInteger:0] forKey:@"friend_status"];
            [arrPeople replaceObjectAtIndex:sender.tag withObject:dictUpdated];
            [tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            [Utility hideLoadingScreenFromView:self.view];
        }];
        
    }
    
}

#pragma mark - Create Game PopUp

-(IBAction)createGamePopUp{
    
    if (!createGame) {
        
        createGame =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForCreateGame];
         createGame.delegate = self;
        UIView *popup = createGame.view;
        [self.view addSubview:popup];
        popup.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[popup]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(popup)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[popup]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(popup)]];
        popup.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            popup.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
    }
    
    [self.view endEditing:YES];
    
    
}

-(void)closeCreateGamePopUp{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        createGame.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [createGame.view removeFromSuperview];
        createGame = nil;
    }];
}


#pragma mark - Generic Methods

-(void)replyToAGameReqWithStatus:(NSString*)statusMsg andReqID:(NSString*)reqId atIndex:(NSInteger)index{
    
    [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    
    [APIMapper replyToGameRequestWithMessage:statusMsg requestID:reqId Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Utility hideLoadingScreenFromView:self.view];
        [arrGameRequests removeObjectAtIndex:index];
        [tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [Utility hideLoadingScreenFromView:self.view];
        NSString *title = @"ERROR";
        NSString *errormsg = error.localizedDescription;
        if (task.responseData) {
            if ([task.response statusCode] == kLimitReached) {
                title = @"LIMIT REACHED";
                [arrGameRequests removeObjectAtIndex:index];
                [tableView reloadData];
            }
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:task.responseData
                                                                 options:kNilOptions
                                                                   error:&error];
            if (NULL_TO_NIL([json objectForKey:@"text"])) errormsg = [json objectForKey:@"text"];
            
            
        }
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:title
                                      message:errormsg
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[NotificationsViewController class]]) {
        
        imgNotifn.hidden = true;
    }
    
}

-(IBAction)showUserProfileWithIndex:(UIButton*)sender{
    if (sender.tag < arrGameRequests.count) {
        NSDictionary *user = arrGameRequests[sender.tag];
        ProfileViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GeneralStoryBoard Identifier:StoryBoardIdentifierForProfile];
        [[self navigationController]pushViewController:games animated:YES];
        games.strUserID = [user objectForKey:@"user_id"];
    }
}



-(void)goToGameZoneWithGameID:(NSString*)gameID{
    
    GameZoneViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForPlayedGameZone];
    games.strGameID = gameID;
    [[self navigationController]pushViewController:games animated:YES];
}

-(void)displayErrorMessgeWithDetails:(NSData*)responseData{
    if (responseData.length) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                               error:&error];
        if (NULL_TO_NIL([json objectForKey:@"text"]))
            strAPIErrorMsg = [json objectForKey:@"text"];
        
        [tableView reloadData];
        
    }
    
}


- (void)customSetup
{
    
    SWRevealViewController *revealViewController = self.revealViewController;
    revealViewController.delegate = self;
    if ( revealViewController )
    {
        [btnSlideMenu addTarget:self.revealViewController action:@selector(revealToggle:)forControlEvents:UIControlEventTouchUpInside];
        [vwOverLay addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}

-(IBAction)revealSlider{
    
    [self.revealViewController revealToggle:nil];
}

- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position{
    
    UIViewController *vc = (MenuViewController*)revealController.rearViewController;
    if ([vc isKindOfClass:[MenuViewController class]]) {
        MenuViewController *menu = (MenuViewController*)vc;
        [menu reloadUserData];
    }
    if (position == FrontViewPositionRight) {
        [self setVisibilityForOverLayIsHide:NO];
    }else{
        [self setVisibilityForOverLayIsHide:YES];
    }
    
}
-(IBAction)hideSlider:(id)sender{
    [self.revealViewController revealToggle:nil];
}

-(void)setVisibilityForOverLayIsHide:(BOOL)isHide{
    
    [self.view bringSubviewToFront:vwOverLay];
    if (isHide) {
        [UIView transitionWithView:vwOverLay
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            vwOverLay.alpha = 0.0;
                        }
                        completion:^(BOOL finished) {
                            
                            vwOverLay.hidden = true;
                        }];
        
        
    }else{
        
        vwOverLay.hidden = false;
        [UIView transitionWithView:vwOverLay
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            vwOverLay.alpha = 0.7;
                        }
                        completion:^(BOOL finished) {
                            
                        }];
        
    }
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


#pragma mark state preservation / restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Save what you need here
    
    [super encodeRestorableStateWithCoder:coder];
}


- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Restore what you need here
    
    [super decodeRestorableStateWithCoder:coder];
}


- (void)applicationFinishedRestoringState
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Call whatever function you need to visually restore
    [self customSetup];
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


@end
