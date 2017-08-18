//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//


typedef enum{
    
    eCellGameName       = 0,
    eCellGameType       = 1,
    eCellGameRecord     = 2,
    eCellThumb          = 3,
    eCellInvite         = 4,
    
}eSectionType;

typedef enum{
    
    eTypeCreateReq       = 0,
    eTypeRequested       = 1,
    eTypeAccept          = 2,
    eTypeFriends       = 3,
    
}eReqType;



#import "PlayedGameDetailPageViewController.h"
#import "Constants.h"
#import "PlayerReqListCell.h"
#import "GameUserInfoCell.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GUIPlayerView.h"
#import "ProfileViewController.h"

@interface PlayedGameDetailPageViewController () <GUIPlayerViewDelegate> {
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    IBOutlet UIView * vwHeader;
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    NSString *strAPIErrorMsg;
    GUIPlayerView *playerView;
    NSInteger currentPlayIndex;
    BOOL isAutoPlayEnabled;
    IBOutlet NSLayoutConstraint *topForTable;
    
    
    
}

@property (strong,nonatomic) AVPlayerViewController *avPlayerViewController;
@property (strong,nonatomic) AVPlayer *avPlayer;

@end

@implementation PlayedGameDetailPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getPlayedGameDetails];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    topForTable.constant = self.view.frame.size.width * 0.56;
    isAutoPlayEnabled = TRUE;
    arrDataSource = [NSMutableArray new];
    
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 150;
    tableView.clipsToBounds = YES;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.hidden = true;
    
    float width = 720;
    float height = 460;
    float ratio = width / height;
    float imageHeight = (self.view.frame.size.width) / ratio;
    constraintForNavBg.constant = imageHeight;
    
   
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
             [playerView toggleToPortrait];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            [playerView toggleToPortrait];
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            /* start special animation */
            [playerView toggletoLandscape];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            /* start special animation */
             [playerView toggletoLandscape];
            break;
            
        default:
            break;
    };
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:vwHeader.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                         cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = vwHeader.bounds;
    maskLayer.path = maskPath.CGPath;
    vwHeader.layer.mask = maskLayer;
    vwHeader.layer.masksToBounds = YES;
}



-(void)getPlayedGameDetails{
    
    [Utility showLoadingScreenOnView:self.view withTitle:@"Loading"];
    [APIMapper getPlayedGameDetailsWithGameID:_strGameID OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        [self showDetailsWithJSON:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [Utility hideLoadingScreenFromView:self.view];
        tableView.hidden = false;
    }];
    
}

-(void)showDetailsWithJSON:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[[responds objectForKey:@"data"] objectForKey:@"game"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
    currentPlayIndex = 0;
    [self showVideoPlayer];
    [tableView reloadData];
    
    
}
-(void)configureVideoPlayer{
    
}

#pragma mark - Video Player Confoguration

- (void)showVideoPlayer{
    
    if (arrDataSource.count) {
        NSDictionary *details = arrDataSource[currentPlayIndex];
        if ([details objectForKey:@"videourl"]) {
            NSString *videoURL = [details objectForKey:@"videourl"];
            CGFloat width = self.view.frame.size.width;
            [playerView clean];
            playerView = [[GUIPlayerView alloc] initWithFrame:CGRectMake(0, 65, width, width * 0.56)];
            [playerView setDelegate:self];
            [[self view] addSubview:playerView];
            playerView.arrTracks = [NSArray arrayWithArray:arrDataSource];
            playerView.curentTrack = currentPlayIndex;
            [playerView enableNextPrevButons];
            NSURL *URL = [NSURL URLWithString:videoURL];
            [playerView setVideoURL:URL];
            [playerView prepareAndPlayAutomatically:YES];
            [tableView reloadData];
            if (currentPlayIndex < arrDataSource.count){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentPlayIndex inSection:1];
                [tableView scrollToRowAtIndexPath:indexPath
                                 atScrollPosition:UITableViewScrollPositionTop
                                         animated:YES];
            }
     
        }
    }
    
}

- (void)playerDidEndPlaying{
    
    if (isAutoPlayEnabled) {
         [self playNextTrack];
    }
   
}

- (void)playNextTrack{
    
    currentPlayIndex ++;
    if (currentPlayIndex < arrDataSource.count) {
         [self showVideoPlayer];
    }else{
        currentPlayIndex = 0;
        [self showVideoPlayer];
    }
     
}
- (void)playPrevTrack{
    
    currentPlayIndex --;
    if (currentPlayIndex >= 0) {
         [self showVideoPlayer];
    }else{
        currentPlayIndex ++;
    }
   
}

- (IBAction)enableAutoPlay:(UISwitch*)_switch{
    isAutoPlayEnabled = false;
    if ([_switch isOn]) {
        isAutoPlayEnabled = true;
    }
    
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
    NSInteger rows = 1;
    if (!isDataAvailable) {
        rows = 1;
    }else{
        if (section == 0) {
            rows = 1;
        }else{
            rows = arrDataSource.count;
        }
    }
    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDataAvailable) {
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strAPIErrorMsg];
        return cell;
    }
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (currentPlayIndex < arrDataSource.count) {
            static NSString *CellIdentifier = @"GameUserInfoCell";
            GameUserInfoCell *_cell = (GameUserInfoCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            NSDictionary *game = arrDataSource[currentPlayIndex];
            _cell.lblName.text = [game objectForKey:@"name"];
            _cell.lblGameID.text = [game objectForKey:@"gameId"];
            [_cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[game objectForKey:@"profileurl"]]
                             placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                        
                                    }];
            isAutoPlayEnabled ? [_cell.swtchAutoPlay setOn:true] : [_cell.swtchAutoPlay setOn:false];
            cell = _cell;
        }
       
    }
    else{
        
        static NSString *CellIdentifier = @"NextGameCell";
        PlayerReqListCell *_cell = (PlayerReqListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSDictionary *game = arrDataSource[indexPath.row];
        _cell.btnShare.hidden = [[game objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId] ? NO:YES;
        _cell.lblName.text = [game objectForKey:@"name"];
        _cell.lblKey.text = [game objectForKey:@"gameId"];
        _cell.lblLocation.text = [game objectForKey:@"location"];
         _cell.btnProfile.tag = indexPath.row;
        _cell.btnShare.tag = indexPath.row;
        [_cell.indicator startAnimating];
        [_cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[game objectForKey:@"profileurl"]]
                         placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    
                                }];
        [_cell.imgThumb sd_setImageWithURL:[NSURL URLWithString:[game objectForKey:@"imageurl"]]
                         placeholderImage:[UIImage imageNamed:@"NoImage"]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                    [_cell.indicator stopAnimating];
                                }];
        _cell.vwBG.backgroundColor = [UIColor whiteColor];
        if (currentPlayIndex == indexPath.row) {
            _cell.vwBG.backgroundColor = [UIColor colorWithRed:1.00 green:0.51 blue:0.16 alpha:.2];
        }

         cell = _cell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        [playerView clean];
        [playerView removeFromSuperview];
        currentPlayIndex = indexPath.row;
        [self showVideoPlayer];
        [tableView reloadData];
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

- (IBAction)shareVideo:(UIButton*)button{
    
    if (button.tag < arrDataSource.count) {
        NSDictionary *details = arrDataSource[button.tag];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SHARE"
                                                                       message:@"Do you really want to share this video?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"SHARE"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  [Utility showLoadingScreenOnView:self.view withTitle:@"Sharing.."];
                                                                  [APIMapper shareVideoWithVideoID:[details objectForKey:@"video_id"] location:@"" address:@"" message:@"" frieds:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                      
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
                                                                  
                                                              }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"CANCEL"
                                                               style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                               }];
        
        [alert addAction:firstAction];
        [alert addAction:cancelAction];
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
        [tableView reloadData];
        
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [playerView clean];
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
