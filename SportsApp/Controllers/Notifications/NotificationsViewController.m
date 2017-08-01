//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationsCell.h"
#import "Constants.h"

@interface NotificationsViewController (){
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    IBOutlet UIButton* btnClaer;
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
}

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllNotificationsByPage:currentPage isPagination:NO];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    tableView.hidden = true;
    btnClaer.hidden = true;
    currentPage = 1;
    arrDataSource = [NSMutableArray new];
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

-(void)getAllNotificationsByPage:(NSInteger)pageNumber isPagination:(BOOL)isPagination{
    
    if (!isPagination) {
        [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    }
    
    [APIMapper getAllNotificationsPageNumber:pageNumber OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = false;
        [self showAllUsersWithJSON:responseObject];
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

-(void)showAllUsersWithJSON:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[responds objectForKey:@"data"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
//    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
//        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
//    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
//        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
    [tableView reloadData];
    if (isDataAvailable) {
        btnClaer.hidden = false;
    }
    
    
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
    
    static NSString *CellIdentifier = @"NotificationCell";
    NotificationsCell *cell = (NotificationsCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < arrDataSource.count) {
        NSDictionary *notification = arrDataSource[indexPath.row];
        NSString *name = [notification objectForKey:@"name"];
        NSMutableAttributedString *messgae = [[NSMutableAttributedString alloc] initWithString:[notification objectForKey:@"notification_msg"]];
        [messgae addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:CommonFontBold size:14]
                      range:NSMakeRange(0, name.length)];
        cell.lblTitle.attributedText = messgae;
        cell.lblDate.text = [Utility getDaysBetweenTwoDatesWith:[[notification objectForKey:@"notification_date"] doubleValue]] ;
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[notification objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
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

-(IBAction)clearNotifications:(id)sender{
    
    if (!arrDataSource.count) {
        return;
    }
    [Utility showLoadingScreenOnView:self.view withTitle:@"Deleting.."];
    [APIMapper clearAllNotificationsOnsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            NSMutableArray *left = [[NSMutableArray alloc]init];
            NSMutableArray *right = [[NSMutableArray alloc]init];
            for(int i=0;i<arrDataSource.count;i++){
                NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                if(i%2==0)
                    [left addObject:ip];
                else
                    [right addObject:ip];
            }
            [arrDataSource removeAllObjects];
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithArray:left]
                             withRowAnimation:UITableViewRowAnimationLeft];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithArray:right]
                             withRowAnimation:UITableViewRowAnimationRight];
            [tableView endUpdates];
            [Utility hideLoadingScreenFromView:self.view];
            
            
        } completion:^(BOOL finished) {
            // code
            strAPIErrorMsg = @"You have no notifications";
            isDataAvailable = false;
            [tableView reloadData];
        }];
        
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        isPageRefresing = false;
        [Utility hideLoadingScreenFromView:self.view];
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
