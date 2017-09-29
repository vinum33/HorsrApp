//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//






#import "Constants.h"
#import "PlayerListTableViewCell.h"
#import "ProfileViewController.h"
#import "FriendRequestManager.h"
#import "SearchFriendsViewController.h"
#import "ContactPickerViewController.h"
#import "FriendRequestsViewController.h"


@interface FriendRequestManager () {
    
    IBOutlet UISegmentedControl *segmentControll;
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet UISearchBar *searchBar;
    SearchFriendsViewController *searchVC;
    FriendRequestsViewController *friendReqVC;
    ContactPickerViewController *contactVC;
}

@end

@implementation FriendRequestManager

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self showFriendRequets];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    searchBar.tintColor = [UIColor getThemeColor];
    UITextField *searchTextField = [searchBar valueForKey:@"_searchField"];
    if ([searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        [searchTextField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: color}]];
    }
    [searchBar setImage:[UIImage imageNamed:@"Search_50"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [searchBar setImage:[UIImage imageNamed:@"Clear"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:CommonFont size:14]];
    
    segmentControll.tintColor = [UIColor whiteColor];
    NSDictionary *attributes1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont fontWithName:CommonFont size:14], NSFontAttributeName,
                                 [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    NSDictionary *attributes2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont fontWithName:CommonFont size:14], NSFontAttributeName,
                                 [UIColor getBlackTextColor], NSForegroundColorAttributeName, nil];
    
    [segmentControll setTitleTextAttributes:attributes1 forState:UIControlStateNormal];
    [segmentControll setTitleTextAttributes:attributes2 forState:UIControlStateSelected];

}
-(void)enableFriendRequestTabFromNotifications{
    
    [segmentControll setSelectedSegmentIndex:eTypeRequests];
    [self segmentChanged:segmentControll];
}

-(IBAction)segmentChanged:(UISegmentedControl*)segment{
    
    switch ([segment selectedSegmentIndex]) {
        case eTypeSearch:
            [self showSearchPeoplePage];
            break;
        case eTypeRequests:
            [self showFriendRequets];
            break;
        case eTypeContacts:
            [self showPhoneContacts];
            break;
            
        default:
            break;
    }
    
    
    
}

-(IBAction)showSearchPeoplePage{
    
    [self hideUnusedViews];
    if (!searchVC) searchVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForSearchFriends];
    UIView *popup = searchVC.view;
    searchBar.delegate = searchVC;
    searchBar.hidden = false;
    [self addChildViewController:searchVC];
    [self.view addSubview:popup];
    [searchVC didMoveToParentViewController:self];
    searchVC.view.hidden = false;
    popup.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-110-[popup]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(popup)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[popup]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(popup)]];
    popup.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        popup.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
    }];

}
-(IBAction)showFriendRequets{
    
    [self hideUnusedViews];
    if (!friendReqVC) friendReqVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForFriendRequest];
    UIView *popup = friendReqVC.view;
    [self addChildViewController:friendReqVC];
    [self.view addSubview:popup];
    [friendReqVC didMoveToParentViewController:self];
    friendReqVC.view.hidden = false;
    popup.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-110-[popup]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(popup)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[popup]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(popup)]];
    popup.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        popup.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
    }];
    
}
-(IBAction)showPhoneContacts{
    
    [self hideUnusedViews];
    searchBar.hidden = false;
    if (!contactVC) contactVC = [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForSlider Identifier:StoryBoardIdentifierForContactPicker];
    UIView *popup = contactVC.view;
    searchBar.delegate = contactVC;
    contactVC.view.hidden = false;
    [self addChildViewController:contactVC];
    [self.view addSubview:popup];
    [contactVC didMoveToParentViewController:self];
    popup.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-110-[popup]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(popup)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[popup]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(popup)]];
    popup.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        popup.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
    }];

}

-(void)hideUnusedViews{
    contactVC.view.hidden = true;
    friendReqVC.view.hidden = true;
    searchVC.view.hidden = true;
    searchBar.hidden = true;
}

-(IBAction)goBack:(id)sender{
    
    [self.view endEditing:YES];
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
