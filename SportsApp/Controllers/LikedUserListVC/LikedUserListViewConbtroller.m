//
//  ViewController.m
//  Paging_ObjC
//
//  Created by olxios on 23/10/14.
//  Copyright (c) 2014 olxios. All rights reserved.
//

#import "InviteOthersCell.h"
#import "Constants.h"
#import "LikedUserListViewConbtroller.h"
#import "PageItemController.h"
#import "ProfileViewController.h"

@interface LikedUserListViewConbtroller (){
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    IBOutlet UIView* vwBG;
    IBOutlet UILabel *lblTitle;
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
}


@end

@implementation LikedUserListViewConbtroller

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
    [self getAllFriendsWithPageNumber:1 isPagination:NO];
  
}

-(void)setUp{
    
    if (!_isTypeLiked) lblTitle.text = @"People who commented";
    currentPage = 1;
    arrDataSource = [NSMutableArray new];
    
    tableView.hidden = true;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    tableView.clipsToBounds = YES;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    vwBG.layer.cornerRadius = 5.f;
    vwBG.layer.borderWidth = 1.f;
    vwBG.backgroundColor = [UIColor whiteColor];
    vwBG.layer.borderColor = [UIColor clearColor].CGColor;
    
    float width = 720;
    float height = 460;
    float ratio = width / height;
    float imageHeight = (self.view.frame.size.width) / ratio;
    constraintForNavBg.constant = imageHeight;
    
   }


-(void)getAllFriendsWithPageNumber:(NSInteger)pageNumber isPagination:(BOOL)isPagination{
    
    if (!isPagination) {
        [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    }
    
    [APIMapper getCommentedAndLikedUsersWithType:_isTypeLiked communityID:_strCommunityID onSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = false;
        [self praseResponds:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        tableView.hidden = false;
        isPageRefresing = false;
        [Utility hideLoadingScreenFromView:self.view];
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        [tableView reloadData];
    }];
    
    
}

-(void)praseResponds:(NSDictionary*)responds{
    
    [arrDataSource removeAllObjects];
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[responds objectForKey:@"data"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
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
    
    static NSString *CellIdentifier = @"InviteOthersCell";
    InviteOthersCell *cell = (InviteOthersCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < arrDataSource.count) {
        
        NSDictionary *people = arrDataSource[indexPath.row];
        cell.lblName.text = [people objectForKey:@"name"];
        cell.lblDateTime.text = [Utility getDateDescriptionForChat:[[people objectForKey:@"date_time"] doubleValue]] ;
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[people objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
    }
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < arrDataSource.count) {
        NSDictionary *user = arrDataSource[indexPath.row];
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
-(IBAction)goBack:(id)sender{
    
    [self.delegate closeComentOrLikeUserPopUp];
}


@end
