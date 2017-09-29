
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
#import "SharedVideoCell.h"
#import "CommentComposeViewController.h"
#import "CommunityGalleryViewController.h"
#import "FriendRequestManager.h"
#import "GameRequestViewController.h"
#import "NotificationsViewController.h"

@interface HomeViewController ()<SWRevealViewControllerDelegate,UITabBarControllerDelegate,RadialMenuDelegate,CreateGamePopUpDelegate,EMEmojiableBtnDelegate,CommentPopUpDelegate,CommunityGalleryPopUpDelegate>{
    
    IBOutlet UIView* vwPagination;
    IBOutlet UIView *vwOverLay;
    IBOutlet UIImageView *imgNotifn;
    IBOutlet UIButton* btnSlideMenu;
    IBOutlet UITableView* tableView;
    IBOutlet UIButton *btnCreateGame;
    NSMutableArray *arrCommunity;
    UIRefreshControl *refreshController;
    NSInteger bgImgHeight;
    NSString *strAPIErrorMsg;
    CreateGameViewController *createGame;
    
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    CommentComposeViewController *comments;
    CommunityGalleryViewController *galleryView;
  
}


@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpInitials];
    [self customSetup];
    [self loadDashBoardWithPageNumber:currentPage isPagination:NO];
    

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)setUpInitials{
    
    arrDataSource = [NSMutableArray new];
    currentPage = 1;
    tableView.hidden = true;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 700;
    refreshController = [[UIRefreshControl alloc] init];
    [refreshController addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshController];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate enablePushNotification];
    float width = 720;
    float height = 256;
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
    
    [arrDataSource removeAllObjects];
    currentPage = 1;
    [self loadDashBoardWithPageNumber:currentPage isPagination:NO];
}
-(void)loadDashBoardWithPageNumber:(NSInteger)pageNumber isPagination:(BOOL)isPagination{
    
    [Utility hideLoadingScreenFromView:self.view];
    if (!isPagination) [Utility showLoadingScreenOnView:self.view withTitle:@"Loading"];
    
    [APIMapper getAllSharedVideosWithPageNumber:pageNumber OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        isPageRefresing = false;
        tableView.hidden = false;
        [Utility hideLoadingScreenFromView:self.view];
        [self parseResponds:responseObject];
        [refreshController endRefreshing];
        [UIView animateWithDuration:1.0 animations:^(void) {
            vwPagination.alpha = 0;
        }];

        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        isPageRefresing = false;
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        tableView.hidden = false;
        [Utility hideLoadingScreenFromView:self.view];
        [refreshController endRefreshing];
        [tableView reloadData];
        [UIView animateWithDuration:1.0 animations:^(void) {
            vwPagination.alpha = 0;
        }];
        
    }];
}

-(void)parseResponds:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"community"]))
        [arrDataSource addObjectsFromArray:[[responds objectForKey:@"data"] objectForKey:@"community"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
    [tableView reloadData];
    
    
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    if (!isDataAvailable) {
        return 1;
    }
    return 2;
    
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (!isDataAvailable) {
        rows = 1;
    }
    if (section == 1) {
        rows = arrDataSource.count;
    }
    
    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (!isDataAvailable) {
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strAPIErrorMsg];
        return cell;
    }
    
    if (indexPath.row < arrDataSource.count) {
        NSDictionary *details = arrDataSource[indexPath.row];
        NSString *msg;
        NSString *CellIdentifier = @"SharedVideoCell";
        if (NULL_TO_NIL( [details objectForKey:@"share_msg"]))msg = [details objectForKey:@"share_msg"];
        if (!msg.length) CellIdentifier = @"SharedVideoCellWithNoText";
        SharedVideoCell *cell = (SharedVideoCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell.btnComment.tag = indexPath.row;
        cell.btnVideo.tag = indexPath.row;
        cell.btnDelete.tag = indexPath.row;
        cell.btnDelete.hidden = true;
        cell.btnProfile.tag = indexPath.row;
        cell.btnShare.tag = indexPath.row;
        cell.btnMoreGallery.tag = indexPath.row;
        cell.btnVideo.hidden = true;
        [cell.indicator stopAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
        cell.lblName.text = [details objectForKey:@"name"];
        cell.lblLoc.text = @"";
        cell.lblFriends.text = @"";
        
        if (NULL_TO_NIL([details objectForKey:@"location"]) ){
            NSMutableAttributedString *myString = [NSMutableAttributedString new];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            UIImage *icon = [UIImage imageNamed:@"Location_Thin"];
            attachment.image = icon;
            attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblLoc.font.descender + 2), icon.size.width, icon.size.height);
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            [myString appendAttributedString:attachmentString];
            NSAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[details objectForKey:@"location"]];
            [myString appendAttributedString:myText];
            cell.lblLoc.attributedText = myString;
            
        }
        
        if (NULL_TO_NIL([details objectForKey:@"tagged_users"]) ){
            
            NSString *conatcts = [details objectForKey:@"tagged_users"];
            if (conatcts.length) {
                NSMutableAttributedString *myString = [NSMutableAttributedString new];
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                UIImage *icon = [UIImage imageNamed:@"Contact_Thin"];
                attachment.image = icon;
                attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblFriends.font.descender + 2), icon.size.width, icon.size.height);
                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
                [myString appendAttributedString:attachmentString];
                NSAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[details objectForKey:@"tagged_users"]]];
                [myString appendAttributedString:myText];
                cell.lblFriends.attributedText = myString;
            }
            
        }
        cell.trailingToChat.priority = 998;
        cell.trailingToSuperView.priority = 999;
        if ([[details objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId]){
            cell.btnDelete.hidden = false;
            cell.trailingToChat.priority = 999;
            cell.trailingToSuperView.priority = 998;
        }
        
        [cell.lblCommenCount setText:[NSString stringWithFormat:@"%d Comments",[[details objectForKey:@"comment_total"] integerValue]]];
        cell.lblTime.text = [Utility getDateDescriptionForChat:[[details objectForKey:@"shared_datetime"] doubleValue]];
        
        cell.lblDescription.text = @"";
        
        if (msg.length) {
            cell.lblDescription.text = [details objectForKey:@"share_msg"];
            cell.imageTopToProfile.priority = 998;
            cell.imageTopToDescBottom.priority = 999;
            cell.vwDescHolder.hidden = false;
        }else{
            cell.vwDescHolder.hidden = true;
            cell.imageTopToProfile.priority = 999;
            cell.imageTopToDescBottom.priority = 998;
        }
        
        cell.lblMediaCount.text = @"";
        cell.imgMore.hidden = true;
        if ([details objectForKey:@"media"]) {
            NSArray *media = [details objectForKey:@"media"];
            if (media.count > 1) {
                cell.imgMore.hidden = false;
                cell.lblMediaCount.text = [NSString stringWithFormat:@"%u+",media.count - 1];
            }
            
        }
        cell.topForImage.constant = 0;
        cell.constraintForHeight.constant = 0;
        cell.imgThumb.hidden = true;
        if (NULL_TO_NIL([details objectForKey:@"display_image"])) {
            cell.imgThumb.hidden = false;
            cell.btnVideo.hidden = false;
            cell.topForImage.constant = 10;
            if ([[details objectForKey:@"display_type"] isEqualToString:@"image"]) {
                cell.btnVideo.hidden = true;
            }
            [cell.indicator startAnimating];
            float width = [[details objectForKey:@"image_width"] integerValue];
            float height = [[details objectForKey:@"image_height"] integerValue];;
            float ratio = width / height;
            float imageHeight = (self.view.frame.size.width) / ratio;
            cell.constraintForHeight.constant = 200;
            [cell.imgThumb sd_setImageWithURL:[NSURL URLWithString:[details objectForKey:@"display_image"]]
                             placeholderImage:[UIImage imageNamed:@"NoImage"]
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                        [cell.indicator stopAnimating];
                                    }];
        }
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[details objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        
        cell.btnEmoji.delegate = self;
        cell.btnEmoji.dataset = @[
                                  [[EMEmojiableOption alloc] initWithImage:@"Like_Blue" withName:@" Like"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Haha" withName:@" Haha"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Wow" withName:@" Wow"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Sad" withName:@" Sad"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Angry" withName:@" Angry"],
                                  ];
        [cell.btnDisplayEmoji setImage:[UIImage imageNamed:@"Like_Inactive"] forState:UIControlStateNormal];
        [cell.btnDisplayEmoji setTitle:[NSString stringWithFormat:@" %d",[[details objectForKey:@"like_total"] integerValue]]forState:UIControlStateNormal];
        if ([[details objectForKey:@"emoji_code"] integerValue] >= 0) {
            EMEmojiableOption *option = [cell.btnEmoji.dataset objectAtIndex:[[details objectForKey:@"emoji_code"] integerValue]];
            [cell.btnDisplayEmoji setImage: [UIImage imageNamed:option.imageName] forState:UIControlStateNormal];
        }
        cell.btnEmoji.vwBtnSuperView = self.view;
        cell.btnEmoji.tag = indexPath.row;
        [cell.btnEmoji privateInit];
        
        return cell;
    }
    
    return cell;
    
    
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (nullable UIView *)tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section{
    
   
    if (section == 0) {
        
        NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"TableHeader" owner:self options:nil];
        TableHeader *header = [viewArray objectAtIndex:0];
        header.delegate = self;
        header.lblName.text = [[User sharedManager] name];
        header.lblRegDate.text = [NSString stringWithFormat:@"Member since %@",[[User sharedManager] regDate]];
        header.imgHeight.constant = bgImgHeight;
        [header.imgUser sd_setImageWithURL:[NSURL URLWithString:[User sharedManager].profileurl]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        return header;
    }
    return nil;
   
    
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return bgImgHeight;
    }
    return 0;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == arrDataSource.count - 1) {
        [self loadPagination];
    }
}

-(void)loadPagination{
    
    if (isDataAvailable) {
        if(isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
            
            NSInteger nextPage = currentPage ;
            nextPage += 1;
            if (nextPage  <= totalPages) {
                isPageRefresing = YES;
                [UIView animateWithDuration:1.0 animations:^(void) {
                    vwPagination.alpha = 1;
                }];
                [self loadDashBoardWithPageNumber:nextPage isPagination:YES];
            }
        }
    }
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

-(IBAction)listAllGames{
    
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

-(IBAction)showFriendManagerView{
    
    FriendRequestManager *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForFriendRequestsManager];
    [[self navigationController]pushViewController:games animated:YES];
    
    /*
     ContactPickerViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForContactPicker];
     [[self navigationController]pushViewController:games animated:YES];*/
    
    
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

-(void)refreshGameZoneWithInfo:(NSDictionary*)info isBBg:(BOOL)isBG;{
    
    GameZoneViewController *gameZone;
    NSMutableArray *viewcontrollers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in viewcontrollers) {
        if ([vc isKindOfClass:[GameZoneViewController class]]) {
            gameZone = (GameZoneViewController*)vc;
        }
    }
    if (isBG) {
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[GameZoneViewController class]]) {
            
            /*! If the user standing in the  chat page !*/
            GameZoneViewController *_gameZone = (GameZoneViewController*)[self.navigationController.viewControllers lastObject];
            
            if ([_gameZone.strGameID isEqualToString:[[info objectForKey:@"data"] objectForKey:@"game_id"]]) {
                [_gameZone getGameZoneDetails];
                [_gameZone showToastWithMessage:[[info objectForKey:@"aps"] objectForKey:@"alert"]];
            }
            else{
                
                /*! If chat notification comes with a defefrent user !*/
                
                if ([[info objectForKey:@"data"] objectForKey:@"game_id"]) {
                    if (gameZone) {
                        [viewcontrollers removeObjectIdenticalTo:gameZone];
                        self.navigationController.viewControllers = viewcontrollers;
                    }
                    [self goToGameZoneWithGameID:[[info objectForKey:@"data"] objectForKey:@"game_id"]];
                }
                
            }
            
        }else
        {
            /*! All other pages !*/
            
            if (gameZone) {
                [viewcontrollers removeObjectIdenticalTo:gameZone];
                self.navigationController.viewControllers = viewcontrollers;
            }
            
            if ([[info objectForKey:@"data"] objectForKey:@"game_id"]) {
                [self goToGameZoneWithGameID:[[info objectForKey:@"data"] objectForKey:@"game_id"]];
            }
            
            
        }
        
    }else{
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[GameZoneViewController class]]) {
            
            /*! If the user standing in the  chat page !*/
            GameZoneViewController *_gameZone = (GameZoneViewController*)[self.navigationController.viewControllers lastObject];
            if ([_gameZone.strGameID isEqualToString:[[info objectForKey:@"data"] objectForKey:@"game_id"]]) {
                [_gameZone getGameZoneDetails];
                [_gameZone showToastWithMessage:[[info objectForKey:@"aps"] objectForKey:@"alert"]];
            }else{
                
                /*! If chat notification comes with a defefrent user !*/
                
                
                NSString *appName = PROJECT_NAME;
                NSString *message = [NSString stringWithFormat:@"%@",[[info objectForKey:@"aps"] objectForKey:@"alert"]];
                [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
                [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                    
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        if (gameZone) {
                            [viewcontrollers removeObjectIdenticalTo:gameZone];
                            self.navigationController.viewControllers = viewcontrollers;
                        }
                        [self goToGameZoneWithGameID:[[info objectForKey:@"data"] objectForKey:@"game_id"]];
                    });
                    
                }];
                
            }
            
        }else
        {
            /*! All other pages !*/
            
            NSString *appName = PROJECT_NAME;
            NSString *message = [NSString stringWithFormat:@"%@",[[info objectForKey:@"aps"] objectForKey:@"alert"]];
            [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
            [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    if (gameZone) {
                        [viewcontrollers removeObjectIdenticalTo:gameZone];
                        self.navigationController.viewControllers = viewcontrollers;
                    }
                    
                    [self goToGameZoneWithGameID:[[info objectForKey:@"data"] objectForKey:@"game_id"]];
                });
                
            }];
            
            
            
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
    
    
    FriendRequestManager *gameRequests;
    NSMutableArray *viewcontrollers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in viewcontrollers) {
        if ([vc isKindOfClass:[FriendRequestManager class]]) {
            gameRequests = (FriendRequestManager*)vc;
        }
    }
    
    UIViewController *vc = [self.navigationController.viewControllers lastObject];
    NSString *message = [NSString stringWithFormat:@"%@",[[_userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
    [ALToastView toastInView:vc.view withText:message];
    
    if (isBG) {
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[FriendRequestManager class]]) {
            FriendRequestManager *friendList = (FriendRequestManager*) [self.navigationController.viewControllers lastObject];
            [friendList enableFriendRequestTabFromNotifications];
            
        }else
        {
            if (gameRequests) {
                [viewcontrollers removeObjectIdenticalTo:gameRequests];
                self.navigationController.viewControllers = viewcontrollers;
            }
            
            /*! All other pages !*/
            FriendRequestManager *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForFriendRequestsManager];
            [self.navigationController pushViewController:games animated:YES];
            
            
        }
        
    }else{
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[FriendRequestsViewController class]]) {
            
            FriendRequestManager *friendList = (FriendRequestManager*) [self.navigationController.viewControllers lastObject];
            [friendList enableFriendRequestTabFromNotifications];
            
        }else
        {
            /*! All other pages !*/
            
            NSString *appName = PROJECT_NAME;
            NSString *message = [NSString stringWithFormat:@"%@",[[_userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
            [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
            [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    if (gameRequests) {
                        [viewcontrollers removeObjectIdenticalTo:gameRequests];
                        self.navigationController.viewControllers = viewcontrollers;
                    }
                    
                    /*! All other pages !*/
                    FriendRequestManager *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForFriendRequestsManager];
                    [self.navigationController pushViewController:games animated:YES];
                });
                
            }];
            
        }
    }

}

-(void)manageGameRequestWith:(NSDictionary*)_userInfo isBBg:(BOOL)isBG{
    
    GameRequestViewController *gameRequests;
    NSMutableArray *viewcontrollers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in viewcontrollers) {
        if ([vc isKindOfClass:[GameRequestViewController class]]) {
            gameRequests = (GameRequestViewController*)vc;
        }
    }
    
    if (isBG) {
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[GameRequestViewController class]]) {
            
            /*! If the user standing in the  chat page !*/
            GameRequestViewController *gameRequset = (GameRequestViewController*)[self.navigationController.viewControllers lastObject];
            [gameRequset handleRefresh];
                        
        }else
        {
            /*! All other pages !*/
            
            if (gameRequests) {
                [viewcontrollers removeObjectIdenticalTo:gameRequests];
                self.navigationController.viewControllers = viewcontrollers;
            }
            GameRequestViewController *gameRequset =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForGameRequest];
            [self.navigationController pushViewController:gameRequset animated:YES];
            
            
        }
        
    }else{
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[GameRequestViewController class]]) {
            
            /*! If the user standing in the  chat page !*/
            GameRequestViewController *gameRequset = (GameRequestViewController*)[self.navigationController.viewControllers lastObject];
            [gameRequset handleRefresh];
            
        }else
        {
            /*! All other pages !*/
            
            NSString *appName = PROJECT_NAME;
            NSString *message = [NSString stringWithFormat:@"%@",[[_userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
            [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
            [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    if (gameRequests) {
                        [viewcontrollers removeObjectIdenticalTo:gameRequests];
                        self.navigationController.viewControllers = viewcontrollers;
                    }
                    
                    GameRequestViewController *gameRequset =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForGameRequest];
                    [self.navigationController pushViewController:gameRequset animated:YES];
                });
                
            }];
            
            
            
        }
    }
    
    
}

-(void)manageGameReplyByAdminWith:(NSDictionary*)_userInfo isBBg:(BOOL)isBG{
    
    NotificationsViewController *gameRequests;
    NSMutableArray *viewcontrollers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in viewcontrollers) {
        if ([vc isKindOfClass:[NotificationsViewController class]]) {
            gameRequests = (NotificationsViewController*)vc;
        }
    }
    
    if (isBG) {
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[NotificationsViewController class]]) {
            
            /*! If the user standing in the  chat page !*/
            NotificationsViewController *gameRequset = (NotificationsViewController*)[self.navigationController.viewControllers lastObject];
            [gameRequset enableGameRequestTabByNotification];
            
        }else
        {
            /*! All other pages !*/
            
            if (gameRequests) {
                [viewcontrollers removeObjectIdenticalTo:gameRequests];
                self.navigationController.viewControllers = viewcontrollers;
            }
            
            NotificationsViewController *gameRequset =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForNotifications];
            gameRequset.menuType = eTypeGameReq;
            [self.navigationController pushViewController:gameRequset animated:YES];
            
        }
        
    }else{
        
        if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[NotificationsViewController class]]) {
            
            /*! If the user standing in the  chat page !*/
            NotificationsViewController *gameRequset = (NotificationsViewController*)[self.navigationController.viewControllers lastObject];
            [gameRequset enableGameRequestTabByNotification];
            
        }else
        {
            /*! All other pages !*/
            
            NSString *appName = PROJECT_NAME;
            NSString *message = [NSString stringWithFormat:@"%@",[[_userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
            [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
            [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    if (gameRequests) {
                        [viewcontrollers removeObjectIdenticalTo:gameRequests];
                        self.navigationController.viewControllers = viewcontrollers;
                    }
                    
                    NotificationsViewController *gameRequset =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForNotifications];
                    gameRequset.menuType = eTypeGameReq;
                    [self.navigationController pushViewController:gameRequset animated:YES];
                    
                });
                
            }];
            
            
            
        }
    }
    
    
}


#pragma mark - IBActions

-(IBAction)showAllGameRequestsPage{
    
    GameRequestViewController *friendList =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForGameRequest];
    [self.navigationController pushViewController:friendList animated:YES];
}


-(IBAction)deleteSharedVideo:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        
        NSDictionary *details = arrDataSource[sender.tag];

        UIAlertController* alertController = [UIAlertController
                                              alertControllerWithTitle:@"DELETE"
                                              message:@"Really want to delete shared post?"
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* item1 = [UIAlertAction actionWithTitle:@"Delete"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [alertController dismissViewControllerAnimated:YES completion:nil];
                                                          if ([details objectForKey:@"community_id"]) {
                                                              [Utility showLoadingScreenOnView:self.view withTitle:@"Deleting.."];
                                                              [APIMapper deleteSharedVideoWithVideoID:[details objectForKey:@"community_id"] OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                  
                                                                  [arrDataSource removeObjectAtIndex:sender.tag];
                                                                  [tableView reloadData];
                                                                  [Utility hideLoadingScreenFromView:self.view];
                                                                  
                                                              } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                                                  
                                                                  [Utility hideLoadingScreenFromView:self.view];
                                                              }];
                                                          }
                                                      }];
        
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:item1];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
        
    }
    
}

-(IBAction)shareVideoToPublic:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        
        NSMutableArray *arrShare = [NSMutableArray new];
        NSDictionary *details = arrDataSource[sender.tag];
        NSString * title;
        if ([details objectForKey:@"share_msg"]) {
            title = [details objectForKey:@"share_msg"];
        }
        title = [NSString stringWithFormat:@"%@\nSent from HorseApp",title];
        [arrShare addObject:title];
        UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:arrShare applicationActivities:nil];
        activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
        [self presentViewController:activityViewController animated:YES completion:^{}];
        
    }
    
    
}

-(IBAction)playVideo:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        
        NSDictionary *details = arrDataSource[sender.tag];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:[NSURL URLWithString:[details objectForKey:@"media_url"]]];
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


-(IBAction)likeVideo:(EMEmojiableBtn *)sender{
    
    if (sender.tag < arrDataSource.count) {
        
        NSDictionary *details = arrDataSource[sender.tag];
        NSInteger value = 0;
        if ([[details objectForKey:@"emoji_code"] integerValue] >= 0) {
            value = -1;
        }
        
        [self updateDetailsWithEmojiIndex:value position:sender.tag];
        [APIMapper likeVideoWithVideoID:[details objectForKey:@"community_id"] type:@"share" emojiCode:value OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
        }];
    }
    
}

#pragma mark - Emoji Methods



- (void)EMEmojiableBtn:( EMEmojiableBtn* _Nonnull)button selectedOption:(NSUInteger)index{
    
       if (button.tag < arrDataSource.count) {
        
        [self updateDetailsWithEmojiIndex:index position:button.tag];
        NSDictionary *details = arrDataSource[button.tag];
        [APIMapper likeVideoWithVideoID:[details objectForKey:@"community_id"] type:@"share" emojiCode:index OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
        }];
    }
    
    
}

- (void)EMEmojiableBtnCanceledAction:(EMEmojiableBtn* _Nonnull)button{
    
}
- (void)EMEmojiableBtnSingleTap:(EMEmojiableBtn* _Nonnull)button{
    
}


-(void)updateDetailsWithEmojiIndex:(NSInteger)emojiCode position:(NSInteger)position{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //UI Updating code here.
        if (position < arrDataSource.count) {
            NSMutableDictionary *details = [NSMutableDictionary dictionaryWithDictionary:arrDataSource[position]];
            NSInteger oldCode = [[details objectForKey:@"emoji_code"] integerValue];
            [details setObject:[NSNumber numberWithInteger:emojiCode] forKey:@"emoji_code"];
            NSInteger count = [[details objectForKey:@"like_total"] integerValue];
            if (oldCode >= 0 && emojiCode >= 0) {
                
            }else if ((oldCode >= 0) && (emojiCode < 0)){
                count -= 1;
            }else if ((oldCode < 0) && (emojiCode >= 0)){
                count += 1;
            }
            count = count < 0 ? 0 : count;
            [details setObject:[NSNumber numberWithInteger:count] forKey:@"like_total"];
            [arrDataSource replaceObjectAtIndex:position withObject:details];
            [tableView reloadData];
        }
    });
    
    
    
}

#pragma mark - Gallery PopUp Methods

-(IBAction)showMoreGalleries:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        NSDictionary *details = arrDataSource[sender.tag];
        if ([details objectForKey:@"media"]) {
            NSArray *media = [details objectForKey:@"media"];
            if (media.count > 0) {
                galleryView =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForCommunityGallery];
                galleryView.gallery = media;
                UIView *popup = galleryView.view;
                [self.view addSubview:popup];
                galleryView.delegate = self;
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
        }
    }
    
}


-(void)closeGalleryPopUp;{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        galleryView.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [galleryView.view removeFromSuperview];
        galleryView = nil;
    }];
}


#pragma mark - Comment PopUp Methods


-(IBAction)showCommentsBy:(UIButton*)sender{
    
    if (!comments) {
        
        if (sender.tag < arrDataSource.count) {
            NSDictionary *details = arrDataSource[sender.tag];
            comments =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForComments];
            comments.strCommunityID = [details objectForKey:@"community_id"];
            comments.objIndex = sender.tag;
            UIView *popup = comments.view;
            [self.view addSubview:popup];
            comments.delegate = self;
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
        
        
        
    }
    
    [self.view endEditing:YES];
    
    
    
    
}

-(void)closePopUp;{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        comments.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [comments.view removeFromSuperview];
        comments = nil;
    }];
}

-(void)updateCommentCountByCount:(NSInteger)count atIndex:(NSInteger)index{
    
    if (index < arrDataSource.count) {
        NSMutableDictionary *details = [NSMutableDictionary dictionaryWithDictionary:arrDataSource[index]];
        [details setObject:[NSNumber numberWithInteger:count] forKey:@"comment_total"];
        [arrDataSource replaceObjectAtIndex:index withObject:details];
        [tableView reloadData];
    }
}






#pragma mark - Create Game PopUp

-(void)createGamePopUp{
    
    // From header
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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[NotificationsViewController class]]) {
        
        imgNotifn.hidden = true;
    }
    
}

-(IBAction)showUserProfileWithIndex:(UIButton*)sender{
    if (sender.tag < arrDataSource.count) {
        NSDictionary *user = arrDataSource[sender.tag];
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
