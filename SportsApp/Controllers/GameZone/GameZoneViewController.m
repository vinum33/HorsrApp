//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "GameZoneViewController.h"
#import "UserCell.h"
#import "UserCollectionViewCell.h"
#import "Constants.h"
#import "VideoDisplayCell.h"
#import "CommunityActionCell.h"
#import "ScoreBoardCell.h"
#import "SDAVAssetExportSession.h"
#import <AVKit/AVKit.h>
#import "CameraViewcontroller.h"
#import "EMEmojiableBtn.h"
#import "UICustomActionSheet.h"
#import "ScoreBoardViewController.h"
#import "ShareGameViewController.h"
#import "GroupChatComposeViewController.h"
#import "InfoPopUp.h"
#import "WinnerPopUp.h"
#import "NotificationsViewController.h"
#import "SearchFriendsViewController.h"
#import "FriendRequestsViewController.h"

@interface GameZoneViewController ()<CameraRecordDelegate,EMEmojiableBtnDelegate,UIActionSheetDelegate,UICustomActionSheetDelegate,UserCellDelegate,ScoreBoardCellDelegate,InfoPopUpDelegate,WinnerPopUpDelegate>{
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    IBOutlet UILabel* lblTitle;
    IBOutlet UIButton* btnInfo;
    NSMutableArray *arrUsers;
    BOOL isDataAvailable;
    NSString *strAPIErrorMsg;
    UIImage *thumbImage;
    NSURL *recordedVideoURL;
    NSInteger clickedIndex;
    NSString *strGameCreatedUserID;
    NSString *strOwnerID;
    NSString *strTrickID;
    NSString *strStatusMsg;
    InfoPopUp *vwInfoPopUp;
    WinnerPopUp *vwWinnderPopUp;
}

@end

@implementation GameZoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getGameZoneDetails];
    [self removeAllContentsInMediaFolder];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    
    isDataAvailable = false;
    tableView.hidden = true;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    
    tableView.clipsToBounds = YES;
    tableView.layer.cornerRadius = 5.f;
    tableView.layer.borderWidth = 1.f;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    
    float width = 720;
    float height = 460;
    float ratio = width / height;
    float imageHeight = (self.view.frame.size.width) / ratio;
    constraintForNavBg.constant = imageHeight;
    
    arrUsers = [NSMutableArray new];
}

-(IBAction)refershPage:(id)sender{
    
    [self getGameZoneDetails];
}

-(void)getGameZoneDetails{
    
    [arrUsers removeAllObjects];
    [Utility hideLoadingScreenFromView:self.view];
    [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    
    [APIMapper getGameZoneDetailsWithGameID:_strGameID Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        [self showAllGamesWithJSON:responseObject];
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

-(void)showAllGamesWithJSON:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"player"]))
        arrUsers = [NSMutableArray arrayWithArray:[[responds objectForKey:@"data"]objectForKey:@"player"]];
    if ([[responds objectForKey:@"data"] objectForKey:@"user_id"]) {
        strGameCreatedUserID = [[responds objectForKey:@"data"] objectForKey:@"user_id"];
    }
    if ([[responds objectForKey:@"data"] objectForKey:@"trick_id"]) {
        strTrickID = [[responds objectForKey:@"data"] objectForKey:@"trick_id"];
    }
    if ([[responds objectForKey:@"data"] objectForKey:@"status_message"]) {
        strStatusMsg = [[responds objectForKey:@"data"] objectForKey:@"status_message"];
        btnInfo.hidden = strStatusMsg.length ? false : true;
    }
    if ([[[responds objectForKey:@"data"] objectForKey:@"winner"] integerValue] > 0) {
        NSString *winUserID = [[responds objectForKey:@"data"] objectForKey:@"winner"];
        if ([winUserID isEqualToString:[[User sharedManager]userId]]) {
             [self showWinnerPopUpIsByWinner:true andName:nil];
        }else{
            [self showWinnerPopUpIsByWinner:false andName:[[responds objectForKey:@"data"] objectForKey:@"winner_name"]];
        }
        
        
    }
    if ([[responds objectForKey:@"data"] objectForKey:@"gameId"]) {
        lblTitle.text = [[responds objectForKey:@"data"] objectForKey:@"gameId"];
    }
    if ([[responds objectForKey:@"data"] objectForKey:@"owner_id"]) {
        strOwnerID = [[responds objectForKey:@"data"] objectForKey:@"owner_id"];
    }
    
    
    if (arrUsers.count > 0) isDataAvailable = true;
    clickedIndex = 0;
    if (arrUsers.count) {
        for (NSDictionary *dict in arrUsers) {
            if ([[dict objectForKey:@"turn"] boolValue]) {
                break;
            }
             clickedIndex ++;
        }
    }
    if (clickedIndex >= arrUsers.count) clickedIndex = 0;
    
    [tableView reloadData];
    
 
}

-(void)showToastWithMessage:(NSString*)strMesage{
    
    [ALToastView toastInView:self.view withText:strMesage];
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 4;
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
        static NSString *CellIdentifier = @"UserCell";
        UserCell *_cell = (UserCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        _cell.selectedIndex = clickedIndex;
        [_cell setDataSourceWithArray:arrUsers];
        _cell.delegate = self;
        float width = self.view.frame.size.width;
        [_cell setUpPagingWithFrame:width];
        cell = _cell;
    }
    if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"VideoDisplayCell";
        VideoDisplayCell *_cell = (VideoDisplayCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        _cell.imgThumb.image = [UIImage imageNamed:@"Game_Waiting"];
        [_cell.indicator stopAnimating];
        _cell.btnVideoPlay.hidden = true;
        _cell.btnSuccess.hidden = true;
        _cell.btnFailure.hidden = true;
        _cell.btnRecord.hidden = true;
        _cell.constarintImgHeight.constant = self.view.frame.size.height - 300;
        if (clickedIndex < arrUsers.count) {
            NSDictionary *user = arrUsers[clickedIndex];
            if ([user objectForKey:@"video"]) {
                NSArray *videos = [user objectForKey:@"video"];
                if (videos.count) {
                     _cell.btnVideoPlay.hidden = false;
                    NSDictionary *video = [videos lastObject];
                    if (![[video objectForKey:@"verify_status"] boolValue] && [strGameCreatedUserID isEqualToString:[User sharedManager].userId]) {
                        _cell.btnSuccess.hidden = false;
                        _cell.btnFailure.hidden = false;
                        
                    }else{
                        _cell.btnSuccess.hidden = true;
                        _cell.btnFailure.hidden = true;
                    }
                    [_cell.indicator startAnimating];
                    [_cell.imgThumb sd_setImageWithURL:[NSURL URLWithString:[video objectForKey:@"imageurl"]]
                                      placeholderImage:[UIImage imageNamed:@"NoImage"]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                   [_cell.indicator stopAnimating];
                                                 [UIView transitionWithView:_cell.imgThumb
                                                                   duration:0.3f
                                                                    options:UIViewAnimationOptionTransitionCrossDissolve
                                                                 animations:^{
                                                                     _cell.imgThumb.image = image;
                                                                 } completion:nil];
                                             }];

                }
            }else{
                if ([[user objectForKey:@"turn"] boolValue] && [[user objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId]) {
                    _cell.btnRecord.hidden = false;
                }
            }
           
        }
       cell = _cell;
    }
    if (indexPath.row == 2) {
        static NSString *CellIdentifier = @"CommunityActionCell";
        CommunityActionCell *_cell = (CommunityActionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        _cell.btnEmoji.delegate = self;
        _cell.btnEmoji.dataset = @[
                                  [[EMEmojiableOption alloc] initWithImage:@"Like_Blue" withName:@" Like"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Haha" withName:@" Haha"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Wow" withName:@" Wow"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Sad" withName:@" Sad"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Angry" withName:@" Angry"],
                                  ];
        _cell.btnEmoji.vwBtnSuperView = self.view;
        [_cell.btnEmoji privateInit];
        [_cell.btnEmoji setEnabled:false];
        _cell.btnShare.hidden = true;
        [_cell.btnEmoji setImage:[UIImage imageNamed:@"Like_Inactive"] forState:UIControlStateNormal];
        [_cell.btnEmoji setTitle:[NSString stringWithFormat:@" %dLikes",0]forState:UIControlStateNormal];
        if (clickedIndex < arrUsers.count) {
            NSDictionary *user = arrUsers[clickedIndex];
            if ([user objectForKey:@"video"]) {
                 [_cell.btnEmoji setEnabled:true];
                NSArray *videos = [user objectForKey:@"video"];
                NSDictionary *video = [videos lastObject];
                [_cell.btnEmoji setImage:[UIImage imageNamed:@"Like_Inactive"] forState:UIControlStateNormal];
                [_cell.btnEmoji setTitle:[NSString stringWithFormat:@" %dLikes",[[video objectForKey:@"like_total"] integerValue]]forState:UIControlStateNormal];
                if ([[video objectForKey:@"emoji_code"] integerValue] >= 0) {
                    EMEmojiableOption *option = [_cell.btnEmoji.dataset objectAtIndex:[[video objectForKey:@"emoji_code"] integerValue]];
                    [_cell.btnEmoji setImage: [UIImage imageNamed:option.imageName] forState:UIControlStateNormal];
                }
            }
            if ([user objectForKey:@"video"]) {
                  if ([[user objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId]) _cell.btnShare.hidden = false;
            }
        }
        cell = _cell;
        
    }
    if (indexPath.row == 3) {
        static NSString *CellIdentifier = @"ScoreBoardCell";
        ScoreBoardCell *_cell = (ScoreBoardCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        _cell.delegate = self;
        float width = self.view.frame.size.width - 30;
        _cell.selectedIndex = clickedIndex;
        [_cell setUpPagingWithFrame:width];
        [_cell setDataSourceWithArray:arrUsers];
        cell = _cell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
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
        [tableView reloadData];
        
    }
    
}

#pragma mark - Verify Video Methods

-(IBAction)verifyVideoWithTag:(UIButton*)sender{
    
    BOOL success = true;
    if (sender.tag == 1) {
        success = false;
    }
    if (clickedIndex < arrUsers.count) {
        NSDictionary *user = arrUsers[clickedIndex];
        NSInteger nextUser = 0;
        NSString *nextUsrID ;
        if (arrUsers.count) {
            if (clickedIndex + 1 < arrUsers.count) {
               nextUser = clickedIndex + 1;
                while (nextUser < arrUsers.count) {
                    NSDictionary *user = arrUsers[nextUser];
                    if ([[user objectForKey:@"player_status"] isEqualToString:@"out"]) {
                    }else{
                        break;
                    }
                    nextUser ++;
                }
            }
            NSDictionary *user = arrUsers[nextUser];
            nextUsrID = [user objectForKey:@"user_id"];
        }

        if ([user objectForKey:@"video"]) {
            NSArray *videos = [user objectForKey:@"video"];
             NSDictionary *video = [videos lastObject];
            [Utility showLoadingScreenOnView:self.view withTitle:@"Verifying.."];
            [APIMapper verifyVideoWithTrickID:strTrickID status:success videoID:[video objectForKey:@"video_id"] gameID:_strGameID nextUserID:nextUsrID OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self getGameZoneDetails];
                [Utility hideLoadingScreenFromView:self.view];
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                
                [Utility hideLoadingScreenFromView:self.view];
            }];
            
        }
    }
}

#pragma mark - Custom Cell Deleagtes

-(IBAction)playVideo:(id)sender{
    
    if (clickedIndex < arrUsers.count) {
        
        NSDictionary *info = arrUsers[clickedIndex];
        if ([info objectForKey:@"video"]) {
            NSArray *videos = [info objectForKey:@"video"];
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
    }
}

- (void)videoDidFinish:(id)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //fade out / remove subview
}



-(void)userSelectedWithIndex:(NSInteger)index;{
    
    if (index < arrUsers.count) {
        
        clickedIndex = index;
        [tableView reloadData];
    }
}

-(void)scoreBoardSelectedWithIndex:(NSInteger)index{
    
    ScoreBoardViewController *score =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GeneralStoryBoard Identifier:StoryBoardIdentifierForScoreBoard];
    score.users = arrUsers;
    score.clickedIndex = index;
    [[self navigationController]pushViewController:score animated:YES];
    
}

#pragma mark - Emoji Methods

-(IBAction)likeVideo:(EMEmojiableBtn *)sender{
    
    if (sender.tag < arrUsers.count) {
        
        NSDictionary *details = arrUsers[clickedIndex];
        if ([details objectForKey:@"video"]) {
            NSArray *videos = [details objectForKey:@"video"];
            NSDictionary *video = [videos lastObject];
            NSInteger value = 0;
            if ([[video objectForKey:@"emoji_code"] integerValue] >= 0) {
                value = -1;
            }
            [self updateDetailsWithEmojiIndex:value position:clickedIndex];
            [APIMapper likeVideoWithVideoID:[video objectForKey:@"video_id"] type:@"game" emojiCode:value OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                
            }];
            
        }

      }
    
}

- (void)EMEmojiableBtn:( EMEmojiableBtn* _Nonnull)button selectedOption:(NSUInteger)index{
    EMEmojiableOption *option = [button.dataset objectAtIndex:index];
    [button setImage: [UIImage imageNamed:option.imageName] forState:UIControlStateNormal];
   // [button setTitle:option.name forState:UIControlStateNormal];
    if (clickedIndex < arrUsers.count) {
        
       
        NSDictionary *details = arrUsers[clickedIndex];
        if ([details objectForKey:@"video"]) {
            [self updateDetailsWithEmojiIndex:index position:clickedIndex];
            NSArray *videos = [details objectForKey:@"video"];
            NSDictionary *video = [videos lastObject];
            [APIMapper likeVideoWithVideoID:[video objectForKey:@"video_id"] type:@"game" emojiCode:index OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                
            }];
            
        }
        
    }
    
}
- (void)EMEmojiableBtnCanceledAction:(EMEmojiableBtn* _Nonnull)button{
    
}
- (void)EMEmojiableBtnSingleTap:(EMEmojiableBtn* _Nonnull)button{
    
}

-(void)updateDetailsWithEmojiIndex:(NSInteger)emojiCode position:(NSInteger)position{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //UI Updating code here.
        if (position < arrUsers.count) {
            
            NSMutableDictionary *details = [NSMutableDictionary dictionaryWithDictionary:arrUsers[position]];
            
            if ([details objectForKey:@"video"]) {
                NSArray *videos = [details objectForKey:@"video"];
                NSMutableDictionary *video = [NSMutableDictionary dictionaryWithDictionary:[videos lastObject]];
                NSInteger oldCode = [[video objectForKey:@"emoji_code"] integerValue];
                NSInteger count = [[video objectForKey:@"like_total"] integerValue];
                if (oldCode >= 0 && emojiCode >= 0) {
                    
                }else if ((oldCode >= 0) && (emojiCode < 0)){
                    count -= 1;
                }else if ((oldCode < 0) && (emojiCode >= 0)){
                    count += 1;
                }
                count = count < 0 ? 0 : count;
                [video setObject:[NSNumber numberWithInteger:count] forKey:@"like_total"];
                [video setObject:[NSNumber numberWithInteger:emojiCode] forKey:@"emoji_code"];
                NSArray *new = [[NSArray alloc] initWithObjects:video, nil];
                [details setObject:new forKey:@"video"];
                [arrUsers replaceObjectAtIndex:position withObject:details];
                [tableView reloadData];
            }
          
        }
    });
    
    
}



#pragma mark - Share Videos

-(IBAction)shareVideos:(id)sender{
    
    UICustomActionSheet* actionSheet = [[UICustomActionSheet alloc] initWithTitle:@"SHARE VIDEO" delegate:self buttonTitles:@[@"Cancel",@"  Share Post Now",@"  Write Now"]];
    [actionSheet setButtonColors:@[[UIColor whiteColor]]];
    [actionSheet setBackgroundColor:[UIColor clearColor]];
    [actionSheet setSubtitleColor:[UIColor whiteColor]];
    [actionSheet showInView:self.view];

}

-(void)customActionSheet:(UICustomActionSheet *)customActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        if (clickedIndex < arrUsers.count) {
            ShareGameViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForShareGame];
            [[self navigationController]pushViewController:games animated:YES];
            games.userInfo = arrUsers[clickedIndex];
        }
    }
    else if (buttonIndex == 1) {
        if (clickedIndex < arrUsers.count) {
             NSDictionary *details = arrUsers[clickedIndex];
              if ([details objectForKey:@"video"]) {
                NSArray *videos = [details objectForKey:@"video"];
                NSDictionary *video = [videos lastObject];
                  [APIMapper shareVideoWithVideoID:[video objectForKey:@"video_id"] location:@"" address:@"" message:@"" frieds:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      [Utility hideLoadingScreenFromView:self.view];
                      if ([responseObject objectForKey:@"text"]) {
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SHARE VIDEO"
                                                                          message:[responseObject objectForKey:@"text"]
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil];
                          [alert show];
                      }
                      
                  } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                      
                      [Utility hideLoadingScreenFromView:self.view];
                      if (task.responseData) [self displayErrorMessgeWithDetails:task.responseData];
                      else [self showAlertWithMessage:error.localizedDescription];
                      
                  }];
              }
            
        }
        
    }
}




#pragma mark - Video Record

-(IBAction)recordVideo:(id)sender{
    
    CameraViewcontroller *recordView = [[CameraViewcontroller alloc] initWithNibName:nil bundle:nil];
    recordView.delegate = self;
    recordView.timeLength = 9;
    [[self navigationController]presentViewController:recordView animated:YES completion:nil];
}

-(void)recordCompletedWithOutOutURL:(NSURL*)outputURL{
    if (outputURL) {
        recordedVideoURL = outputURL;
        NSString *path = [outputURL path];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [Utility hideLoadingScreenFromView:self.view];
            [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
            [self compressVideoWithURL:outputURL handler:^(AVAssetExportSession *completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utility hideLoadingScreenFromView:self.view];
                    thumbImage = [Utility fixrotation:[Utility getThumbNailFromVideoURL:outputURL]];
                    [tableView reloadData];
                    [self submitVideo:nil];
                    
                });
                
            }];
            
        }
        
    }
}

-(void)compressVideoWithURL:(NSURL*)videoURL handler:(void (^)(AVAssetExportSession*))completion{
    
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/SportsApp"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    NSString *outputFile = [NSString stringWithFormat:@"%@/%@.mp4",dataPath,@"Game"];
    NSURL *outputURL = [NSURL fileURLWithPath:outputFile];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        completion(exportSession);
    }];
    
}

#pragma mark - Game Submit Methods

-(IBAction)submitVideo:(id)sender{
    
    [self uploadMediaOnsuccess:^(NSDictionary *responds) {
        
        if ([responds objectForKey:@"data"]) {
            NSDictionary *data = [responds objectForKey:@"data"];
            
            if (clickedIndex < arrUsers.count) {
                [APIMapper submitGameWithGameID:_strGameID mediaFileName:[data objectForKey:@"media_file"] thumbFileName:[data objectForKey:@"thumb_file"] trickID:strTrickID OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [Utility hideLoadingScreenFromView:self.view];
                    if ([responseObject objectForKey:@"text"]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SUBMIT GAME"
                                                                        message:[responseObject objectForKey:@"text"]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        [self resetIfNeeded];
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
            }
           
        }
        
    } failure:^{
        
        
    }];
}

-(void)uploadMediaOnsuccess:(void (^)(NSDictionary *responds ))success failure:(void (^)())failure{
    
    [Utility showLoadingScreenOnView:self.view withTitle:@"Creating.."];
    [APIMapper uploadGameMediasWith:recordedVideoURL thumbnail:thumbImage type:@"video" Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    
}



#pragma mark - Winner PopUp and Delegates


-(IBAction)showWinnerPopUpIsByWinner:(BOOL)isByWinner andName:(NSString*)name{
    
    if (!vwWinnderPopUp) {
        
        [[self delegate]gameZoneCompleted];
        NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"WinnerPopUp" owner:self options:nil];
        vwWinnderPopUp = [viewArray objectAtIndex:0];
        [self.view addSubview:vwWinnderPopUp];
        vwWinnderPopUp.delegate = self;
        vwWinnderPopUp.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwWinnderPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwWinnderPopUp)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwWinnderPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwWinnderPopUp)]];
        
        vwWinnderPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            vwWinnderPopUp.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            
            if (!isByWinner) {
                [vwWinnderPopUp setUpPopUpForOthersWithWinnerName:name];
            }
            
            // if you want to do something once the animation finishes, put it here
        }];
        
        
    }
    
    [self.view endEditing:YES];
    [vwWinnderPopUp setUp];
}

-(void)closeWinnerPopUp{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwWinnderPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [vwWinnderPopUp removeFromSuperview];
        vwWinnderPopUp = nil;
        [self goBack:nil];
        
    }];
}



#pragma mark - Info PopUp and Delegates


-(IBAction)showInfoPopUp{
    
    if (!vwInfoPopUp) {
        
        NSString *nibName = @"InfoPopUp";
        if ([strOwnerID isEqualToString:[User sharedManager].userId]) {
            nibName = @"InfoPopUpEdit";
        }
        NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        vwInfoPopUp = [viewArray objectAtIndex:0];
        [self.view addSubview:vwInfoPopUp];
        vwInfoPopUp.delegate = self;
        vwInfoPopUp.strGameID = _strGameID;
        vwInfoPopUp.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwInfoPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwInfoPopUp)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwInfoPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwInfoPopUp)]];
        vwInfoPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            vwInfoPopUp.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
        
    }
    
    [self.view endEditing:YES];
    [vwInfoPopUp setUpWithTitle:strStatusMsg];
}



-(void)closeInfoPopUp:(BOOL)shouldRefresh{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwInfoPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [vwInfoPopUp removeFromSuperview];
        vwInfoPopUp = nil;
    }];

    if (shouldRefresh) {
        [self getGameZoneDetails];
    }
}



#pragma mark - IBActions

-(IBAction)showNotifications{
    
    NotificationsViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForNotifications];
    [[self navigationController]pushViewController:games animated:YES];
}

-(IBAction)showSearchPeoplePage{
    
    SearchFriendsViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForSearchFriends];
    [[self navigationController]pushViewController:games animated:YES];
}

-(IBAction)showFriendReqPage{
    
    FriendRequestsViewController *friendList =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForFriendRequest];
    [self.navigationController pushViewController:friendList animated:YES];
}


#pragma mark - Generic Methods


-(void)showAlertWithMessage:(NSString*)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SHARE VIDEO"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



-(IBAction)composeChat{
    
    GroupChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForGroupChatComposer];
    chatCompose.strGameID = _strGameID;
    chatCompose.strChatCount = [NSString stringWithFormat:@"%d",arrUsers.count] ;
    [[self navigationController]pushViewController:chatCompose animated:YES];
    
}


-(void)resetIfNeeded{
    
    [self getGameZoneDetails];
    [self removeAllContentsInMediaFolder];
}


-(IBAction)deleteVideo:(id)sender{
    
    thumbImage = nil;
    recordedVideoURL = nil;
    [tableView reloadData];
}


-(void)removeAllContentsInMediaFolder{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/SportsApp"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:dataPath error:&error];
    if (success){
        
    }
    else
    {
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
