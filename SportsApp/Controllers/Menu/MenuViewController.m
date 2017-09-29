//
//  MenuViewController.m
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

#define kTagForTitle        1
#define kCellHeight         50
#define kHeightForHeader    170
#define kTagForIcon         2

#import "MenuViewController.h"
#import "HomeViewController.h"
#import "Constants.h"

@implementation SWUITableViewCell
@end

@interface MenuViewController (){
    
    IBOutlet UIImageView *imgUser;
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblLocation;
    IBOutlet NSLayoutConstraint *heightForBg;
}

@end

@implementation MenuViewController{
    
    NSMutableArray *arrCategories;
}


- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // configure the destination view controller:
    if ( [sender isKindOfClass:[UITableViewCell class]] ){
    }
}
-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self setUp];
    [self loadAllCategories];
}

-(void)setUp{
    
    arrCategories = [NSMutableArray new];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    imgUser.clipsToBounds = YES;
    imgUser.layer.cornerRadius = 30.f;
    imgUser.layer.borderWidth = 3.f;
    imgUser.backgroundColor = [UIColor whiteColor];
    imgUser.layer.borderColor = [UIColor colorWithRed:0.94 green:0.76 blue:0.46 alpha:1.0].CGColor;
    lblName.text = [User sharedManager].name;
    lblLocation.text = [User sharedManager].location;
    if ([User sharedManager].profileurl.length) {
        
        [imgUser sd_setImageWithURL:[NSURL URLWithString:[User sharedManager].profileurl]
                      placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 
                             }];
    }
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.clipsToBounds = YES;
    _tableView.layer.cornerRadius = 5.f;
    _tableView.layer.borderWidth = 1.f;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)loadAllCategories{
    
    [arrCategories addObject:@"Start New Game"];
    [arrCategories addObject:@"Community"];
    [arrCategories addObject:@"All Games"];
    [arrCategories addObject:@"Notifications"];
    [arrCategories addObject:@"Chat"];
    [arrCategories addObject:@"Settings"];
    [arrCategories addObject:@"Logout"];
    [_tableView reloadData];
}

-(void)reloadUserData{
    
    lblName.text = [User sharedManager].name;
    lblLocation.text = [User sharedManager].location;
    if ([User sharedManager].profileurl.length) {
        
        [imgUser sd_setImageWithURL:[NSURL URLWithString:[User sharedManager].profileurl]
                   placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                              
                          }];
    }
    
    [_tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    }else{
        return 1;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    UIImageView *imgIcon;
    if ([[cell contentView]viewWithTag:kTagForIcon]) {
        imgIcon = (UIImageView*)[[cell contentView]viewWithTag:kTagForIcon];
    }
    NSInteger index = indexPath.row;
    if (indexPath.section == 1) {
        index += arrCategories.count - 1;
    }
    NSString *title;
    if (index < arrCategories.count) {
        title = arrCategories [index];
    }
    if ([[cell contentView]viewWithTag:kTagForTitle]) {
        UILabel *lblTitle = (UILabel*)[[cell contentView]viewWithTag:kTagForTitle];
        lblTitle.text = title;
    }
    
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                imgIcon.image = [UIImage imageNamed:@"Create_Game_Menu"];
                break;
            case 1:
                imgIcon.image = [UIImage imageNamed:@"Shared_Video"];
                break;
            case 2:
                imgIcon.image = [UIImage imageNamed:@"Menu_All_Games"];
                break;
            case 3:
                imgIcon.image = [UIImage imageNamed:@"Notification_Black"];
                break;
            case 4:
                imgIcon.image = [UIImage imageNamed:@"Menu_Chat"];
                break;
            case 5:
                imgIcon.image = [UIImage imageNamed:@"Settings"];
                break;
           
            default:
                break;
        }

    }else{
        switch (indexPath.row) {
            case 0:
                imgIcon.image = [UIImage imageNamed:@"Logout"];
                break;
                
                
            default:
                break;
        }

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < arrCategories.count) {
        
        /**! Get RootVC from the navigation controller.Since SWReavealcontroller is initialised by two NAV Controller on Front and Rear.!**/
        UINavigationController *navController = (UINavigationController*)self.revealViewController.frontViewController;
        NSArray *viewControllers = navController.viewControllers;
        if (viewControllers.count) {
            HomeViewController *homeVC = viewControllers[0];
            NSInteger clickdIndex = indexPath.row;
            if (indexPath.section == 1) {
                 clickdIndex += arrCategories.count - 1;
            }
            [homeVC showSelectedCategoryDetailsFromMenuList:clickdIndex];
        }
    }
    [self.revealViewController revealToggleAnimated:YES];
    
}

- (nullable UIView *)tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section{
    
        return nil;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return 0;
    }
        return 50;
}


-(IBAction)showProfile:(id)sender{
    
    UINavigationController *navController = (UINavigationController*)self.revealViewController.frontViewController;
    NSArray *viewControllers = navController.viewControllers;
    if (viewControllers.count) {
        HomeViewController *homeVC = viewControllers[0];
        [homeVC showSelectedCategoryDetailsFromMenuList:7];
    }
    [self.revealViewController revealToggleAnimated:YES];
}


-(IBAction)closeSlider:(id)sender{
    
    [self.revealViewController revealToggleAnimated:YES];
}


#pragma mark state preservation / restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO save what you need here
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO restore what you need here
    
    [super decodeRestorableStateWithCoder:coder];
}

- (void)applicationFinishedRestoringState {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO call whatever function you need to visually restore
}

@end
