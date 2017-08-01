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

#import "InviteOthersViewController.h"
#import "Constants.h"
#import "InviteOthersCell.h"

@interface InviteOthersViewController (){
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
    
    IBOutlet UISearchBar *searchBar;
    IBOutlet UIButton* btnTick;
    IBOutlet UIButton *btnSearch;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnClose;
    
    
}

@end

@implementation InviteOthersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllFriendsWithPageNumber:currentPage isPagination:NO];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
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
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    searchBar.tintColor = [UIColor getThemeColor];
    UITextField *searchTextField = [searchBar valueForKey:@"_searchField"];
    if ([searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        [searchTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Search friends" attributes:@{NSForegroundColorAttributeName: color}]];
    }
    [searchBar setImage:[UIImage imageNamed:@"Search_50"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [searchBar setImage:[UIImage imageNamed:@"Clear"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:CommonFont size:14]];
}

-(IBAction)searchClicked:(id)sender{
    
    searchBar.text = @"";
    lblTitle.hidden = true;
    btnSearch.hidden = true;
    btnTick.hidden = true;
    searchBar.hidden = false;
    btnClose.hidden = false;
    
}

-(IBAction)clearClicked:(id)sender{
    
    btnSearch.hidden = false;
    btnTick.hidden = false;
    searchBar.hidden = true;
    lblTitle.hidden = false;
    btnClose.hidden = true;
   [self getAllFriendsWithPageNumber:currentPage isPagination:NO];
    [self.view endEditing:YES];
}


-(void)getAllFriendsWithPageNumber:(NSInteger)pageNumber isPagination:(BOOL)isPagination{
    
    if (!isPagination) {
        [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    }
    
    [APIMapper getAllMyFriendsPageNumber:pageNumber onSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        btnSearch.hidden = false;
        btnTick.hidden = false;
        tableView.hidden = false;
        isPageRefresing = false;
        [self showAllUsersWithJSON:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        btnSearch.hidden = true;
        btnTick.hidden = true;
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

-(void)showAllUsersWithJSON:(NSDictionary*)responds{
    
    [arrDataSource removeAllObjects];
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[responds objectForKey:@"data"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
//    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
//        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
//    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
//        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
    NSMutableArray *arrUsers = [NSMutableArray new];
    if (_selectedUsers.count) {
        for (NSDictionary *dict in arrDataSource) {
            NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:dict];
            if ([_selectedUsers containsObject:[dict objectForKey:@"user_id"]]) {
                 [dictUpdated setObject:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
            }
            [arrUsers addObject:dictUpdated];
        }
        arrDataSource = [NSMutableArray arrayWithArray:arrUsers];
    }
    
    
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
        cell.lblLoc.text = [people objectForKey:@"location"];
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[people objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        if ([[people objectForKey:@"isSelected"] boolValue]) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:1.00 green:0.51 blue:0.16 alpha:.3];
        }
        if ([[people objectForKey:@"logged_status"] boolValue]){
            cell.imgStatus.image = [UIImage imageNamed:@"Online"];
            if ([[people objectForKey:@"isSelected"] boolValue]) {
                cell.imgStatus.image = [UIImage imageNamed:@"Online_Selected"];
            }
        }else{
             cell.imgStatus.image = [UIImage imageNamed:@"Offline"];
            if ([[people objectForKey:@"isSelected"] boolValue]) {
                cell.imgStatus.image = [UIImage imageNamed:@"Offline_Selected"];
            }
        }
        
    }

    
    return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < arrDataSource.count) {
        NSDictionary *people = arrDataSource[indexPath.row];
        NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:people];
        if ([[dictUpdated objectForKey:@"isSelected"] boolValue]) {
            [dictUpdated setObject:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
        }else{
            [dictUpdated setObject:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
        }
        [arrDataSource replaceObjectAtIndex:indexPath.row withObject:dictUpdated];
        [tableView reloadData];
        
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
   // [self performSelector:@selector(callSearchWebService:) withObject:_searchBar.text];
    searchBar.showsCancelButton = NO;
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if ([searchText isEqualToString:@""]) {
       [self performSelector:@selector(callSearchWebService:) withObject:searchText];
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
}

-(void)callSearchWebService:(NSString*)searchText{
    
    currentPage = 1;
    NSString *trimDot = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [APIMapper searchFriendsNameWithText:trimDot pageNumber:currentPage OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self praseResponds:responseObject];
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        
    }];
}

-(void)praseResponds:(NSDictionary*)responds{
    
    isDataAvailable = false;
    [arrDataSource removeAllObjects];
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[responds objectForKey:@"data"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
//    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
//        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
//    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
//        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
    NSMutableArray *arrUsers = [NSMutableArray new];
    if (_selectedUsers.count) {
        for (NSDictionary *dict in arrDataSource) {
            NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:dict];
            if ([_selectedUsers containsObject:[dict objectForKey:@"user_id"]]) {
                [dictUpdated setObject:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
            }
            [arrUsers addObject:dictUpdated];
        }
        arrDataSource = [NSMutableArray arrayWithArray:arrUsers];
    }
    [tableView reloadData];
    
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

-(IBAction)doneApplied:(id)sender{
    
    NSMutableArray *selections = [NSMutableArray new];
    for (NSDictionary *dict in arrDataSource) {
        if ([[dict objectForKey:@"isSelected"] boolValue]) {
            [selections addObject:dict];
        }
    }
    
    [[self delegate]userInvitedWithList:selections];
    [[self navigationController]popViewControllerAnimated:YES];
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
