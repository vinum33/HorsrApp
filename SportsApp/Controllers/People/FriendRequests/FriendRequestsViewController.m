//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "FriendRequestsViewController.h"
#import "FriendRequestsCell.h"
#import "Constants.h"
#import "ProfileViewController.h"

@interface FriendRequestsViewController (){
    
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

@implementation FriendRequestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllFriendRequetsWithPage:currentPage isPagination:NO];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    currentPage = 1;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    
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

-(void)refreshPage{
    
    [arrDataSource removeAllObjects];
    [self getAllFriendRequetsWithPage:currentPage isPagination:NO];
    
}
-(void)getAllFriendRequetsWithPage:(NSInteger)pageNumber isPagination:(BOOL)isPagination{
    
    if (!isPagination) {
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility showLoadingScreenOnView:delegate.window.rootViewController.view withTitle:@"Loading.."];
    }
    
    [APIMapper getAllFriendRequestsWithpageNumber:pageNumber Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        isPageRefresing = false;
        [self showAllRequestsWithJSON:responseObject];
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        isPageRefresing = false;
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
        [tableView reloadData];
    }];
    
}

-(void)showAllRequestsWithJSON:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[responds objectForKey:@"data"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
//    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
//        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
//    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
//        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
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
    static NSString *CellIdentifier = @"FriendRequestsCell";
    FriendRequestsCell *cell = (FriendRequestsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < arrDataSource.count) {
        cell.btnCancel.tag = indexPath.row;
        cell.btnConfirm.tag = indexPath.row;
        [cell.indicator startAnimating];
        NSDictionary *user = arrDataSource[indexPath.row];
        cell.lblName.text = [user objectForKey:@"name"];
        cell.lblLoc.text = [user objectForKey:@"location"];;
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[user objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   [cell.indicator stopAnimating];
                                   
                               }];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.parentViewController.view endEditing:YES];
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

-(IBAction)acceptReq:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        NSDictionary *people = arrDataSource[sender.tag];
        AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [Utility showLoadingScreenOnView:delegate.window.rootViewController.view withTitle:@"Accepting.."];
        
        [APIMapper updateFriendRequestWithReqID:[people objectForKey:@"request_id"] status:1 OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
            [arrDataSource removeObjectAtIndex:sender.tag];
            [self resetDataSource];
           
            
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
            [arrDataSource removeObjectAtIndex:sender.tag];
            [self resetDataSource];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
            [Utility hideLoadingScreenFromView:delegate.window.rootViewController.view];
        }];
        
    }
    
}

-(void)resetDataSource{
    
    if (arrDataSource.count <= 0) {
        isDataAvailable = false;
    }
    strAPIErrorMsg = @"No Friends request Found!";
     [tableView reloadData];
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
