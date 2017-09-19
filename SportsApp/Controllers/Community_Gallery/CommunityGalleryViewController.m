//
//  ChatComposeViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kSectionCount               1
#define kMinimumCellCount           1



#import "CommunityGalleryViewController.h"
#import "Constants.h"
#import "CommunityGalleryCell.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CommunityGalleryViewController (){
    
     IBOutlet UIView *vwBG;
    IBOutlet UITableView *tableView;
    
}

@end

@implementation CommunityGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 450;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    vwBG.layer.cornerRadius = 5.f;
    vwBG.layer.borderWidth = 1.f;
    vwBG.backgroundColor = [UIColor whiteColor];
    vwBG.layer.borderColor = [UIColor clearColor].CGColor;
    
}


#pragma mark - UITableViewDataSource Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return _gallery.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommunityGalleryCell *cell = (CommunityGalleryCell *)[tableView dequeueReusableCellWithIdentifier:@"CommunityGalleryCell"];
    if (indexPath.row < _gallery.count ) {
        
        NSDictionary *gallery = (NSDictionary *) [_gallery objectAtIndex:indexPath.row];
        cell.imgVideo.hidden = false;
        NSString *strMediaURL;
        if ([[gallery objectForKey:@"display_type"] isEqualToString:@"image"]) {
            cell.imgVideo.hidden = true;
            strMediaURL = [gallery objectForKey:@"mediaurl"];
        }else{
            strMediaURL = [gallery objectForKey:@"thumburl"];
        }
        float width = [[gallery objectForKey:@"width"] integerValue];
        float height = [[gallery objectForKey:@"height"] integerValue];;
        float ratio = width / height;
        float imageHeight = (self.view.frame.size.width - 40) / ratio;
        cell.constraintForHeight.constant = imageHeight;
        if (strMediaURL.length) {
            [cell.indicator startAnimating];
            [cell.imgGallery sd_setImageWithURL:[NSURL URLWithString:strMediaURL]
                               placeholderImage:[UIImage imageNamed:@"NoImage"]
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          
                                          [cell.indicator stopAnimating];
                                      }];
        }

        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;

   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < _gallery.count) {
        
        NSDictionary *details = _gallery[indexPath.row];
        if ([[details objectForKey:@"display_type"] isEqualToString:@"video"]) {
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
            playerViewController.player = [AVPlayer playerWithURL:[NSURL URLWithString:[details objectForKey:@"mediaurl"]]];
            [delegate.window.rootViewController presentViewController:playerViewController animated:YES completion:nil];
             [playerViewController.player play];
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
    AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    //fade out / remove subview
}
-(IBAction)goBack:(id)sender{
    
    [self.delegate closeGalleryPopUp];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
