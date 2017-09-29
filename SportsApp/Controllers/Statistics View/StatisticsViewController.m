//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

typedef enum{
    
    eCellPlayed     = 0,
    eCellWon        = 1,
    eCellLost       = 2,
    eCellNoResult   = 3,
    eCellPoint      = 4,
    
}eSectionType;


#import "StatisticsViewController.h"
#import "FriendRequestsCell.h"
#import "Constants.h"
#import "ProfileViewController.h"

@interface StatisticsViewController (){
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    IBOutlet UIView* vwBg;
    
    IBOutlet UILabel* lblstatDate;
    IBOutlet UIImageView* imgOne;
    IBOutlet UIImageView* imgTwo;
    IBOutlet UILabel* lblNameOne;
    IBOutlet UILabel* lblNameTwo;
    
    NSDictionary *userInfo;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
}

@end

@implementation StatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self setUpHeader];
    [self getStatistics];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    vwBg.clipsToBounds = YES;
    vwBg.layer.cornerRadius = 5.f;
    vwBg.layer.borderWidth = 1.f;
    vwBg.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    
    float width = 720;
    float height = 460;
    float ratio = width / height;
    float imageHeight = (self.view.frame.size.width) / ratio;
    constraintForNavBg.constant = imageHeight;
    
}

-(void)getStatistics{
   
    [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    [APIMapper getStatisticsWithUserID:_userID OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        isPageRefresing = false;
        [self pasreResponds:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        isPageRefresing = false;
        [Utility hideLoadingScreenFromView:self.view];
        [tableView reloadData];

    }];
        
    
    
}

-(void)pasreResponds:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        userInfo =  [responds objectForKey:@"data"];
    if (userInfo){
        
        isDataAvailable = true;
        
        lblNameOne.text = [[userInfo objectForKey:@"from"] objectForKey:@"name"];
        lblNameTwo.text = [[userInfo objectForKey:@"to"] objectForKey:@"name"];
        
        [imgOne sd_setImageWithURL:[NSURL URLWithString:[[userInfo objectForKey:@"from"] objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        [imgTwo sd_setImageWithURL:[NSURL URLWithString:[[userInfo objectForKey:@"to"] objectForKey:@"profileurl"]]
                  placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             
                         }];

    }
    
    [tableView reloadData];
    
    
}

-(void)setUpHeader{
    
    imgOne.clipsToBounds = YES;
    imgOne.layer.cornerRadius = 40.f;
    imgOne.layer.borderWidth = 3.f;
    imgOne.layer.borderColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0].CGColor;
    
    imgTwo.clipsToBounds = YES;
    imgTwo.layer.cornerRadius = 40.f;
    imgTwo.layer.borderWidth = 3.f;
    imgTwo.layer.borderColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0].CGColor;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 5;
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
    NSString *strValueOne;
    NSString *strValueTwo;
    NSInteger index = indexPath.row;
    NSString *CellIdentifier = @"PlayedCell";
    switch (index) {
            
        case eCellPlayed:
            CellIdentifier = @"PlayedCell";
            strValueOne = [NSString stringWithFormat: @"%ld", [[[userInfo objectForKey:@"from"] objectForKey:@"played"] integerValue]];
            strValueTwo = [NSString stringWithFormat: @"%ld", [[[userInfo objectForKey:@"to"] objectForKey:@"played"] integerValue]];
            
            break;
        case eCellWon:
            CellIdentifier = @"WonCell";
            strValueOne = [NSString stringWithFormat: @"%ld", [[[userInfo objectForKey:@"from"] objectForKey:@"won"] integerValue]];
            strValueTwo = [NSString stringWithFormat: @"%ld", [[[userInfo objectForKey:@"to"] objectForKey:@"won"] integerValue]];
            
            break;
            
        case eCellLost:
            CellIdentifier = @"LostCell";
            strValueOne = [NSString stringWithFormat: @"%ld", [[[userInfo objectForKey:@"from"] objectForKey:@"lost"] integerValue]];
            strValueTwo = [NSString stringWithFormat: @"%ld", [[[userInfo objectForKey:@"to"] objectForKey:@"lost"] integerValue]];
            
            break;
            
        case eCellNoResult:
            CellIdentifier = @"NoResultCell"; strValueOne = [NSString stringWithFormat: @"%ld", [[[userInfo objectForKey:@"from"] objectForKey:@"noresult"] integerValue]];
            strValueTwo = [NSString stringWithFormat: @"%ld", [[[userInfo objectForKey:@"to"] objectForKey:@"noresult"] integerValue]];
            
            break;
            
        case eCellPoint:
            CellIdentifier = @"PointCell";
            strValueOne = [NSString stringWithFormat: @"%ld", [[[userInfo objectForKey:@"from"] objectForKey:@"point"] integerValue]];
            strValueTwo = [NSString stringWithFormat: @"%ld", [[[userInfo objectForKey:@"to"] objectForKey:@"point"] integerValue]];
            
            break;
            
        default:
            break;
    }
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([[cell contentView] viewWithTag:2]) {
        UIView *vw = (UIView*)[[cell contentView] viewWithTag:2];
        vw.layer.borderWidth = 1.f;
        vw.layer.borderColor = [UIColor whiteColor].CGColor;
        
        if ([vw viewWithTag:3]) {
            UILabel *lblScore = (UILabel*)[vw viewWithTag:3];
            lblScore.text = strValueTwo;
        }
    }
    if ([[cell contentView] viewWithTag:1]) {
        UIView *vw = (UIView*)[[cell contentView] viewWithTag:1];
        vw.layer.borderWidth = 1.f;
        vw.layer.borderColor = [UIColor whiteColor].CGColor;
        if ([vw viewWithTag:3]) {
            UILabel *lblScore = (UILabel*)[vw viewWithTag:3];
            lblScore.text = strValueOne;
        }
    }

    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70;
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
        [tableView reloadData];
        
    }
    
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
