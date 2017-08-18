//
//  ChatComposeViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kSectionCount               1
#define kDefaultCellHeight          70
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kHeightForHeader            40

#define kTagForImage                1
#define kTagForName                 2


#import "ChatComposeViewController.h"
#import "Constants.h"
#import "ComposeMessageTableViewCell.h"
#import "HPGrowingTextView.h"
#import "ProfileViewController.h"

@interface ChatComposeViewController () <HPGrowingTextViewDelegate>{
    
    IBOutlet UIView *vwBG;
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView *tableView;
    IBOutlet UIView *vwLoadHistory;
    IBOutlet NSLayoutConstraint *tableConstraint;
    
    NSMutableArray *arrMessages;
    UIButton *btnDone;;
    
    BOOL isPageRefresing;
    NSInteger totalPages;
    HPGrowingTextView *textView;
    UIView *containerView;
    NSInteger currentPage;
    BOOL isDataAvailable;
    NSString *strAPIErrorMsg;
}

@end

@implementation ChatComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self loadChatHistoryWithPageNo:currentPage isByPagination:NO];
    [self setUpGrowingTextView];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    isDataAvailable = false;
    self.view.backgroundColor = [UIColor whiteColor];
    vwLoadHistory.hidden = true;
    currentPage = 1;
    totalPages = 10;
    arrMessages = [NSMutableArray new];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.clipsToBounds = YES;
    vwBG.layer.cornerRadius = 5.f;
    vwBG.layer.borderWidth = 1.f;
    vwBG.backgroundColor = [UIColor whiteColor];
    vwBG.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    tableView.hidden = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}



-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}


-(void)loadChatHistoryWithPageNo:(NSInteger)pageNo isByPagination:(BOOL)isPagination{
    
    if (!isPagination){
        [self hideLoadingScreen];
        [self showLoadingScreen];
    }
    
    else
        vwLoadHistory.hidden = false;
    [APIMapper loadChatHistoryWithGameID:_strGameID toUserID:_strUserID page:pageNo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self showAllChatHistoryMessagesWith:responseObject isPagination:isPagination];
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (task.responseData)
            [self displayErrorMessgeWithDetails:task.responseData];
        else
            strAPIErrorMsg = error.localizedDescription;
        isDataAvailable = false;
        [self hideLoadingScreen];
        [tableView reloadData];
        [tableView setHidden:false];
        isPageRefresing = NO;
        vwLoadHistory.hidden = true;
        
    }];
    
    
}

-(void)showAllChatHistoryMessagesWith:(NSDictionary*)responds isPagination:(BOOL)isPagination{
    
    vwLoadHistory.hidden = true;
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"chat"])){
        NSArray *result = [[responds objectForKey:@"data"] objectForKey:@"chat"];
        if (result.count) {
            isDataAvailable = true;
            if (isPagination) {
                NSMutableArray *indexPaths = [NSMutableArray array];
                for (int i = 0; i < result.count; i++) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    [arrMessages insertObject:result[i] atIndex:i];
                }
                [tableView beginUpdates];
                [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
                [tableView endUpdates];
            }else{
                [arrMessages addObjectsFromArray:result];
                [tableView reloadData];
                [self tableScrollToLastCell];
            }
        }
    }
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
    
    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
    

    tableView.hidden = false;
    isPageRefresing = NO;
    
}



-(void)newChatHasReceivedWithDetails:(NSDictionary*)chatInfo{
    
    [arrMessages addObject:chatInfo];
    [tableView reloadData];
    [self tableScrollToLastCell];
    
    
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
    return arrMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDataAvailable) {
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strAPIErrorMsg];
        return cell;
    }
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell = [self configureCellForIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(UITableViewCell*)configureCellForIndexPath:(NSIndexPath*)indexPath{
   
    NSString *CellIdentifier = @"ChatComposeCellLeft";
    ComposeMessageTableViewCell *cell = (ComposeMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (indexPath.row < arrMessages.count ) {
        
        NSDictionary *chatInfo = (NSDictionary *) [arrMessages objectAtIndex:indexPath.row];
        NSString *sender = @"OTHERS";
        NSString *localDateTime;
        if ([[chatInfo objectForKey:@"in_out"] integerValue] == 1) {
            sender = @"YOU";
            CellIdentifier = @"ChatComposeCellRight";
            cell = (ComposeMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        NSString *message = [chatInfo objectForKey:@"msg"];
        if ([chatInfo objectForKey:@"chat_datetime"]) {
            double serverTime = [[chatInfo objectForKey:@"chat_datetime"] doubleValue];
            localDateTime = [Utility getDateDescriptionForChat:serverTime];
        }
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[chatInfo objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        cell.lblName.text = [chatInfo objectForKey:@"name"];
        cell.lblTime.text = localDateTime;
        UIImage *bgImage = nil;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 1.2f;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14],
                                     NSParagraphStyleAttributeName:paragraphStyle,
                                     };
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:message attributes:attributes];
        cell.lblMessage.attributedText = attributedText;
        if ([sender isEqualToString:@"OTHERS"])
            bgImage = [[UIImage imageNamed:@"Chat_White_buble.png"] stretchableImageWithLeftCapWidth:25  topCapHeight:10];
        else
            bgImage = [[UIImage imageNamed:@"Chat_Green_buble"] stretchableImageWithLeftCapWidth:25  topCapHeight:10];
        cell.imgBg.image = bgImage;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
   
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self resetHeightConstraints];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    /**! Pagination call !**/
    if (scrollView.contentOffset.y <= 0){
        
        if(isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
            
            NSInteger nextPage = currentPage ;
            nextPage += 1;
            if (nextPage  <= totalPages) {
                isPageRefresing = YES;
                [self loadChatHistoryWithPageNo:nextPage isByPagination:YES];
            }
            
        }

    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    
}


#pragma mark - Growing Text View


- (void)setUpGrowingTextView {
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 60, self.view.frame.size.width - 20 , 50)];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.borderColor = [UIColor getThemeColor].CGColor;
    containerView.layer.cornerRadius = 25.f;
    containerView.layer.borderWidth = 1.f;
    containerView.clipsToBounds = YES;
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5, 8, containerView.frame.size.width - 50, 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(5, 5, 0, 5);
    textView.layer.borderColor = [UIColor clearColor].CGColor;
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView.font = [UIFont fontWithName:CommonFont size:14];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"Write a message..";
    textView.textColor = [UIColor getThemeColor];
    textView.internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    //textView.keyboardType = UIKeyboardTypeASCIICapable;
    
    // textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [containerView addSubview:textView];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneBtn setImage:[UIImage imageNamed:@"Send_Button"] forState:UIControlStateNormal];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 45, 5, 40, 40);
    [doneBtn addTarget:self action:@selector(postMessage) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:doneBtn];
    btnDone = doneBtn;
    btnDone.alpha = 0.5;
    [btnDone setEnabled:FALSE];
    
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    // set views with new info
    containerView.frame = containerFrame;
    // commit animations
    [UIView commitAnimations];
    [self.view layoutIfNeeded];
    float constant =  keyboardBounds.size.height + containerFrame.size.height;
    tableConstraint.constant = constant;
    [UIView animateWithDuration:.5
                     animations:^{
                         [self.view layoutIfNeeded];
                          // Called on parent view
                     }];
   
    
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height - 10;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    // set views with new info
    containerView.frame = containerFrame;
    // commit animations
    [UIView commitAnimations];
    tableConstraint.constant = 70;
    [UIView animateWithDuration:.5
                     animations:^{
                         [self.view layoutIfNeeded];
                         // Called on parent view
                     }];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
}
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    
    [btnDone setEnabled:TRUE];
    btnDone.enabled = YES;
    btnDone.alpha = 1;
    NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length > 0) [btnDone setEnabled:TRUE];
    else{
        
        btnDone.enabled = NO;
        btnDone.alpha = 0.5;
        [btnDone setEnabled:FALSE];
    }
    
}
#pragma mark -  Chat Operations


-(void)postMessage{
    
    if (textView.text.length > 0) {
        NSString *message = textView.text;
        
        [APIMapper postChatMessageWithGameID:_strGameID toUserID:_strUserID message:message success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            isDataAvailable = true;
            [arrMessages addObject:[responseObject objectForKey:@"data"]];
            [tableView reloadData];
            [self tableScrollToLastCell];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            if (task.responseData)
                [self displayErrorMessgeWithDetails:task.responseData];
            
        }];
        
        textView.text = @"";
    }
}






#pragma mark - Generic Methods



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


-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(IBAction)showUserProfilePage:(UITapGestureRecognizer*)gesture{
    
//    if (NULL_TO_NIL([_chatUserInfo objectForKey:@"chatuser_id"])) {
//        ProfileViewController *profile =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GeneralStoryBoard Identifier:StoryBoardIdentifierForProfile];
//        profile.strUserID = [_chatUserInfo objectForKey:@"chatuser_id"];
//        [self.navigationController pushViewController:profile animated:YES];
//        
//    }
    
    
}


-(void)resetHeightConstraints{
    
    [self.view endEditing:YES];
    tableConstraint.constant = 70;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)tableScrollToLastCell{
    
    if (arrMessages.count ) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:arrMessages.count - 1 inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:YES];
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
    
    [[self navigationController]popViewControllerAnimated:YES];
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
