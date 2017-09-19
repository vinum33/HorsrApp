//
//  ChatComposeViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kSectionCount               1
#define kMinimumCellCount           1



#import "ParticipantsViewController.h"
#import "Constants.h"
#import "ParticipantsCell.h"
#import "PrivateChatComposeViewController.h"

@interface ParticipantsViewController (){
    
    IBOutlet UITableView *tableView;
    IBOutlet UIView *vwBG;
    NSArray *arrUser;
    BOOL isDataAvailable;
    NSString *strAPIErrorMsg;
    
}

@end

@implementation ParticipantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllParticipantsWithPageNumber:1 isByPagination:NO];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    vwBG.clipsToBounds = YES;
    vwBG.layer.cornerRadius = 5.f;
    vwBG.layer.borderWidth = 1.f;
    tableView.backgroundColor = [UIColor whiteColor];
    vwBG.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
       
}




-(void)getAllParticipantsWithPageNumber:(NSInteger)pageNo isByPagination:(BOOL)isPagination{
    
    [self showLoadingScreen];
    
    [APIMapper getAllMembersInGroupWithGroupID:_strGroupID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self hideLoadingScreen];
        [self parseJson:responseObject];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        isDataAvailable = false;
        [self hideLoadingScreen];
        [tableView reloadData];
        [tableView setHidden:false];
        
    }];
    
    
}

-(void)parseJson:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        arrUser = [responds objectForKey:@"data"];
    if (arrUser.count > 0) isDataAvailable = true;
    tableView.hidden = false;
    [tableView reloadData];
    
    
}




#pragma mark - UITableViewDataSource Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable) {
        return 1;
    }
    return arrUser.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDataAvailable) {
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strAPIErrorMsg];
        return cell;
    }
  
    ParticipantsCell *cell = (ParticipantsCell *)[tableView dequeueReusableCellWithIdentifier:@"ParticipantsCell"];
    if (indexPath.row < arrUser.count ) {
        
        NSDictionary *comment = (NSDictionary *) [arrUser objectAtIndex:indexPath.row];
        cell.btnChat.hidden = false;
        cell.btnChat.tag = indexPath.row;
        if ([[comment objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId]) {
             cell.btnChat.hidden = true;
        }
        cell.lblName.text = [comment objectForKey:@"name"];
        cell.lblLocation.text = [comment objectForKey:@"location"];
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[comment objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;

   
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    

    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
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

-(IBAction)composeChat:(UIButton*)sender{
    
    if (sender.tag < arrUser.count) {
        NSDictionary *details = arrUser[sender.tag];
        [[self delegate]showChatPageWithInfo:details];
    }
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
    
    [self.delegate closePopUp];
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
