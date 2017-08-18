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

#import "SharedVideosViewController.h"
#import "Constants.h"
#import "SharedVideoCell.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EMEmojiableBtn.h"
#import "ProfileViewController.h"

@interface SharedVideosViewController () <EMEmojiableBtnDelegate>{
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
}

@end

@implementation SharedVideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllFriendRequetsWithPage:currentPage isPagination:NO];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    currentPage = 1;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 450;
    
    tableView.hidden = true;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    
    arrDataSource = [NSMutableArray new];
}
-(void)getAllFriendRequetsWithPage:(NSInteger)pageNumber isPagination:(BOOL)isPagination{
    
    if (!isPagination) {
        [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    }
    
    [APIMapper getAllSharedVideosWithPageNumber:pageNumber OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = false;
        [self showAllRequestsWithJSON:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
         tableView.hidden = false;
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
    
    isDataAvailable = false;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"videos"]))
        [arrDataSource addObjectsFromArray:[[responds objectForKey:@"data"] objectForKey:@"videos"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
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
    if (!isDataAvailable) {
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strAPIErrorMsg];
        return cell;
    }
    static NSString *CellIdentifier = @"SharedVideoCell";
    SharedVideoCell *cell = (SharedVideoCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.btnVideo.tag = indexPath.row;
    cell.btnDelete.tag = indexPath.row;
    cell.btnDelete.hidden = true;
    cell.btnProfile.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < arrDataSource.count) {
        NSDictionary *details = arrDataSource[indexPath.row];
        cell.lblName.text = [details objectForKey:@"name"];
        
         if (NULL_TO_NIL([details objectForKey:@"location"]) ){
             NSMutableAttributedString *myString = [NSMutableAttributedString new];
             NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
             UIImage *icon = [UIImage imageNamed:@"Loc_Small"];
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
                UIImage *icon = [UIImage imageNamed:@"contact_icon"];
                attachment.image = icon;
                attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblFriends.font.descender + 2), icon.size.width, icon.size.height);
                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
                [myString appendAttributedString:attachmentString];
                NSAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[details objectForKey:@"tagged_users"]]];
                [myString appendAttributedString:myText];
                cell.lblFriends.attributedText = myString;
            }
            
        }
        if ([[details objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId])cell.btnDelete.hidden = false;
        cell.lblTime.text = [Utility getDateDescriptionForChat:[[details objectForKey:@"shared_datetime"] doubleValue]];
        cell.lblDescription.text = [details objectForKey:@"share_msg"];
        float width = [[details objectForKey:@"width"] integerValue];
        float height = [[details objectForKey:@"height"] integerValue];;
        float ratio = width / height;
        float imageHeight = (self.view.frame.size.width - 30) / ratio;
        //cell.constraintForHeight.constant = imageHeight;
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[details objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"NoImage"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        [cell.imgThumb sd_setImageWithURL:[NSURL URLWithString:[details objectForKey:@"imageurl"]]
                        placeholderImage:[UIImage imageNamed:@"NoImage"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        cell.btnEmoji.delegate = self;
        cell.btnEmoji.dataset = @[
                                  [[EMEmojiableOption alloc] initWithImage:@"Sad" withName:@" Sad"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Wow" withName:@" Wow"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Haha" withName:@" Haha"],
                                  [[EMEmojiableOption alloc] initWithImage:@"Angry" withName:@" Angry"],
                                  ];
        [cell.btnEmoji setImage:[UIImage imageNamed:@"Like_Inactive"] forState:UIControlStateNormal];
        [cell.btnEmoji setTitle:@"Like" forState:UIControlStateNormal];
        if ([[details objectForKey:@"emoji_code"] integerValue] >= 0) {
            if ([[details objectForKey:@"emoji_code"] integerValue] == 4) {
                [cell.btnEmoji setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];
                 [cell.btnEmoji setTitle:@"Like" forState:UIControlStateNormal];
            }else{
                EMEmojiableOption *option = [ cell.btnEmoji.dataset objectAtIndex:[[details objectForKey:@"emoji_code"] integerValue]];
                [cell.btnEmoji setImage: [UIImage imageNamed:option.imageName] forState:UIControlStateNormal];
                [cell.btnEmoji setTitle:option.name forState:UIControlStateNormal];
            }
        }
        cell.btnEmoji.vwBtnSuperView = self.view;
        cell.btnEmoji.tag = indexPath.row;
        [cell.btnEmoji privateInit];
    }
   
    return cell;

    
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

-(IBAction)showUserProfileWithIndex:(UIButton*)sender{
    if (sender.tag < arrDataSource.count) {
        NSDictionary *user = arrDataSource[sender.tag];
        ProfileViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GeneralStoryBoard Identifier:StoryBoardIdentifierForProfile];
        [[self navigationController]pushViewController:games animated:YES];
        games.strUserID = [user objectForKey:@"user_id"];
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
        [arrDataSource removeAllObjects];
        [tableView reloadData];
        
    }
    
}

-(IBAction)deleteSharedVideo:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        
        NSDictionary *details = arrDataSource[sender.tag];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete"
                                                                       message:@"Do you really want to delete the post?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"DELETE"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  if ([details objectForKey:@"video_id"]) {
                                                                       [Utility showLoadingScreenOnView:self.view withTitle:@"Deleting.."];
                                                                      [APIMapper deleteSharedVideoWithVideoID:[details objectForKey:@"video_id"] OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          
                                                                          [arrDataSource removeObjectAtIndex:sender.tag];
                                                                          [tableView reloadData];
                                                                           [Utility hideLoadingScreenFromView:self.view];
                                                                          
                                                                      } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                                                          
                                                                           [Utility hideLoadingScreenFromView:self.view];
                                                                      }];
                                                                  }
                                                                  
                                                              }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"CANCEL"
                                                              style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                              }];
        
        [alert addAction:firstAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];

      
    }

}

-(IBAction)playVideo:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        
        NSDictionary *details = arrDataSource[sender.tag];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:[NSURL URLWithString:[details objectForKey:@"videourl"]]];
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

#pragma mark - Emoji Methods

-(IBAction)likeVideo:(EMEmojiableBtn *)sender{
    
    if (sender.tag < arrDataSource.count) {
        
        NSDictionary *details = arrDataSource[sender.tag];
        [self updateDetailsWithEmojiIndex:4 position:sender.tag];
        [APIMapper likeVideoWithVideoID:[details objectForKey:@"video_id"] type:@"share" emojiCode:4 OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
        }];
    }
    
}

- (void)EMEmojiableBtn:( EMEmojiableBtn* _Nonnull)button selectedOption:(NSUInteger)index{
    
    EMEmojiableOption *option = [button.dataset objectAtIndex:index];
    [button setImage: [UIImage imageNamed:option.imageName] forState:UIControlStateNormal];
    [button setTitle:option.name forState:UIControlStateNormal];
    if (button.tag < arrDataSource.count) {
        
        [self updateDetailsWithEmojiIndex:index position:button.tag];
        NSDictionary *details = arrDataSource[button.tag];
        [APIMapper likeVideoWithVideoID:[details objectForKey:@"video_id"] type:@"share" emojiCode:index OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
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
            [details setObject:[NSNumber numberWithInteger:emojiCode] forKey:@"emoji_code"];
            [arrDataSource replaceObjectAtIndex:position withObject:details];
            [tableView reloadData];
        }
    });
    
    
   
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
