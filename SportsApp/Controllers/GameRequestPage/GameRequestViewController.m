//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

typedef enum{
    
    eCellPlayed     = 0,
    eCellWon        = 1,
    eCellLost       = 2,
    eCellNoResult   = 3,
    eCellPoint      = 4,
    
}eSectionType;

#define kLimitReached           406

#import "GameRequestViewController.h"
#import "FriendRequestsCell.h"
#import "Constants.h"
#import "ProfileViewController.h"
#import "PlayerReqListCell.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface GameRequestViewController (){
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    UIRefreshControl *refreshController;
    
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
}

@end

@implementation GameRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllGameRequests];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    currentPage = 1;
    strAPIErrorMsg = @"No records found.";
    
    refreshController = [[UIRefreshControl alloc] init];
    [refreshController addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshController];

    
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.clipsToBounds = YES;
    tableView.layer.cornerRadius = 5.f;
    tableView.layer.borderWidth = 1.f;
    tableView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    tableView.hidden = true;
    
    float width = 720;
    float height = 460;
    float ratio = width / height;
    float imageHeight = (self.view.frame.size.width) / ratio;
    constraintForNavBg.constant = imageHeight;
    
    arrDataSource = [NSMutableArray new];
}

-(void)handleRefresh{
    
    [self getAllGameRequests];
    
}
-(void)getAllGameRequests{
    
    [Utility hideLoadingScreenFromView:self.view];
    [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    [APIMapper getAllGameRequetsOnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        [Utility hideLoadingScreenFromView:self.view];
        [refreshController endRefreshing];
        isPageRefresing = false;
        [self showAllRequestsWithJSON:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        isDataAvailable = false;
         tableView.hidden = false;
         [Utility hideLoadingScreenFromView:self.view];
         [refreshController endRefreshing];
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        isPageRefresing = false;
        [Utility hideLoadingScreenFromView:self.view];
        [tableView reloadData];
    }];
    
}

-(void)showAllRequestsWithJSON:(NSDictionary*)responds{
    
    [arrDataSource removeAllObjects];
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[responds objectForKey:@"data"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
    [tableView reloadData];
    
    
}



#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = arrDataSource.count;
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
    
    if (indexPath.row < arrDataSource.count) {
        
        static NSString *CellIdentifier = @"PlayerReqListCell";
        PlayerReqListCell *cell = (PlayerReqListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row < arrDataSource.count) {
            [cell.indicator startAnimating];
            [cell closeExpandedMenu];
            NSDictionary *game = arrDataSource[indexPath.row];
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
#pragma mark - IBActions


-(IBAction)replyToAGameReq:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        NSDictionary *details = arrDataSource[sender.tag];
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


-(IBAction)showUserProfileWithIndex:(UIButton*)sender{
    if (sender.tag < arrDataSource.count) {
        NSDictionary *user = arrDataSource[sender.tag];
        ProfileViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GeneralStoryBoard Identifier:StoryBoardIdentifierForProfile];
        [[self navigationController]pushViewController:games animated:YES];
        games.strUserID = [user objectForKey:@"user_id"];
    }
}



-(IBAction)playRequestedVideos:(UIButton*)sender{
    
    NSURL *videoURL;
    if (sender.tag < arrDataSource.count) {
        NSDictionary *details = arrDataSource[sender.tag];
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


- (void)videoDidFinish:(id)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //fade out / remove subview
}

-(void)replyToAGameReqWithStatus:(NSString*)statusMsg andReqID:(NSString*)reqId atIndex:(NSInteger)index{
    
    [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    
    [APIMapper replyToGameRequestWithMessage:statusMsg requestID:reqId Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Utility hideLoadingScreenFromView:self.view];
        if (index < arrDataSource.count) {
            [arrDataSource removeObjectAtIndex:index];
            if (arrDataSource.count <= 0) {
                isDataAvailable = false;
            }
            [tableView reloadData];
        }
        
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [Utility hideLoadingScreenFromView:self.view];
        NSString *title = @"ERROR";
        NSString *errormsg = error.localizedDescription;
        if (task.responseData) {
            if ([task.response statusCode] == kLimitReached) {
                title = @"LIMIT REACHED";
                [arrDataSource removeObjectAtIndex:index];
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


-(void)displayErrorMessgeWithDetails:(NSData*)responseData{
    if (responseData.length) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:kNilOptions
                                                               error:&error];
        if (NULL_TO_NIL([json objectForKey:@"text"]))
            strAPIErrorMsg = [json objectForKey:@"text"];
        
        isDataAvailable = false;
        [arrDataSource removeAllObjects];
        [tableView reloadData];
        
    }
    
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
