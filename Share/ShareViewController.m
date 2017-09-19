//
//  ShareViewController.m
//  Share
//
//  Created by Purpose Code on 29/08/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

typedef enum{
    
    eCellUserInfo    = 0,
    eCellDescription  = 1,
    eCellVideo      = 2,
    eCellLocation = 3,
    eCellFriends = 4,
    
    
}eMenuType;

#import "PrefixHeader.pch"
#import "ShareViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"
#import "SDAVAssetExportSession.h"
#import "Constants.h"
#import "ShareUserCell.h"
#import "MediaCell.h"
#import "InviteOthersViewController.h"
#import "AHTag.h"
#import <GooglePlaces/GooglePlaces.h>
#import "AHTagTableViewCell.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PhotoBrowser.h"

@interface ShareViewController ()<InviteUserDeleagte,GMSAutocompleteViewControllerDelegate,PhotoBrowserDelegate>{
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView *tableView;
    NSMutableArray *arrDataSource;
    NSMutableArray *arrInvites;
    NSMutableString *strFriends;
    NSMutableString *strMessage;
    NSMutableString *strAddress;
    UIView *inputAccView;
    NSString *txtToBeShared;
    
    UILabel *lblPlaceHolder;
    PhotoBrowser *photoBrowser;
    NSMutableArray *arrMediaURLs;
    
    NSMutableArray *arrThumbNames;
    NSMutableArray *arrMediaNames;
}

@end

@import GoogleMaps;
@import GooglePlacePicker;

@implementation ShareViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self showLoadingScreen];
    [self removeAllContentsInMediaFolder];
    [self setUpGoogleMapConfiguration];
    [self setUp];
    [self didSelectPost];
    [self createInputAccessoryView];
        
    
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    arrThumbNames = [NSMutableArray new];
    arrMediaNames = [NSMutableArray new];
    
    arrDataSource = [NSMutableArray new];
    arrMediaURLs = [NSMutableArray new];
    
    float width = 720;
    float height = 460;
    float ratio = width / height;
    float imageHeight = (self.view.frame.size.width) / ratio;
    constraintForNavBg.constant = imageHeight;
    
    strMessage = [NSMutableString new];
    strAddress = [NSMutableString new];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 450;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.clipsToBounds = YES;
    tableView.layer.cornerRadius = 5.f;
    tableView.layer.borderWidth = 1.f;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.layer.borderColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
}


-(void)createInputAccessoryView{
    
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(inputAccView.frame.size.width - 85, 1.0f, 85.0f, 38.0f)];
    [btnDone setTitle:@"DONE" forState:UIControlStateNormal];
    [btnDone setBackgroundColor:[UIColor colorWithRed:1.00 green:0.51 blue:0.16 alpha:1.0]];
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

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    return 3;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    if (section == 1) {
        return arrDataSource.count;
    }else{
       
        return 2;
    }
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case eCellUserInfo:
                cell = [self congigureUserInfoCell];
                break;
                
            case eCellDescription:
                cell = [self congigureDescriptionCell];
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section == 1) {
        
        cell = [self congigureMediaCellWithIndex:indexPath];
    }
    else{
        
        switch (indexPath.row) {
            case 0:
                cell = [self congigureLocationCell];
                break;
                
            case 1:
                cell = [self congigureFriendsCellForIndexPath:indexPath];
                break;
                
            default:
                break;
        }

    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
    
}



- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self showLocationPikcer];
        }
    }
    if (indexPath.section == 1) {
        NSMutableArray *images = [NSMutableArray new];
        NSString *mediaType ;
            if (indexPath.row < arrDataSource.count) {
                
                NSURL *fileURL = [NSURL fileURLWithPath:arrDataSource[indexPath.row]];
                NSString *fileExtension = [fileURL pathExtension];
                NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
                NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
                if ([contentType hasPrefix:@"image"]){
                    [images addObject:fileURL];
                }else if ([contentType hasPrefix:@"video"]){
                    NSError* error;
                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
                    [[AVAudioSession sharedInstance] setActive:NO error:&error];
                    NSURL  *videourl = fileURL;
                    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
                    playerViewController.player = [AVPlayer playerWithURL:videourl];
                    [playerViewController.player play];
                    [self presentViewController:playerViewController animated:YES completion:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(videoDidFinish:)
                                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                                               object:[playerViewController.player currentItem]];
                }
                
            }
            if (images.count) {
                for (id details in arrDataSource) {
                    if ([details isKindOfClass:[NSDictionary class]]) {
                        mediaType = [details objectForKey:@"media_type"];
                        if ([mediaType isEqualToString:@"image"]) {
                            NSURL *url =  [NSURL URLWithString:[details objectForKey:@"gem_media"]];
                            if (![images containsObject:url]) {
                                [images addObject:url];
                            }
                        }
                    }else{
                        NSString *filePath = (NSString*)details;
                        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                        NSString *fileExtension = [fileURL pathExtension];
                        NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
                        NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
                        if ([contentType hasPrefix:@"image"]){
                            if (![images containsObject:fileURL]) {
                                [images addObject:fileURL];
                            }
                        }
                    }
                    
                }
        }
        if (images.count) {
            [self presentGalleryWithImages:images];
        }
    }
    

    
    
}


-(ShareUserCell*)congigureUserInfoCell{
    
    static NSString *CellIdentifier = @"ShareUserCell";
    ShareUserCell *cell = (ShareUserCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.purposecodes.sportsapp"];
    cell.lblName.text =   [sharedDefaults objectForKey:@"name"];
    [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[sharedDefaults objectForKey:@"profileurl"]]
                    placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                               
                               
                               
                           }];

    
    return cell;
}
-(UITableViewCell*)congigureDescriptionCell{
    
    static NSString *CellIdentifier = @"DescriptionCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([[cell contentView] viewWithTag:1]) {
        UITextView *txtView = (UITextView*)[[cell contentView] viewWithTag:1];
        txtView.text = strMessage;
    }
    if ([[cell contentView] viewWithTag:2]) {
        lblPlaceHolder = (UILabel*)[[cell contentView] viewWithTag:2];
        
    }
    lblPlaceHolder.hidden = false;
    if (strMessage.length > 0) {
        lblPlaceHolder.hidden = true;
    }
    
    return cell;
}
-(MediaCell*)congigureMediaCellWithIndex:(NSIndexPath*)indexPath{
    
    static NSString *CellIdentifier = @"MediaCell";
    MediaCell *cell = (MediaCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.imgMediaThumbnail.image = [UIImage imageNamed:@"NoImage.png"];
    cell.btnDelete.tag = indexPath.row;
    [[cell videoPlay]setHidden:true];
    if (indexPath.row < arrDataSource.count) {
        NSURL *fileURL = [NSURL fileURLWithPath:arrDataSource[indexPath.row]];
        
        if ([[fileURL pathExtension] isEqualToString:@"jpeg"]) {
            cell.lblTitle.text = [fileURL lastPathComponent];
            [cell.indicator startAnimating];
            [cell.imgMediaThumbnail sd_setImageWithURL:fileURL
                                      placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                 [cell.indicator stopAnimating];
                                             }];
            
        }
        else if ([[fileURL pathExtension] isEqualToString:@"mp4"]) {
            [[cell videoPlay]setHidden:false];
            cell.lblTitle.text = [fileURL lastPathComponent];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                UIImage *thumbnail = [self getThumbNailFromVideoURL:fileURL];
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    cell.imgMediaThumbnail.image = thumbnail;
                    [cell.indicator stopAnimating];
                });
                
            });
            
            
            
        }
        else {
            [[cell videoPlay]setHidden:false];
            cell.lblTitle.text = [fileURL lastPathComponent];
            cell.imgMediaThumbnail.image = [UIImage imageNamed:@"NoImage"];
            [cell.indicator stopAnimating];
            
        }
        
    }
    
    
//    NSArray *videos = [arrDataSource objectForKey:@"video"];
//    if (videos.count) {
//        NSDictionary *video = [videos lastObject];
//        float width = [[video objectForKey:@"width"] integerValue];
//        float height = [[video objectForKey:@"height"] integerValue];;
//        float ratio = width / height;
//        float imageHeight = (self.view.frame.size.width - 30) / ratio;
//        cell.constraintForHeight.constant = imageHeight;
//        [cell.imgThumb sd_setImageWithURL:[NSURL URLWithString:[video objectForKey:@"imageurl"]]
//                         placeholderImage:[UIImage imageNamed:@"NoImage"]
//                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                    
//                                }];
//    }
    return cell;
}

-(UITableViewCell*)congigureLocationCell{
    
    static NSString *CellIdentifier = @"LocationCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([cell.contentView viewWithTag:1]) {
        UILabel *lblLoc = (UILabel*)[cell.contentView viewWithTag:1];
        lblLoc.text = @"Add Location";
        if (strAddress.length)lblLoc.text = strAddress;
    }
    return cell;
}

-(UITableViewCell*)congigureFriendsCellForIndexPath:(NSIndexPath*)indexPath{
    
    if (arrInvites.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaggedFriends" forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        static NSString *CellIdentifier = @"FriendsCell";
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        return cell;
    }
    
    
}

- (void)configureCell:(id)object atIndexPath:(NSIndexPath *)indexPath {
    if (![object isKindOfClass:[AHTagTableViewCell class]]) {
        return;
    }
    AHTagTableViewCell *cell = (AHTagTableViewCell *)object;
    cell.label.tags = arrInvites;
}

#pragma mark - UITextView delegate methods


-(void)textViewDidEndEditing:(UITextView *)textField
{
    [textField resignFirstResponder];
    
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}


-(BOOL)textViewShouldEndEditing:(UITextView *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromStatusField:textField];
    }
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textField {
    
    [textField setInputAccessoryView:inputAccView];
    NSIndexPath *indexPath;
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    lblPlaceHolder.hidden = true;
    
    return YES;
    
}

-(void)textViewDidBeginEditing:(UITextView *)textField {
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
}

-(void) textViewDidChange:(UITextView *)textView
{
    lblPlaceHolder.hidden = true;
    if(textView.text.length == 0){
        lblPlaceHolder.hidden = false;
    }
}

-(void)getTextFromStatusField:(UITextView*)textView{
    
    [strMessage appendString:textView.text];
    [tableView reloadData];
}
#pragma mark - Search Invites


-(void)userInvitedWithList:(NSMutableArray*)users{
    
    arrInvites = [NSMutableArray new];
    NSMutableArray *names = [NSMutableArray new];
    for (NSDictionary *dict in users) {
        AHTag *tag = [AHTag new];
        tag.title = [dict objectForKey:@"name"];
        tag.userID = [dict objectForKey:@"user_id"];
        [arrInvites addObject:tag];
        [names addObject:[dict objectForKey:@"name"]];
    }
    strFriends = [NSMutableString stringWithString:[names componentsJoinedByString:@","]];
    [tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSMutableArray *arrIDS = [NSMutableArray new];
    for (AHTag *tag in arrInvites) {
        [arrIDS addObject:tag.userID];
    }
    InviteOthersViewController *vc = segue.destinationViewController;
    vc.isFromTagFriends = YES;
    vc.delegate = self;
    vc.selectedUsers = arrIDS;
}



#pragma mark - Location Picker

-(IBAction)showLocationPikcer{
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [self.view endEditing:YES];
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    acController.autocompleteFilter.type = kGMSPlacesAutocompleteTypeFilterCity;
    [self presentViewController:acController animated:YES completion:nil];
}

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    [strAddress setString:@""];
    [strAddress appendString:place.name];
    [tableView reloadData];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
}

#pragma mark - Photo Browser & Deleagtes

- (void)presentGalleryWithImages:(NSArray*)images
{
    [self.view endEditing:YES];
    if (!photoBrowser) {
        photoBrowser = [[[NSBundle mainBundle] loadNibNamed:@"PhotoBrowser" owner:self options:nil] objectAtIndex:0];
        photoBrowser.delegate = self;
    }
    UIView *vwPopUP = photoBrowser;
    [self.view addSubview:vwPopUP];
    vwPopUP.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    
    vwPopUP.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwPopUP.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [photoBrowser setUpWithImages:images];
    }];
    
}

-(void)closePhotoBrowserView{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        photoBrowser.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [photoBrowser removeFromSuperview];
        photoBrowser = nil;
    }];
}


#pragma mark - Did Selected Post


- (void)didSelectPost
{
    [arrMediaURLs removeAllObjects];
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
    //NSLog(@"info %@",inputItem.userInfo);
    NSArray *arrAttachments = [inputItem.userInfo valueForKey:NSExtensionItemAttachmentsKey];
    
    for ( NSItemProvider *itemProvider in arrAttachments) {
        
        if ([itemProvider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypePlainText]) {
            
            [itemProvider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypePlainText options:nil completionHandler:^(NSString *plain, NSError *error) {
                txtToBeShared = plain;
                [strMessage appendString:plain];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView reloadData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideLoadingScreen];
                        
                    });
                    
                });
            }];
        }
        
        else if ([itemProvider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeURL]){
            
            [itemProvider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error)
             {
                 //[arrDataSource addObject:url];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (url) {
                         [self writeMediaToFolderWithFromPath:url];
                     }else{
                         [self hideLoadingScreen];
                     }
                     
                 });
             }];
            
        }else if ([itemProvider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeImage]){
            
            [itemProvider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeImage
                                            options:nil
                                  completionHandler:^(NSURL *url, NSError *error) {
                                      if (url) {
                                          [self writeMediaToFolderWithFromPath:url];
                                      }else{
                                          [self hideLoadingScreen];
                                      }
                                      
                                      
                                      
                                  }];
        }
        else if ([itemProvider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeVideo]){
            
            [itemProvider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeVideo
                                            options:nil
                                  completionHandler:^(NSURL *url, NSError *error) {
                                      
                                      if (url) {
                                          [self writeMediaToFolderWithFromPath:url];
                                      }else{
                                          [self hideLoadingScreen];
                                      }
                                      
                                      
                                      
                                  }];
        }
        else if ([itemProvider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeQuickTimeMovie]){
            
            [itemProvider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeQuickTimeMovie
                                            options:nil
                                  completionHandler:^(NSURL *url, NSError *error) {
                                      
                                      if (url) {
                                          [self writeMediaToFolderWithFromPath:url];
                                      }else{
                                          [self hideLoadingScreen];
                                      }
                                      
                                  }];
        }
        
    }
    
}

-(void)writeMediaToFolderWithFromPath:(NSURL*)_urlPath{
    
    [arrMediaURLs addObject:_urlPath];
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
    NSArray *arrAttachments = [inputItem.userInfo valueForKey:NSExtensionItemAttachmentsKey];
    if (arrAttachments.count == arrMediaURLs.count) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideLoadingScreen];
            [self showLoadingScreen];
            
            for (NSURL *urlPath in arrMediaURLs) {
                NSString *fileExtension = [urlPath pathExtension];
                NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
                NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
                
                if ([contentType hasPrefix:@"image"]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                        UIImage *im = [UIImage imageWithData: [NSData dataWithContentsOfURL:urlPath]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                             [self saveSelectedImageFileToFolderWithImage:im shouldReload:YES];
                        });
                    });
                }
                else if ([contentType hasPrefix:@"video"]) {
                    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
                    NSString *uniqueFileName = [NSString stringWithFormat:@"%@", guid];
                    NSString *outputFile = [NSString stringWithFormat:@"%@/%@.mp4",[self getMediaSaveFolderPath],uniqueFileName];
                    [self compressVideoWithURL:urlPath outputURL:[NSURL fileURLWithPath:outputFile] onComplete:^(bool completed) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self loadAllMedias];
                            
                        });
                    }];
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self loadAllMedias];
                        
                    });
                }

            }
            
            
            
        });
        
    }
  
    
}


-(void)saveSelectedImageFileToFolderWithImage:(UIImage*)_image shouldReload:(BOOL)shouldReload{
    
    UIImage *image = [[self class] fixrotation:_image];
    NSData *pngData = UIImageJPEGRepresentation(image, 0.1f);
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@", guid];
    NSString *outputFile = [NSString stringWithFormat:@"%@/%@.jpeg",[self getMediaSaveFolderPath],uniqueFileName];
    [pngData writeToFile:outputFile atomically:YES];
    if (shouldReload) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadAllMedias];
            
        });
    }
    
}

-(NSString*)getMediaSaveFolderPath{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/Share"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    return dataPath;
    
}

-(void)writeAudioFileToGalleryFromURL:(NSURL*)sourceURL{
    
    NSData *audio = [NSData dataWithContentsOfURL:sourceURL];
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *outputFile = [NSString stringWithFormat:@"%@/%@.%@",[self getMediaSaveFolderPath],guid,[sourceURL pathExtension]];
    if ([audio writeToFile:outputFile atomically:YES]) {
        // yeah - file written
    } else {
        // oops - file not written
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadAllMedias];
    });
    
}

-(void)loadAllMedias{
    
    [arrDataSource removeAllObjects];
    
    NSString *dataPath = [self getMediaSaveFolderPath];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:NULL];
    NSError* error = nil;
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[directoryContent count]];
    for(NSString* file in directoryContent) {
        
        if (![file isEqualToString:@".DS_Store"]) {
            NSString* filePath = [dataPath stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:filePath
                                        error:&error];
            NSDate* modDate = [properties objectForKey:NSFileCreationDate];
            
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           file, @"path",
                                           modDate, @"lastModDate",
                                           nil]];
            
        }
    }
    // sort using a block
    // order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {
                                // compare
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                           [path2 objectForKey:@"lastModDate"]];
                                // invert ordering
                                if (comp == NSOrderedDescending) {
                                    comp = NSOrderedAscending;
                                }
                                else if(comp == NSOrderedAscending){
                                    comp = NSOrderedDescending;
                                }
                                return comp;
                            }];
    
    for (NSInteger i = sortedFiles.count - 1; i >= 0; i --) {
        NSDictionary *dict = sortedFiles[i];
        NSString *outputFile = [NSString stringWithFormat:@"%@/%@",[self getMediaSaveFolderPath],[dict objectForKey:@"path"]];
        [arrDataSource insertObject:outputFile atIndex:0];
    }
    [tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoadingScreen];
        
    });
}

-(void)removeAllContentsInMediaFolder{
    
    NSString *dataPath = [self getMediaSaveFolderPath];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:dataPath error:&error];
    if (success){
        
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    
}

-(void)compressVideoWithURL:(NSURL*)videoURL outputURL:(NSURL*)outputURL onComplete:(void (^)(bool completed))completed{
    
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:[AVAsset assetWithURL:videoURL]];
    NSURL *url = outputURL;
    encoder.outputURL = url;
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
     }];
}

#pragma mark - Submit Post Methods

-(IBAction)submit:(id)sender{
    [arrThumbNames removeAllObjects];
    [arrMediaNames removeAllObjects];
    NSInteger index = 0;
    if (arrDataSource.count || strMessage.length) {
        [self showLoadingScreen];
        [self uploadMediaByIndex:index];
    }
    
}

-(void)uploadMediaByIndex:(NSInteger)index{
    
    if (index < arrDataSource.count) {
        NSString *strURL = arrDataSource[index];
        [self uploadMediasToCommunityByStrURL:strURL Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"res %@",responseObject);
            if ([[responseObject objectForKey:@"data"] objectForKey:@"media_file"]) {
                [arrMediaNames addObject:[[responseObject objectForKey:@"data"] objectForKey:@"media_file"]];
            }
            NSString *strThumb;
            if (NULL_TO_NIL([[responseObject objectForKey:@"data"] objectForKey:@"thumb_file"])) {
                strThumb = [[responseObject objectForKey:@"data"] objectForKey:@"thumb_file"];
            }
            if (strThumb.length) {
                [arrThumbNames addObject:strThumb];

            }else{
                [arrThumbNames addObject:@""];
            }
            NSInteger nextIndex = index + 1;
            [self uploadMediaByIndex:nextIndex];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            [self hideLoadingScreen];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"ERROR"
                                          message:error.localizedDescription
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
        
    }else{
        
        NSMutableArray *invites = [NSMutableArray new];
        for (AHTag *tag in arrInvites) {
            [invites addObject:tag.userID];
        }
        
        [self shareToCommunityWithThumbs:arrThumbNames mediaNames:arrMediaNames location:strAddress address:strAddress message:strMessage frieds:invites success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"COMMUNITY"
                                          message:[responseObject objectForKey:@"text"]
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                       [self goBack:nil];
                                     
                                 }];
            
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];

            
            
          
            [self hideLoadingScreen];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            [self hideLoadingScreen];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"COMMUNITY"
                                          message:error.localizedDescription
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

}

- (void)shareToCommunityWithThumbs:(NSMutableArray*)_arrThumbNames mediaNames:(NSMutableArray*)_arrMediaNames location:(NSString*)location address:(NSString*)strAddress message:(NSString*)message frieds:(NSArray*)friends success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@community",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.purposecodes.sportsapp"];
    [manager.requestSerializer setValue:[sharedDefaults objectForKey:@"TOKEN"] forHTTPHeaderField:@"Authorization"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (_arrThumbNames.count)[params setObject:_arrThumbNames forKey:@"thumb_file"];
    if (_arrMediaNames.count)[params setObject:_arrMediaNames forKey:@"media_file"];
    if (location.length)[params setObject:location forKey:@"location_name"];
    if (message.length)[params setObject:message forKey:@"share_msg"];
    if (friends.count)[params setObject:friends forKey:@"tagged_user"];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}


- (void)uploadMediasToCommunityByStrURL:(NSString*)_fileURL Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@iosmediaupload",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.purposecodes.sportsapp"];
    [manager.requestSerializer setValue:[sharedDefaults objectForKey:@"TOKEN"] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *params = @{@"type": @"community"};
    [manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSURL *fileURL = [NSURL fileURLWithPath:_fileURL];
        NSString *fileExtension = [fileURL pathExtension];
        NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
        NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
        if ([contentType hasPrefix:@"image"]){
            
            NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:_fileURL];
            [formData appendPartWithFileData:imageData name:@"media_file" fileName:@"Media" mimeType:@"image/jpeg"];
            
        }else if ([contentType hasPrefix:@"video"]){
            
            UIImage *thumbnail = [self getThumbNailFromVideoURL:fileURL];
            NSData *imageData = UIImageJPEGRepresentation(thumbnail,0.1);
            [formData appendPartWithFileData:imageData name:@"share_thumb_file" fileName:@"Media" mimeType:@"image/jpeg"];
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:[fileURL path]];
            [formData appendPartWithFileData:data name:@"media_file" fileName:@"Media" mimeType:@"video/mp4"];
        }

   
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
        
    }];
    
    
}


#pragma mark - Generic Methods

- (void)videoDidFinish:(id)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //fade out / remove subview
}

-(IBAction)deleteSelectedMedia:(UIButton*)btnDelete{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Delete"
                                  message:@"Delete the selected media ?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             if (btnDelete.tag < arrDataSource.count) {
                                 id object = arrDataSource[btnDelete.tag];
                                 if ([object isKindOfClass:[NSString class]]) {
                                     NSString *fileName = arrDataSource[btnDelete.tag];
                                     [self removeAMediaFileWithName:fileName];
                                 }
                                 
                             }
                             
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

- (void)removeAMediaFileWithName:(NSString *)filePath{
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success){}
    else NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    [self loadAllMedias];
}

-(UIImage*)getThumbNailFromVideoURL:(NSURL*)videoURL{
    
    NSURL *url = videoURL;
    AVAsset *asset = [AVAsset assetWithURL:url];
    //  Get thumbnail at the very start of the video
    CMTime thumbnailTime = [asset duration];
    thumbnailTime.value = 0;
    //  Get image from the video at the given time
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = true;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return thumbnail;
}


+ (UIImage *)fixrotation:(UIImage *)image{
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

-(void)setUpGoogleMapConfiguration{
    
    [GMSServices provideAPIKey:GoogleMapAPIKey];
    [GMSPlacesClient provideAPIKey:GoogleMapAPIKey];
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
    
    [self.extensionContext completeRequestReturningItems:@[]  completionHandler:nil];
}


@end
