//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

typedef enum{
    
    eTypePlaying      = 0,
    eTypeCreated      = 1,
    eTypeCompleted    = 2,
    
    
}eGameType;

#import "ListGamesViewController.h"
#import "PlayerReqListCell.h"
#import "Constants.h"
#import "PlayedGameDetailPageViewController.h"
#import "GameZoneViewController.h"
#import "NotificationsViewController.h"
#import "SearchFriendsViewController.h"
#import "FriendRequestsViewController.h"

@interface ListGamesViewController () <GameZoneDelegate>{
    
    IBOutlet UISegmentedControl *segmentControll;
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
    eGameType gameType;
}

@end

@implementation ListGamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllGamesByPage:currentPage isPagination:NO];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    currentPage = 1;
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
    
    arrDataSource = [NSMutableArray new];
    gameType = eTypePlaying;
    segmentControll.tintColor = [UIColor whiteColor];
    NSDictionary *attributes1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont fontWithName:CommonFont size:14], NSFontAttributeName,
                                 [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    NSDictionary *attributes2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont fontWithName:CommonFont size:14], NSFontAttributeName,
                                 [UIColor getBlackTextColor], NSForegroundColorAttributeName, nil];
    
    [segmentControll setTitleTextAttributes:attributes1 forState:UIControlStateNormal];
    [segmentControll setTitleTextAttributes:attributes2 forState:UIControlStateSelected];
}

-(IBAction)segmentChanged:(UISegmentedControl*)sender{
    
    [arrDataSource removeAllObjects];
    currentPage = 1;
    
    switch ([sender selectedSegmentIndex]) {
        case eTypeCreated:
            gameType = eTypeCreated;
            break;
        case eTypePlaying:
            gameType = eTypePlaying;
            break;
        case eTypeCompleted:
             gameType = eTypeCompleted;
            break;
            
        default:
            break;
    }
   
     [self getAllGamesByPage:currentPage isPagination:NO];
    
}


-(void)getAllGamesByPage:(NSInteger)pageNumber isPagination:(BOOL)isPagination{
    
    if (!isPagination) {
        [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    }
    
    [APIMapper getAllGamesWithpageNumber:pageNumber gameType:gameType Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = false;
        [self showAllGamesWithJSON:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isPagination) {
                [tableView setContentOffset:CGPointZero animated:NO];
            }
        });
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        tableView.hidden = false;
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        isPageRefresing = false;
        [tableView reloadData];
        [Utility hideLoadingScreenFromView:self.view];
    }];
                
}

-(void)showAllGamesWithJSON:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"game"]))
        [arrDataSource addObjectsFromArray:[[responds objectForKey:@"data"] objectForKey:@"game"]];
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
    
    PlayerReqListCell *cell = (PlayerReqListCell*)[tableView dequeueReusableCellWithIdentifier:@"PlayerReqListCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < arrDataSource.count) {
        [cell.indicator startAnimating];
        NSDictionary *game = arrDataSource[indexPath.row];
        cell.btnPlayVideo.tag = indexPath.row;
        cell.btnAcceptInvite.tag = indexPath.row;
        cell.btnRejectInvite.tag = indexPath.row;
        cell.lblKey.text = [Utility getDateDescriptionForChat:[[game objectForKey:@"gameadded_date"] doubleValue]];
        cell.lblName.text = [game objectForKey:@"name"];
        cell.lblDateTime.text = [game objectForKey:@"location"];
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

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath *path = [tableView indexPathForSelectedRow];
    if (path.row < arrDataSource.count) {
        NSDictionary *details = arrDataSource[path.row];
        if ((gameType == eTypeCreated) || (gameType == eTypeCompleted) ) {
            
            PlayedGameDetailPageViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForPlayedGameDetail];
            games.strGameID = [details objectForKey:@"id"];
            [[self navigationController]pushViewController:games animated:YES];
            
        }
        else{
            
            GameZoneViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForPlayedGameZone];
            games.strGameID = [details objectForKey:@"id"];
            games.delegate = self;
            [[self navigationController]pushViewController:games animated:YES];
            
        }
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





-(void)gameZoneCompleted{
    
    [segmentControll setSelectedSegmentIndex:0];
    [arrDataSource removeAllObjects];
    currentPage = 1;
    gameType = eTypePlaying;
    [self getAllGamesByPage:currentPage isPagination:NO];
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

-(NSString*)getDaysBetweenTwoDatesWith:(double)timeInSeconds{
    
    NSDate * today = [NSDate date];
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:refDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:today];
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute
                                                  fromDate:fromDate toDate:toDate options:0];
    NSString *msgDate;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy EE h:mm a"];
    msgDate = [dateformater stringFromDate:refDate];
    
     NSInteger days = [difference day];
     if (days > 7) {
     NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
     [dateformater setDateFormat:@"d MMM,yyyy EE h:mm a"];
     msgDate = [dateformater stringFromDate:refDate];
     }
     else if (days <= 0) {
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"h:mm a"];
     NSDate *date = refDate;
     msgDate = [dateFormatter stringFromDate:date];
     }else{
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"EE h:mm a"];
     msgDate = [dateFormatter stringFromDate:refDate];
     }
    
    return msgDate;
    
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
