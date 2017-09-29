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



#import "SearchFriendsViewController.h"
#import "Constants.h"
#import "PlayerListTableViewCell.h"
#import "ProfileViewController.h"
#import "PrivateChatComposeViewController.h"

@interface SearchFriendsViewController () <UISearchBarDelegate> {
    
    IBOutlet UISearchBar *searchBar;
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
    NSString *strSeatchText;
    
}

@end

@implementation SearchFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllUsersWithPageNumber:currentPage isPagination:NO];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    

    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    searchBar.tintColor = [UIColor getThemeColor];
    UITextField *searchTextField = [searchBar valueForKey:@"_searchField"];
    if ([searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        [searchTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Search People" attributes:@{NSForegroundColorAttributeName: color}]];
    }
    [searchBar setImage:[UIImage imageNamed:@"Search_50"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [searchBar setImage:[UIImage imageNamed:@"Clear"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:CommonFont size:14]];
   
    currentPage = 1;
    arrDataSource = [NSMutableArray new];
    
    tableView.hidden = true;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    tableView.clipsToBounds = YES;
    tableView.layer.cornerRadius = 5.f;
    tableView.layer.borderWidth = 1.f;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    float width = 720;
    float height = 460;
    float ratio = width / height;
    float imageHeight = (self.view.frame.size.width) / ratio;
    constraintForNavBg.constant = imageHeight;
}

-(void)getAllUsersWithPageNumber:(NSInteger)pageNumber isPagination:(BOOL)isPagination{
    
//    AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
//    [Utility showLoadingScreenOnView:delegate.window.rootViewController.view withTitle:@"Syncing contacts.."];
    if (!isPagination) {
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility showLoadingScreenOnView:delegate.window.rootViewController.view withTitle:@"Loading.."];
    }
   
    [APIMapper getAllUserListWithPageNumber:pageNumber OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = false;
        [self showAllUsersWithJSON:responseObject];
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        tableView.hidden = false;
        isPageRefresing = false;
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        [tableView reloadData];

    }];
    
}

-(void)showAllUsersWithJSON:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[[responds objectForKey:@"data"] objectForKey:@"people"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
    //if (isDataAvailable) [searchBar becomeFirstResponder];
    
    [tableView reloadData];
    
    
}



#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = arrDataSource.count;
    if (rows <= 0) {
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
    static NSString *CellIdentifier = @"PlayerListTableViewCell";
    PlayerListTableViewCell *cell = (PlayerListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < arrDataSource.count) {
        
        cell.btnChat.hidden = true;
        cell.btnChat.tag = indexPath.row;
        cell.btnAddFrnd.tag = indexPath.row;
        cell.btnCancel.tag = indexPath.row;
        cell.btnAcept.tag = indexPath.row;
        
        cell.btnCancelReq.tag = indexPath.row;
        cell.btnReject.tag = indexPath.row;
        
        cell.contrsintForCancelReq.priority = 998;
        cell.contrsintForCreateReq.priority = 998;
        cell.contrsintForConfirmation.priority = 998;
        cell.contrsintForEnd.priority = 998;
        cell.vwCancelReq.hidden = true;
        cell.vwCreatereq.hidden = true;
        cell.vwConfirmation.hidden = true;
        NSDictionary *people = arrDataSource[indexPath.row];
        cell.lblName.text = [people objectForKey:@"name"];
        cell.lblLocation.text = [people objectForKey:@"location"];
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[people objectForKey:@"profileurl"]]
                          placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     
                                 }];
        
        NSInteger reqType = [[people objectForKey:@"friend_status"] integerValue];
        switch (reqType) {
            case eTypeCreateReq:
                [self configureCreateReqWithCell:cell];
                break;
            case eTypeRequested:
                [self configureRequestedCell:cell];
                break;
            case eTypeAccept:
                [self configureConfirmCell:cell];
                break;
            case eTypeFriends:
                [self configureConfirmedCell:cell];
                break;
                
            default:
                break;
        }
        
        
        
        
    }
    return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < arrDataSource.count) {
        NSDictionary *user = arrDataSource[indexPath.row];
        UINavigationController *navController = (UINavigationController*)self.revealViewController.frontViewController;
        NSArray *viewControllers = navController.viewControllers;
        if (viewControllers.count) {
            HomeViewController *homeVC = viewControllers[0];
            [homeVC showProfilePageWithID:[user objectForKey:@"user_id"]];
        }
        
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (isDataAvailable) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
        {
            if(isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
                
                NSInteger nextPage = currentPage ;
                nextPage += 1;
                if (nextPage  <= totalPages) {
                    isPageRefresing = YES;
                    [self getPaginationWithPage:nextPage];
                }
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
   [self.view endEditing:YES];
}

#pragma mark - Configure Cell

-(void)configureCreateReqWithCell:(PlayerListTableViewCell*)cell{
    
    cell.contrsintForCreateReq.priority = 999;
    cell.vwCreatereq.hidden = false;
    
}
-(void)configureRequestedCell:(PlayerListTableViewCell*)cell{
    
    cell.contrsintForCancelReq.priority = 999;
    cell.vwCancelReq.hidden = false;
}
-(void)configureConfirmCell:(PlayerListTableViewCell*)cell{
    
    cell.contrsintForConfirmation.priority = 999;
    cell.vwConfirmation.hidden = false;
}
-(void)configureConfirmedCell:(PlayerListTableViewCell*)cell{
    
    cell.contrsintForEnd.priority = 999;
    cell.btnChat.hidden = false;
  
}



#pragma mark - IBActions

-(IBAction)addFriend:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        NSDictionary *people = arrDataSource[sender.tag];
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility showLoadingScreenOnView:delegate.window.rootViewController.view withTitle:@"Requesting.."];
        [APIMapper addFriendWithFriendID:[people objectForKey:@"user_id"] OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
            if ([[responseObject objectForKey:@"data"] objectForKey:@"request_id"]) {
                
                NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:people];
                [dictUpdated setObject:[[responseObject objectForKey:@"data"] objectForKey:@"request_id"] forKey:@"request_id"];
                [dictUpdated setObject:[NSNumber numberWithInteger:1] forKey:@"friend_status"];
                [arrDataSource replaceObjectAtIndex:sender.tag withObject:dictUpdated];
                [tableView reloadData];
            }
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
          
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
            
        }];

    }
    
}

-(IBAction)cancelAlreadyGivenReq:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        NSDictionary *people = arrDataSource[sender.tag];
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility showLoadingScreenOnView:delegate.window.rootViewController.view withTitle:@"Cancelling.."];
        [APIMapper updateFriendRequestWithReqID:[people objectForKey:@"request_id"] status:0 OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
            NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:people];
            [dictUpdated setObject:[NSNumber numberWithInteger:0] forKey:@"friend_status"];
            [arrDataSource replaceObjectAtIndex:sender.tag withObject:dictUpdated];
            [tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
        }];
        
    }
}

-(IBAction)acceptReq:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        NSDictionary *people = arrDataSource[sender.tag];
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility showLoadingScreenOnView:delegate.window.rootViewController.view withTitle:@"Accepting.."];
        [APIMapper updateFriendRequestWithReqID:[people objectForKey:@"request_id"] status:1 OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
            NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:people];
            [dictUpdated setObject:[NSNumber numberWithInteger:3] forKey:@"friend_status"];
            [arrDataSource replaceObjectAtIndex:sender.tag withObject:dictUpdated];
            [tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
        }];
        
    }
    
}

-(IBAction)rejectRequest:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        NSDictionary *people = arrDataSource[sender.tag];
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility showLoadingScreenOnView:delegate.window.rootViewController.view withTitle:@"Rejecting.."];
        [APIMapper updateFriendRequestWithReqID:[people objectForKey:@"request_id"] status:0 OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
            NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:people];
            [dictUpdated setObject:[NSNumber numberWithInteger:0] forKey:@"friend_status"];
            [arrDataSource replaceObjectAtIndex:sender.tag withObject:dictUpdated];
            [tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
        }];
        
    }
    
}



#pragma mark - Search Methods and Delegates

- (BOOL)searchBar:(UISearchBar *)_searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *trimDot = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimDot isEqualToString:@"."]) {
        return YES;
    }
    NSString *appendStr;
    if([text length] == 0)
    {
        NSRange rangemak = NSMakeRange(0, [_searchBar.text length]-1);
        appendStr = [_searchBar.text substringWithRange:rangemak];
    }
    else
    {
        appendStr = [NSString stringWithFormat:@"%@%@",_searchBar.text,text];
        
    }
    [self performSelector:@selector(callSearchWebService:) withObject:appendStr];
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)_searchBar
{
    [self performSelector:@selector(callSearchWebService:) withObject:_searchBar.text];
    searchBar.showsCancelButton=NO;
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        [self performSelector:@selector(callSearchWebService:) withObject:searchText];
    }
    
}

-(void)callSearchWebService:(NSString*)searchText{
    
    strSeatchText = searchText;
    currentPage = 1;
    NSString *trimDot = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    trimDot = [trimDot stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [APIMapper searchUserNameWithText:trimDot pageNumber:currentPage OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self praseResponds:responseObject isByPagination:NO];
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
       
    }];
}

-(void)praseResponds:(NSDictionary*)responds isByPagination:(BOOL)isByPagination{
    
    if (!isByPagination) {
        isDataAvailable = false;
        [arrDataSource removeAllObjects];
    }
   
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[[responds objectForKey:@"data"] objectForKey:@"people"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
    [tableView reloadData];

}
-(void)getPaginationWithPage:(NSInteger)page{
    
    [APIMapper searchUserNameWithText:strSeatchText pageNumber:page OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self praseResponds:responseObject isByPagination:YES];
        isPageRefresing = false;
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        isPageRefresing = false;
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        
    }];
}

-(IBAction)composeChat:(UIButton*)btn{
    
    PrivateChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForPrivateChatComposer];
    if (btn.tag < arrDataSource.count) {
        NSDictionary *details = arrDataSource[btn.tag];
        if ([details objectForKey:@"user_id"]) {
            chatCompose.strUserID = [details objectForKey:@"user_id"];
        }
    }
    
    [[self navigationController]pushViewController:chatCompose animated:YES];
    
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
