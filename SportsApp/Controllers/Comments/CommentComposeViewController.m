//
//  ChatComposeViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kSectionCount               1
#define kMinimumCellCount           1



#import "CommentComposeViewController.h"
#import "Constants.h"
#import "CommentCell.h"
#import "HPGrowingTextView.h"
#import "ProfileViewController.h"

@interface CommentComposeViewController () <HPGrowingTextViewDelegate>{
    
    IBOutlet UIView *vwBG;
    IBOutlet UITableView *tableView;
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

@implementation CommentComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self setUpGrowingTextView];
    [self getAllCommentsBy:currentPage isByPagination:NO];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    isDataAvailable = false;
    currentPage = 1;
    arrMessages = [NSMutableArray new];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    tableView.clipsToBounds = YES;
    vwBG.layer.cornerRadius = 5.f;
    vwBG.layer.borderWidth = 1.f;
    vwBG.backgroundColor = [UIColor whiteColor];
    vwBG.layer.borderColor = [UIColor clearColor].CGColor;
    tableView.hidden = true;
    
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


-(void)getAllCommentsBy:(NSInteger)pageNo isByPagination:(BOOL)isPagination{
    
    [self showLoadingScreen];
    
    [APIMapper loadAllCommentsWithCommunityID:_strCommunityID page:pageNo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self hideLoadingScreen];
        [self showAllCommentsWithJSON:responseObject];
        
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
        
    }];
    
    
}

-(void)showAllCommentsWithJSON:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrMessages addObjectsFromArray:[responds objectForKey:@"data"]];
    if (arrMessages.count > 0) isDataAvailable = true;
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
    return arrMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDataAvailable) {
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strAPIErrorMsg];
        return cell;
    }
    CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    if (indexPath.row < arrMessages.count ) {
        
        NSDictionary *comment = (NSDictionary *) [arrMessages objectAtIndex:indexPath.row];
        cell.btnRemove.hidden = true;
        cell.btnRemove.tag = indexPath.row;
        cell.lblName.text = [comment objectForKey:@"firstname"];
        double serverTime = [[comment objectForKey:@"comment_datetime"] doubleValue];
        cell.lblTime.text = [Utility getDateDescriptionForChat:serverTime];
        cell.lblMessage.text = [comment objectForKey:@"comment_txt"];
        [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[comment objectForKey:@"profileurl"]]
                        placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                               }];
        if ([[comment objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId]) {
            cell.btnRemove.hidden = false;
        }
        
        
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


#pragma mark - Growing Text View


- (void)setUpGrowingTextView {
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(25, self.view.frame.size.height - 75, self.view.frame.size.width - 50 , 50)];
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
    textView.placeholder = @"Write a comment..";
    textView.textColor = [UIColor getThemeColor];
    textView.internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    //textView.keyboardType = UIKeyboardTypeASCIICapable;
    
    // textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [containerView addSubview:textView];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneBtn setImage:[UIImage imageNamed:@"Post_Comment"] forState:UIControlStateNormal];
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
    float constant =  keyboardBounds.size.height;
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
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height - 25;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    // set views with new info
    containerView.frame = containerFrame;
    // commit animations
    [UIView commitAnimations];
    tableConstraint.constant = 15;
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
#pragma mark -  Comment Operations


-(void)postMessage{
    
    if (textView.text.length > 0) {
        NSString *message = textView.text;
        
        [APIMapper postCommentWithCommunityID:_strCommunityID message:message success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            textView.text = @"";
            isDataAvailable = true;
            [arrMessages addObject:[responseObject objectForKey:@"data"]];
            [tableView reloadData];
            [[self delegate]updateCommentCountByCount:arrMessages.count atIndex:_objIndex];
            [self tableScrollToLastCell];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            if (task.responseData)
                [self displayErrorMessgeWithDetails:task.responseData];
            
        }];
        
       
    }
}



-(IBAction)deleteComment:(UIButton*)sender{
    
    if (sender.tag < arrMessages.count) {
        NSDictionary *details = arrMessages[sender.tag];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete"
                                                                       message:@"Do you really want to delete the comment?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"DELETE"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  [Utility showLoadingScreenOnView:self.view withTitle:@"Deleting.."];
                                                                  [APIMapper deleteCommentWithCommentID:[details objectForKey:@"comment_id"] OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                      
                                                                      [arrMessages removeObjectAtIndex:sender.tag];
                                                                      if (arrMessages.count <= 0) {
                                                                          strAPIErrorMsg = @"No comments available";
                                                                          isDataAvailable = false;
                                                                      }
                                                                      [tableView reloadData];
                                                                      [Utility hideLoadingScreenFromView:self.view];
                                                                      [[self delegate]updateCommentCountByCount:arrMessages.count atIndex:_objIndex];
                                                                      
                                                                  } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                                                      
                                                                      [Utility hideLoadingScreenFromView:self.view];
                                                                  }];

                                                                  
                                                              }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"CANCEL"
                                                               style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                               }];
        
        [alert addAction:firstAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
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




-(void)tableScrollToLastCell{
    
    if (arrMessages.count ) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:arrMessages.count - 1 inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:YES];
    }
    [self.view endEditing:YES];
    

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
