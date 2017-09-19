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
    eCellStatusMsg      = 2,
    eCellInvite         = 3,
    eCellThumb          = 4,
    eCellGameRecord     = 5,
   
    
    
}eSectionType;

typedef enum{
    
    eGameTypeNone      = 0,
    eGameTypeHorse     = 1,
    eGameTypePig       = 2,
    
    
}eGameType;

#import <AVKit/AVKit.h>
#import "CreateGameViewController.h"
#import "Constants.h"
#import "ThumbCustomCell.h"
#import "InvitedUserListCell.h"
#import "AHTagTableViewCell.h"
#import "CameraViewcontroller.h"
#import "InviteOthersViewController.h"
#import "SDAVAssetExportSession.h"
#import "CreatedGameSummaryViewController.h"

@interface CreateGameViewController () <UserTagListCellDelegate,CameraRecordDelegate,InviteUserDeleagte>{
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    IBOutlet UIView *vwBG;
    
    float tagCellHeight;
    NSMutableArray *arrInvites;
    NSString *strGameID;
    NSString *strStatusMsg;
    NSInteger gameType;
    UIImage *thumbImage;
    NSURL *recordedVideoURL;
    UIView *inputAccView;
    
    
}

@end

@implementation CreateGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self initializeGameVariables];
    [self createInputAccessoryView];
    [self removeAllContentsInMediaFolder];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    tagCellHeight = 0;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    
    vwBG.clipsToBounds = YES;
    vwBG.layer.cornerRadius = 5.f;
    vwBG.layer.borderWidth = 1.f;
    tableView.backgroundColor = [UIColor whiteColor];
    vwBG.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    float width = 720;
    float height = 460;
    float ratio = width / height;
    float imageHeight = (self.view.frame.size.width) / ratio;
    constraintForNavBg.constant = imageHeight;
    
    
}

-(void)initializeGameVariables{
    
    gameType = eGameTypeNone;
    
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 6;
    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == eCellGameName) {
        static NSString *CellIdentifier = @"GameNameCell";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if ([[cell contentView]viewWithTag:1]) {
            UIView *vwContainer = (UIImageView*)[[cell contentView]viewWithTag:1];
            vwContainer.layer.cornerRadius = 25.f;
            vwContainer.layer.borderWidth = 1.f;
            vwContainer.backgroundColor = [UIColor whiteColor];
            vwContainer.layer.borderColor = [UIColor getSeperatorColor].CGColor;
            if ([vwContainer viewWithTag:2]) {
                UITextField *txtGameName = (UITextField*)[vwContainer viewWithTag:2];
                if ([txtGameName respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                    UIColor *color = [UIColor lightGrayColor];
                    txtGameName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter game name" attributes:@{NSForegroundColorAttributeName: color}];
                }
                if (strGameID.length) {
                    txtGameName.text = strGameID;
                }
                
            }
            
        }
       
    }
   
    if (indexPath.row == eCellGameType) {
        static NSString *CellIdentifier = @"GameTypeCell";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([[cell contentView]viewWithTag:1]) {
            UIView *vwContainer = (UIImageView*)[[cell contentView]viewWithTag:1];
            vwContainer.layer.cornerRadius = 25.f;
            vwContainer.layer.borderWidth = 1.f;
            vwContainer.backgroundColor = [UIColor whiteColor];
            vwContainer.layer.borderColor = [UIColor getSeperatorColor].CGColor;
            
            UIButton *btnHorse;
            UIButton *btnPig;
            if ([vwContainer viewWithTag:2]) {
                btnHorse = (UIButton*)[vwContainer viewWithTag:2];
                [btnHorse setImage:[UIImage imageNamed:@"Game_Selection_Normal"] forState:UIControlStateNormal];
            }
            if ([vwContainer viewWithTag:3]) {
                btnPig = (UIButton*)[vwContainer viewWithTag:3];
                [btnPig setImage:[UIImage imageNamed:@"Game_Selection_Normal"] forState:UIControlStateNormal];
            }
            if (gameType == eGameTypeHorse) {
                [btnHorse setImage:[UIImage imageNamed:@"Game_Selection_Active"] forState:UIControlStateNormal];
            }else if (gameType == eGameTypePig){
                [btnPig setImage:[UIImage imageNamed:@"Game_Selection_Active"] forState:UIControlStateNormal];
            }
            
        }
    }
    if (indexPath.row == eCellStatusMsg) {
        static NSString *CellIdentifier = @"GameStatus";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if ([[cell contentView]viewWithTag:1]) {
            UIView *vwContainer = (UIImageView*)[[cell contentView]viewWithTag:1];
            vwContainer.layer.cornerRadius = 5.f;
            vwContainer.layer.borderWidth = 1.f;
            vwContainer.backgroundColor = [UIColor whiteColor];
            vwContainer.layer.borderColor = [UIColor getSeperatorColor].CGColor;
            if ([vwContainer viewWithTag:2]) {
                UITextView *txtGameName = (UITextView*)[vwContainer viewWithTag:2];
                if (strStatusMsg.length) {
                    txtGameName.text = strStatusMsg;
                }
                
            }
            
        }
        
    }
    if (indexPath.row == eCellGameRecord) {
        static NSString *CellIdentifier = @"RecordVideo";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([[cell contentView]viewWithTag:1]) {
            UIView *vwContainer = (UIImageView*)[[cell contentView]viewWithTag:1];
            vwContainer.layer.cornerRadius = 17.f;
            vwContainer.layer.borderWidth = 1.f;
            vwContainer.backgroundColor = [UIColor whiteColor];
            vwContainer.layer.borderColor = [UIColor getSeperatorColor].CGColor;
        }
        
    }
    if (indexPath.row == eCellThumb) {
        static NSString *CellIdentifier = @"VideoThumb";
        ThumbCustomCell *_cell = (ThumbCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        _cell.imgThumb.image = thumbImage;
        cell = _cell;
        
    }
    
    if (indexPath.row == eCellInvite) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitedUsers" forIndexPath:indexPath];
        float radius = 25;
        UIView *vwContainer;
        if ([[cell contentView]viewWithTag:1]) {
            vwContainer = (UIImageView*)[[cell contentView]viewWithTag:1];
            vwContainer.layer.borderWidth = 1.f;
            vwContainer.backgroundColor = [UIColor whiteColor];
            vwContainer.layer.borderColor = [UIColor getSeperatorColor].CGColor;
        }
        if (arrInvites.count) radius = 10;
        [self configureCell:cell atIndexPath:indexPath];
        vwContainer.layer.cornerRadius = radius;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    /*

    if (indexPath.row == eCellInvite) {
        static NSString *CellIdentifier = @"InviteOthers";
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([[cell contentView]viewWithTag:1]) {
            UIView *vwContainer = (UIImageView*)[[cell contentView]viewWithTag:1];
            vwContainer.layer.cornerRadius = 25.f;
            vwContainer.layer.borderWidth = 1.f;
            vwContainer.backgroundColor = [UIColor whiteColor];
            vwContainer.layer.borderColor = [UIColor getSeperatorColor].CGColor;
        }

        
    }*/
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
  
}

- (void)configureCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    if (![object isKindOfClass:[AHTagTableViewCell class]]) {
        return;
    }
    AHTagTableViewCell *cell = (AHTagTableViewCell *)object;
    cell.label.tags = arrInvites;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == eCellThumb) {
        if (thumbImage) {
            float width = thumbImage.size.width;
            float height = thumbImage.size.height;
            float ratio = width / height;
            float imageHeight = (self.view.frame.size.width - 50) / ratio;
            return imageHeight + 20;
        }
        return 0;
        
    }
    if (indexPath.row == eCellGameName) {
        return 0;
        
    }
    if (indexPath.row == eCellStatusMsg) {
        return 0;
        
    }
    
    if (indexPath.row ==  eCellGameRecord) {
        if (!thumbImage) {
            return 0;
        }
    }
    
   
    return UITableViewAutomaticDimension;
}


- (nullable UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section{
    
    UIView *vwFooter = [UIView new];
    vwFooter.backgroundColor = [UIColor whiteColor];
    
    UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [vwFooter addSubview:btnSend];
    btnSend.translatesAutoresizingMaskIntoConstraints = NO;
   
    btnSend.layer.borderColor = [UIColor clearColor].CGColor;
    btnSend.titleLabel.font = [UIFont fontWithName:CommonFontBold size:16];
   
    if (!thumbImage) {
        [btnSend setTitle:@"PROCEED TO RECORD" forState:UIControlStateNormal];
        [btnSend addTarget:self action:@selector(recordVideo:)forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btnSend setTitle:@"SUBMIT" forState:UIControlStateNormal];
        [btnSend addTarget:self action:@selector(submitGame)forControlEvents:UIControlEventTouchUpInside];
    }
   
    [btnSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSend setBackgroundColor:[UIColor getThemeColor]];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[btnSend]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnSend)]];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[btnSend]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnSend)]];
    btnSend.layer.borderColor = [[UIColor clearColor] CGColor];
    btnSend.layer.borderWidth = 1.0f;
    btnSend.layer.cornerRadius = 20.0f;
    btnSend.clipsToBounds = YES;
    
    float width = aTableView.frame.size.width - 30;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == eCellThumb) {
        [self playRecordedVideo:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 70;
}
-(IBAction)changeGameType:(UIButton*)sender{
    
    gameType = eGameTypeNone;
    if (sender.tag == 3) {
        gameType = eGameTypePig;
    }
    else if (sender.tag == 2) {
        gameType = eGameTypeHorse;
    }
    [tableView reloadData];
    if (arrInvites.count <= 0) {
         [self showInviteOthersPage];
    }
   
    
}


#pragma mark - UITextField delegate methods


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([textField.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromNameField:textField];
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [textField setInputAccessoryView:inputAccView];
    NSIndexPath *indexPath;
    if ([textField.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
    
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
}

#pragma mark - UITextView delegate methods


-(void)textViewDidEndEditing:(UITextView *)textField
{
    [textField resignFirstResponder];
    
    if ([textField.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}


-(BOOL)textViewShouldEndEditing:(UITextView *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getStatusMsgFromNameField:textField];
    }
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textField {
    
    [textField setInputAccessoryView:inputAccView];
    NSIndexPath *indexPath;
    if ([textField.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
    
    return YES;
    
}

-(void)textViewDidBeginEditing:(UITextView *)textField {
    
    CGPoint pointInTable = [textField.superview.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
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

-(void)getTextFromNameField:(UITextField*)textView{
    
    strGameID = textView.text;
    [tableView reloadData];
}

-(void)getStatusMsgFromNameField:(UITextView*)textView{
    
    strStatusMsg = textView.text;
    [tableView reloadData];
}

#pragma mark - Search Invites

-(void)showInviteOthersPage{
    
    InviteOthersViewController *inviteOthers = [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForInviteOthers];
    NSMutableArray *arrIDS = [NSMutableArray new];
    for (AHTag *tag in arrInvites) {
        [arrIDS addObject:tag.userID];
    }
    inviteOthers.delegate = self;
    inviteOthers.selectedUsers = arrIDS;
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController  presentViewController:inviteOthers animated:YES completion:nil];
    
}

-(void)userInvitedWithList:(NSMutableArray*)users{
    
    arrInvites = [NSMutableArray new];
    for (NSDictionary *dict in users) {
        AHTag *tag = [AHTag new];
        tag.title = [dict objectForKey:@"name"];
        tag.userID = [dict objectForKey:@"user_id"];
        [arrInvites addObject:tag];
    }
    [tableView reloadData];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:5 inSection:0];
    [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
    if (!thumbImage) {
        [self performSelector:@selector(recordVideo:) withObject:nil afterDelay:0.1];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSMutableArray *arrIDS = [NSMutableArray new];
    for (AHTag *tag in arrInvites) {
        [arrIDS addObject:tag.userID];
    }
    InviteOthersViewController *vc = segue.destinationViewController;
    vc.delegate = self;
    vc.selectedUsers = arrIDS;
}


#pragma mark - Video Record

-(IBAction)recordVideo:(id)sender{
    
    CameraViewcontroller *recordView = [[CameraViewcontroller alloc] initWithNibName:nil bundle:nil];
    recordView.timeLength = 15;
    recordView.delegate = self;
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController  presentViewController:recordView animated:YES completion:nil];

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
                                    NSIndexPath* ip = [NSIndexPath indexPathForRow:5 inSection:0];
                                    [tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
                
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
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [delegate.window.rootViewController  presentViewController:playerViewController animated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[playerViewController.player currentItem]];
    }
    
    
}


- (void)videoDidFinish:(id)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
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
    }
    
}


#pragma mark - Submit Methods

-(void)submitGame{
    BOOL isValid = true;
    NSString *alertMsg;
    if (arrInvites.count <= 0) {
        isValid = false;
        alertMsg = @"Invite others to play";
    }
    if (gameType == eGameTypeNone) {
        isValid = false;
        alertMsg = @"Choose game type";
    }
    if (isValid) {
        [self uploadMediaOnsuccess:^(NSDictionary *responds) {
            
            if ([responds objectForKey:@"data"]) {
                NSDictionary *data = [responds objectForKey:@"data"];
                NSMutableArray *invites = [NSMutableArray new];
                for (AHTag *tag in arrInvites) {
                    [invites addObject:tag.userID];
                }
                [APIMapper createGameWithGameID:strGameID gameType:[NSString stringWithFormat:@"%ld",(long)gameType] mediaFileName:[data objectForKey:@"media_file"] thumbFileName:[data objectForKey:@"thumb_file"] invites:invites statusMsg:strStatusMsg OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [Utility hideLoadingScreenFromView:self.view];
                    if ([responseObject objectForKey:@"text"]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CREATE GAME"
                                                                        message:[responseObject objectForKey:@"text"]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        [self removeAllContentsInMediaFolder];
                        [self goBack:nil];
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
            
        } failure:^{
            
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CREATE GAME"
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
}

-(void)uploadMediaOnsuccess:(void (^)(NSDictionary *responds ))success failure:(void (^)())failure{
    
    if (recordedVideoURL && thumbImage && arrInvites.count) {
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
    }else{
        
        NSString *title = @"Please Record video";
        if (!recordedVideoURL) {
            title = @"Please Record video";
        }else if (arrInvites.count <= 0){
            title = @"Invite others to play";
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Create Game"
                                                                       message:title
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              }];
        
        [alert addAction:firstAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

#pragma mark -Generic Methods

-(void)showSummaryPage{
    
  

}


-(IBAction)goBack:(id)sender{
    
    [[self delegate]closeCreateGamePopUp];
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
