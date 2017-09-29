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
#import "CommentComposeViewController.h"
#import "CommunityGalleryViewController.h"
#import "NotificationsViewController.h"
#import "SearchFriendsViewController.h"
#import "FriendRequestsViewController.h"

@interface SharedVideosViewController () <EMEmojiableBtnDelegate,CommentPopUpDelegate,CommunityGalleryPopUpDelegate>{
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
    CommentComposeViewController *comments;
    CommunityGalleryViewController *galleryView;
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
    if (indexPath.row < arrDataSource.count) {
        NSDictionary *details = arrDataSource[indexPath.row];
        cell.lblName.text = [details objectForKey:@"name"];
        cell.lblLoc.text = @"";
        cell.lblFriends.text = @"";
        
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
        cell.trailingToChat.priority = 998;
        cell.trailingToSuperView.priority = 999;
        if ([[details objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId]){
            cell.btnDelete.hidden = false;
            cell.trailingToChat.priority = 999;
            cell.trailingToSuperView.priority = 998;
        }
        
        [cell.lblCommenCount setText:[NSString stringWithFormat:@"%d Comments",[[details objectForKey:@"comment_total"] integerValue]]];
        cell.lblTime.text = [Utility getDateDescriptionForChat:[[details objectForKey:@"shared_datetime"] doubleValue]];
        NSString *msg = [details objectForKey:@"share_msg"];
        cell.lblDescription.text = @"";
        cell.desrptionTopToView.constant = 0;
        cell.desrptionTopToImage.constant = 0;
        if (msg.length) {
            cell.lblDescription.text = [details objectForKey:@"share_msg"];
            cell.desrptionTopToView.constant = 15;
            cell.desrptionTopToImage.constant = 15;
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
            float imageHeight = (self.view.frame.size.width - 30) / ratio;
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

#pragma mark - Emoji Methods

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
