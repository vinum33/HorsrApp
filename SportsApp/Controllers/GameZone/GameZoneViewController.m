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

@interface GameZoneViewController ()<CameraRecordDelegate,EMEmojiableBtnDelegate,UIActionSheetDelegate,UICustomActionSheetDelegate>{
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    NSMutableArray *arrUsers;
    BOOL isDataAvailable;
    NSString *strAPIErrorMsg;
    UIImage *thumbImage;
    NSURL *recordedVideoURL;
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
    
    isDataAvailable = true;
    //tableView.hidden = true;
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

-(void)getGameZoneDetails{
    
   /*
    
    [APIMapper getAllGamesWithpageNumber:pageNumber Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = false;
        [self showAllGamesWithJSON:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        tableView.hidden = false;
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        isPageRefresing = false;
        [tableView reloadData];
        [Utility hideLoadingScreenFromView:self.view];
    }];*/
                
}

-(void)showAllGamesWithJSON:(NSDictionary*)responds{
    
    /*
    isDataAvailable = false;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"game"]))
        [arrUsers addObjectsFromArray:[[responds objectForKey:@"data"] objectForKey:@"game"]];
    if (arrUsers.count > 0) isDataAvailable = true;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
    [tableView reloadData];
    */
    
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
        [_cell setDataSourceWithArray:nil];
        float width = self.view.frame.size.width;
        [_cell setUpPagingWithFrame:width];
        
        cell = _cell;
    }
    if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"VideoDisplayCell";
        VideoDisplayCell *_cell = (VideoDisplayCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = _cell;
    }
    if (indexPath.row == 2) {
        static NSString *CellIdentifier = @"CommunityActionCell";
        CommunityActionCell *_cell = (CommunityActionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        _cell.btnEmoji.delegate = self;
        _cell.btnEmoji.dataset = @[
                           [[EMEmojiableOption alloc] initWithImage:@"Sad" withName:@" Sad"],
                           [[EMEmojiableOption alloc] initWithImage:@"Wow" withName:@" Wow"],
                           [[EMEmojiableOption alloc] initWithImage:@"Haha" withName:@" Haha"],
                           [[EMEmojiableOption alloc] initWithImage:@"Angry" withName:@" Angry"],
                           ];
        [ _cell.btnEmoji setImage:[UIImage imageNamed:@"Wow"] forState:UIControlStateNormal];
        _cell.btnEmoji.vwBtnSuperView = self.view;
        [_cell.btnEmoji privateInit];
        cell = _cell;
    }
    if (indexPath.row == 3) {
        static NSString *CellIdentifier = @"ScoreBoardCell";
        ScoreBoardCell *_cell = (ScoreBoardCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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

#pragma mark - Share Videos

-(IBAction)shareVideos:(id)sender{
    
    UICustomActionSheet* actionSheet = [[UICustomActionSheet alloc] initWithTitle:@"SHARE VIDEO" delegate:self buttonTitles:@[@"Cancel",@"  Share Post Now",@"  Write Now"]];
    [actionSheet setButtonColors:@[[UIColor whiteColor]]];
    [actionSheet setBackgroundColor:[UIColor clearColor]];
    [actionSheet setSubtitleColor:[UIColor whiteColor]];
    [actionSheet showInView:self.view];



}

-(void)customActionSheet:(UICustomActionSheet *)customActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"index %d",buttonIndex);
    
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
            //            [self compressVideoWithURL:outputURL onComplete:^(bool completed) {
            //
            //                dispatch_async(dispatch_get_main_queue(), ^{
            //                    [Utility hideLoadingScreenFromView:self.view];
            //                    thumbImage = [Utility fixrotation:[Utility getThumbNailFromVideoURL:outputURL]]; ;
            //                    [tableView reloadData];
            //                });
            //
            //            }];
            
        }
        
        [self compressVideoWithURL:outputURL handler:^(AVAssetExportSession *completion) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [Utility hideLoadingScreenFromView:self.view];
                thumbImage = [Utility fixrotation:[Utility getThumbNailFromVideoURL:outputURL]]; ;
                [tableView reloadData];
                
            });
            
        }];
        
    }
}

-(void)compressVideoWithURL:(NSURL*)videoURL handler:(void (^)(AVAssetExportSession*))completion{
    
    /*
     
     NSError *error;
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
     NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/SportsApp"];
     
     if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
     [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
     NSString *outputFile = [NSString stringWithFormat:@"%@/%@.mp4",dataPath,@"Game"];
     NSURL *outputURL = [NSURL fileURLWithPath:outputFile];
     SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:[AVAsset assetWithURL:videoURL]];
     NSURL *url = outputURL;
     encoder.outputURL=url;
     encoder.outputFileType = AVFileTypeMPEG4;
     encoder.shouldOptimizeForNetworkUse = YES;
     encoder.videoSettings = @
     {
     AVVideoCodecKey: AVVideoCodecH264,
     AVVideoWidthKey:[NSNumber numberWithInteger:360], // required
     AVVideoHeightKey:[NSNumber numberWithInteger:480], // required
     AVVideoCompressionPropertiesKey: @
     {
     AVVideoAverageBitRateKey: @500000, // Lower bit rate here
     AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
     },
     };
     
     encoder.audioSettings = @
     {
     AVFormatIDKey: @(kAudioFormatMPEG4AAC),
     AVNumberOfChannelsKey: @2,
     AVSampleRateKey: @44100,
     AVEncoderBitRateKey: @128000,
     };
     
     [encoder exportAsynchronouslyWithCompletionHandler:^
     {
     int status = encoder.status;
     if (status == AVAssetExportSessionStatusCompleted)
     {
     
     
     }
     else if (status == AVAssetExportSessionStatusCancelled)
     {
     NSLog(@"Video export cancelled");
     }
     else
     {
     }
     
     completed(YES);
     }];*/
    
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


-(IBAction)deleteVideo:(id)sender{
    
    thumbImage = nil;
    recordedVideoURL = nil;
    [tableView reloadData];
}

-(IBAction)playRecordedVideo:(id)sender{
    
    if (recordedVideoURL) {
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:recordedVideoURL];
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
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    
}


- (void)EMEmojiableBtn:( EMEmojiableBtn* _Nonnull)button selectedOption:(NSUInteger)index{
    EMEmojiableOption *option = [button.dataset objectAtIndex:index];
    [button setImage: [UIImage imageNamed:option.imageName] forState:UIControlStateNormal];
    [button setTitle:option.name forState:UIControlStateNormal];
}
- (void)EMEmojiableBtnCanceledAction:(EMEmojiableBtn* _Nonnull)button{
    
}
- (void)EMEmojiableBtnSingleTap:(EMEmojiableBtn* _Nonnull)button{
    
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
