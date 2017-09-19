//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

typedef enum{
    
    eTypeNotifications      = 0,
    eTypeGameReq            = 1,
    eTypePending            = 2,
    
    
}eMenuType;

#define kLimitReached           406

#import "NotificationsViewController.h"
#import "NotificationsCell.h"
#import "Constants.h"
#import "GameReqConfirmCell.h"
#import "NotificationHeader.h"

@interface NotificationsViewController () <RequestCellDelegate>{
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    IBOutlet UIButton* btnClaer;
    NSMutableArray *arrDataSource;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
    IBOutlet UISegmentedControl *segmentControll;
    eMenuType menuType;
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
    
    menuType = eTypeNotifications;
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
    
    segmentControll.tintColor = [UIColor whiteColor];
    NSDictionary *attributes1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont fontWithName:CommonFont size:13], NSFontAttributeName,
                                 [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    NSDictionary *attributes2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont fontWithName:CommonFont size:13], NSFontAttributeName,
                                 [UIColor getBlackTextColor], NSForegroundColorAttributeName, nil];
    
    [segmentControll setTitleTextAttributes:attributes1 forState:UIControlStateNormal];
    [segmentControll setTitleTextAttributes:attributes2 forState:UIControlStateSelected];
}
-(IBAction)segmentChanged:(id)sender{
    
    btnClaer.hidden = true;
    [arrDataSource removeAllObjects];
    isDataAvailable = false;
    tableView.hidden = true;
    [tableView reloadData];
    menuType = eTypeNotifications;
    if ([segmentControll selectedSegmentIndex] == 1) {
        menuType = eTypeGameReq;
    }
    currentPage = 1;
    [self getAllNotificationsByPage:currentPage isPagination:NO];
}

-(void)getAllNotificationsByPage:(NSInteger)pageNumber isPagination:(BOOL)isPagination{
    
    if (!isPagination) {
        [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    }
    
    [APIMapper getAllNotificationsPageNumber:pageNumber type:menuType OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = false;
        [self showAllUsersWithJSON:responseObject];
        [Utility hideLoadingScreenFromView:self.view];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
         isDataAvailable = false;
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
    if (isDataAvailable && menuType == eTypeNotifications) {
        btnClaer.hidden = false;
    }
    
    
}



#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    if (menuType == eTypeNotifications || !isDataAvailable) {
        return 1;
    }
    return arrDataSource.count;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows =  arrDataSource.count;
    if (menuType == eTypeNotifications || !isDataAvailable) {
        if (!isDataAvailable) {
            rows = 1;
        }
        
    }else{
        
        if (section < arrDataSource.count) {
            
            NSDictionary *details  = arrDataSource[section];
            NSArray *items = [details objectForKey:@"game_reply"];
            rows = items.count;
        }
    }

    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (!isDataAvailable) {
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strAPIErrorMsg];
        return cell;
    }
    
    if (menuType == eTypeNotifications) {
        NSString *CellIdentifier = @"NotificationCell";
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
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }

    }else{
        
        if (indexPath.section < arrDataSource.count) {
            GameReqConfirmCell *cell;
            NSString *CellIdentifier = @"GameReqPendingCell";
            NSDictionary *details  = arrDataSource[indexPath.section];
            NSArray *items = [details objectForKey:@"game_reply"];
            if (indexPath.row < items.count) {
                BOOL needActionCell = false;
                NSDictionary *userInfo = items[indexPath.row];
                if ([[userInfo objectForKey:@"verify_status"] integerValue] == 1) needActionCell = true;
                if (needActionCell) CellIdentifier = @"GameReqConfirmCell";
                NSInteger status = [[userInfo objectForKey:@"verify_status"] integerValue];
                
                NSString *statusMsg;
                UIColor *statusColor = [UIColor getThemeColor];
                if (status == 0) statusMsg = @"Pending";
                else if (status == 2){
                    CellIdentifier = @"GameReqDoneCell";
                    statusMsg = @"Accepted";
                    statusColor = [UIColor colorWithRed:0.04 green:0.71 blue:0.00 alpha:1.0];;
                }
                else if (status == 3){
                    CellIdentifier = @"GameReqDoneCell";
                    statusMsg = @"Rejected";
                    statusColor = [UIColor colorWithRed:0.84 green:0.01 blue:0.01 alpha:1.0];;
                }
                cell = (GameReqConfirmCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                cell.lblStatusMessage.text = statusMsg;
                cell.lblStatusMessage.textColor = statusColor;
                cell.delegate = self;
                cell.column = indexPath.section;
                cell.row = indexPath.row;
                cell.lblName.text = [userInfo objectForKey:@"name"];
                cell.lblMessage.text = [userInfo objectForKey:@"reply_msg"];
                [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"profileurl"]]
                                   placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                              
                                          }];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
       
    }
 
    return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section{
    
    if (!isDataAvailable || menuType == eTypeNotifications) {
        return 0.1;
    }
    return 70;
}

- (nullable UIView *)tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!isDataAvailable || menuType == eTypeNotifications) {
        return nil;
    }
    NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"NotificationHeader" owner:self options:nil];
    NotificationHeader *header = [viewArray objectAtIndex:0];
    if (section < arrDataSource.count) {
        NSDictionary *details  = arrDataSource[section];
        header.lblDate.text = [Utility getDateDescriptionForChat:[[details objectForKey:@"gameadded_date"] doubleValue]] ;
        [header.imgThumb sd_setImageWithURL:[NSURL URLWithString:[details objectForKey:@"imageurl"]]
                        placeholderImage:[UIImage imageNamed:@"NoImage"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        
    }
    
    return header;
    
    
}
- (nullable UIView *)tableView:(UITableView *)_tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}


-(void)cellClickedWithColumn:(NSInteger)column row:(NSInteger)row type:(NSInteger)type{
    
    if (column < arrDataSource.count) {
        
        NSInteger updatedStatus = 3;
        if (type == 1) {
            //Confirmed
            updatedStatus = 2;
        }
        NSMutableDictionary *details  = [NSMutableDictionary dictionaryWithDictionary:arrDataSource[column]];
        NSMutableArray *items = [NSMutableArray arrayWithArray:[details objectForKey:@"game_reply"]];
        if (row < items.count) {
            NSDictionary *people = items[row];
            [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
            [APIMapper updateGameRequestWithStatus:type requestID:[people objectForKey:@"request_id"] Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSMutableDictionary *updatedInfo = [NSMutableDictionary dictionaryWithDictionary:people];
                [updatedInfo setObject:[NSNumber numberWithInteger:updatedStatus] forKey:@"verify_status"];
                [items replaceObjectAtIndex:row withObject:updatedInfo];
                [details setObject:items forKey:@"game_reply"];
                [Utility hideLoadingScreenFromView:self.view];
                [arrDataSource replaceObjectAtIndex:column withObject:details];
                [tableView reloadData];
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                
                [Utility hideLoadingScreenFromView:self.view];
                NSString *title = @"ERROR";
                NSString *errormsg = error.localizedDescription;
                if (task.responseData) {
                    if ([task.response statusCode] == kLimitReached) {
                        title = @"LIMIT REACHED";
                        [tableView reloadData];
                    }
                    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:task.responseData
                                                                         options:kNilOptions
                                                                           error:&error];
                    if (NULL_TO_NIL([json objectForKey:@"text"])) errormsg = [json objectForKey:@"text"];
                    
                    
                }
                
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:title
                                              message:errormsg
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
            btnClaer.hidden = true;
            
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
