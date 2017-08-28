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
#import "Base64.h"
#import<CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "NBPhoneNumberUtil.h"

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
    [self getUserPermission];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    

    [Base64 initialize];
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
    [self.view endEditing:YES];
    [arrFiltered removeAllObjects];
    [arrFiltered addObjectsFromArray:arrDataSource];
    [tableView reloadData];
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
    [Utility showLoadingScreenOnView:self.view withTitle:@"Syncing contacts.."];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSMutableArray *arrContacts = [NSMutableArray new];
    for (int i=0;i < nPeople;i++) {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            NSString *phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            NSError *anError = nil;
            NBPhoneNumber *myNumber = [phoneUtil parseWithPhoneCarrierRegion:phoneNumber error:&anError];
            if (anError == nil) {
                NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
                if(ABPersonHasImageData(ref)){
                    NSData  *imageData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
                    NSString *strEncoded = [Base64 encode:imageData];
                    [dOfPerson setObject:strEncoded forKey:@"image"];
                }
                CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, i);
                NSString *mobileLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
                if (!mobileLabel.length) {
                    mobileLabel = @"Phone";
                }
                CFStringRef firstName, lastName;
                firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
                lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
                NSString *name;
                if (firstName) name = [NSString stringWithFormat:@"%@",firstName];
                if (lastName) name = [NSString stringWithFormat:@"%@ %@",name,lastName];
                [dOfPerson setObject:[NSString stringWithFormat:@"%@",name] forKey:@"name"];
                [dOfPerson setObject:[NSString stringWithFormat:@"%@",mobileLabel] forKey:@"type"];
                [dOfPerson setObject:[phoneUtil format:myNumber
                                          numberFormat:NBEPhoneNumberFormatE164
                                                 error:&anError] forKey:@"phone"];
                [arrContacts addObject:dOfPerson];
            }
        }
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self sendContactsToBakendWith:arrContacts];
    });
    
    
}


-(void)sendContactsToBakendWith:(NSMutableArray*)arrContacts{
    
    if (arrContacts.count) {
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:arrContacts,@"contacts", nil];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [APIMapper syncContactsWith:jsonString OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
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
 
    
}

-(void)showAllUsersWithJSON:(NSDictionary*)responds{
    
    [arrFiltered removeAllObjects];
    [arrDataSource removeAllObjects];
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"data"]))
        [arrDataSource addObjectsFromArray:[responds objectForKey:@"data"]];
    if (arrDataSource.count > 0) isDataAvailable = true;
    arrFiltered = [NSMutableArray arrayWithArray:arrDataSource];
    [tableView reloadData];
    
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
    NSString *CellIdentifier = @"PhoneContact";
    InviteOthersCell *cell;
    if (indexPath.row < arrFiltered.count) {
        NSDictionary *people = arrFiltered[indexPath.row];
        cell = (InviteOthersCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.btnInvite.tag = indexPath.row;
        cell.btnChat.tag = indexPath.row;
        cell.btnInvite.clipsToBounds = YES;
        cell.btnInvite.layer.cornerRadius = 5.f;
        cell.btnInvite.layer.borderWidth = 1.f;
        cell.btnInvite.layer.borderColor = [UIColor getThemeColor].CGColor;
        cell.imgUser.image = [UIImage imageNamed:@"UserProfilePic"];
        if (NULL_TO_NIL([people objectForKey:@"image"])) {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [Base64 decode:[people objectForKey:@"image"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                   cell.imgUser.image = [UIImage imageWithData:data];
                });
                
            });
        }
        cell.lblName.text = [people objectForKey:@"name"];
        cell.lblLoc.text = [people objectForKey:@"phone"];
        cell.lblType.text = [people objectForKey:@"type"];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}

-(IBAction)sendSMS:(UIButton*)sender{
    
    NSDictionary *people = arrFiltered[sender.tag];
    [self sendSMSWithMessage:@"Install HorseApp from the link." andNumber:[NSArray arrayWithObjects:[people objectForKey:@"phone"], nil] ];
    
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
