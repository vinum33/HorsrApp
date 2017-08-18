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

#import "ContactPickerViewController.h"
#import "Constants.h"
#import "InviteOthersCell.h"
#import "ProfileViewController.h"
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "ChatComposeViewController.h"

@interface ContactPickerViewController () <MFMessageComposeViewControllerDelegate>{
    
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UITableView* tableView;
    IBOutlet UISearchBar *searchBar;
    NSMutableArray *arrDataSource;
    NSMutableArray *arrFiltered;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages;
    NSInteger currentPage;
    NSString *strAPIErrorMsg;
    
    
    
    
}

@end

@implementation ContactPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllFriendsWithPageNumber:currentPage isPagination:NO];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    currentPage = 1;
    arrDataSource = [NSMutableArray new];
    arrFiltered = [NSMutableArray new];
    
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
        [searchTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Search Contacts" attributes:@{NSForegroundColorAttributeName: color}]];
    }
    [searchBar setImage:[UIImage imageNamed:@"Search_50"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [searchBar setImage:[UIImage imageNamed:@"Clear"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:CommonFont size:14]];
}



-(IBAction)clearClicked:(id)sender{
    [self getAllFriendsWithPageNumber:currentPage isPagination:NO];
    [self.view endEditing:YES];
}


-(void)getAllFriendsWithPageNumber:(NSInteger)pageNumber isPagination:(BOOL)isPagination{
    
    if (!isPagination) {
        [Utility showLoadingScreenOnView:self.view withTitle:@"Loading.."];
    }
    
    [APIMapper getAllMyFriendsPageNumber:pageNumber onSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = false;
        [self showAllUsersWithJSON:responseObject];
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

-(void)showAllUsersWithJSON:(NSDictionary*)responds{
    
    [arrFiltered removeAllObjects];
    [arrDataSource removeAllObjects];
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[responds objectForKey:@"data"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
//    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"pageCount"]))
//        totalPages =  [[[responds objectForKey:@"data"] objectForKey:@"pageCount"] integerValue];
//    if (NULL_TO_NIL([[responds objectForKey:@"data"] objectForKey:@"currentPage"]))
//        currentPage =  [[[responds objectForKey:@"data"] objectForKey:@"currentPage"] integerValue];
   
    arrFiltered = [NSMutableArray arrayWithArray:arrDataSource];
    [self getUserPermission];
    
    
}

#pragma mark - Contact Picker

-(void)getUserPermission{
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            [self getAllContacts];
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self getAllContacts];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }}

- (IBAction)getAllContacts {
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    [self getContactsWithAddressBook:addressBook];
    
}

// Get the contacts.
- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    
    NSMutableArray *contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        BOOL isPhoneAvailable = false;
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        NSString *name;
        if (firstName) name = [NSString stringWithFormat:@"%@", firstName];
        if (lastName) name = [NSString stringWithFormat:@"%@ %@",name,lastName];
        [dOfPerson setObject:[NSString stringWithFormat:@"%@",name] forKey:@"name"];
        
        // For getting the user image.
        UIImage *contactImage;
        if(ABPersonHasImageData(ref)){
            contactImage = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(ref)];
            [dOfPerson setObject:contactImage forKey:@"contact_image"];
        }
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0) {
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
        }
        //For Phone number
        NSString* mobileLabel;
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            //            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            //            {
            //                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
            //            }
            //            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            //            {
            //                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
            //                break ;
            //            }
            [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
            isPhoneAvailable = true;
            break;
            
        }
        [dOfPerson setObject:[NSNumber numberWithBool:YES] forKey:@"PhoneContact"];
        if (name.length && isPhoneAvailable) {
            [contactList addObject:dOfPerson];
        }
        
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [arrDataSource addObjectsFromArray:contactList];
        [arrFiltered addObjectsFromArray:contactList];
        [tableView reloadData];
    });
    
    
    
    //NSLog(@"Contacts = %@",contactList);
}



#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = arrFiltered.count;
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
    
    NSString *CellIdentifier = @"HorseAppContact";
    InviteOthersCell *cell;
    if (indexPath.row < arrFiltered.count) {
        NSDictionary *people = arrFiltered[indexPath.row];
        BOOL isPhoneContact = false;
        if ([[people objectForKey:@"PhoneContact"] boolValue]) {
             CellIdentifier = @"PhoneContact";
            isPhoneContact = true;
        }
        cell = (InviteOthersCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.btnSMS.tag = indexPath.row;
        cell.btnChat.tag = indexPath.row;
        cell.imgUser.image = [UIImage imageNamed:@"NoImage"];
        cell.lblName.text = [people objectForKey:@"name"];
        if (isPhoneContact) {
            cell.lblLoc.text = [people objectForKey:@"Phone"];
            if ([people objectForKey:@"contact_image"]) {
                [cell.imgUser setImage:[people objectForKey:@"contact_image"]];
            }
           
        }else{
            
            cell.lblLoc.text = [people objectForKey:@"location"];
            [cell.imgUser sd_setImageWithURL:[NSURL URLWithString:[people objectForKey:@"profileurl"]]
                            placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       
                                   }];
        }
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}

-(IBAction)sendSMS:(UIButton*)sender{
    
    NSDictionary *people = arrFiltered[sender.tag];
    if ([[people objectForKey:@"PhoneContact"] boolValue]) {
        [self sendSMSWithMessage:@"Error Error Domain=NSCocoaErrorDomain Code=3010" andNumber:[NSArray arrayWithObjects:[people objectForKey:@"Phone"], nil] ];
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

-(void)callSearchWebService:(NSString*)searchString{
    
    [arrFiltered removeAllObjects];
    if (searchString.length > 0) {
        if (arrDataSource.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSString *regexString  = [NSString stringWithFormat:@".*\\b%@.*", searchString];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name matches[cd] %@", regexString];
                // NSPredicate *predicate =[NSPredicate predicateWithFormat:@"ANY words BEGINSWITH[c] %@",searchString];
                arrFiltered = [NSMutableArray arrayWithArray:[arrDataSource filteredArrayUsingPredicate:predicate]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    isDataAvailable = true;
                    if (arrFiltered.count <= 0)isDataAvailable = false;
                     strAPIErrorMsg = @"No contacts found.";
                    [tableView reloadData];
                });
            });
            
        }
    }else{
        if (arrDataSource.count > 0) {
            if (searchBar.text.length > 0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSString *regexString  = [NSString stringWithFormat:@".*\\b%@.*", searchString];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name matches[cd] %@", regexString];
                    arrFiltered = [NSMutableArray arrayWithArray:[arrDataSource filteredArrayUsingPredicate:predicate]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        isDataAvailable = true;
                        if (arrFiltered.count <= 0)isDataAvailable = false;
                        strAPIErrorMsg = @"No contacts found.";
                        [tableView reloadData];
                    });
                });
            }else{
                
                arrFiltered = [NSMutableArray arrayWithArray:arrDataSource];
                dispatch_async(dispatch_get_main_queue(), ^{
                    isDataAvailable = true;
                    if (arrFiltered.count <= 0)isDataAvailable = false;
                     strAPIErrorMsg = @"No contacts found.";
                    [tableView reloadData];
                });
            }
            
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
        [arrFiltered removeAllObjects];
        [tableView reloadData];
        
    }
    
}

-(IBAction)doneApplied:(id)sender{
    
    
}

#pragma mark - SMS COMPOSER

- (void)sendSMSWithMessage:(NSString*)message andNumber:(NSArray*)recipents {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)composeChat:(UIButton*)btn{
    
    ChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForChatComposer];
    if (btn.tag < arrFiltered.count) {
        NSDictionary *details = arrFiltered[btn.tag];
        if ([details objectForKey:@"user_id"]) {
            chatCompose.strUserID = [details objectForKey:@"user_id"];
        }
    }
    [[self navigationController]pushViewController:chatCompose animated:YES];
    
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
