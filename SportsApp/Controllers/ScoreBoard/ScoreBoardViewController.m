//
//  NotificationsViewController.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "ScoreBoardViewController.h"
#import "Constants.h"
#import "BSStackView.h"
#import "ScoreBoard.h"
#import "ProfileViewController.h"

@interface ScoreBoardViewController () <BSStackViewProtocol> {
        
    IBOutlet NSLayoutConstraint *constraintForNavBg;
    IBOutlet BSStackView *stackView;
    IBOutlet UIPageControl *pageControl;
    
    
}

@end

@implementation ScoreBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self setUpCardView];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    float width = 720;
    float height = 460;
    float ratio = width / height;
    float imageHeight = (self.view.frame.size.width) / ratio;
    constraintForNavBg.constant = imageHeight;
}

-(void)setUpCardView{
  
    pageControl.numberOfPages = _users.count;
    pageControl.transform = CGAffineTransformMakeScale(1.3, 1.3);
    NSMutableArray *views = [NSMutableArray array];
    ScoreBoard *card;
    for (NSInteger i = 0; i < _users.count; i++) {
        if (i == _clickedIndex) {
            card = [self viewWithLabel:i];
        }else{
             [views addObject:[self viewWithLabel:i]];
        }
    }
    [views insertObject:card atIndex:0];
    stackView.swipeDirections = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    stackView.forwardDirections = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp;
    stackView.backwardDirections = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionDown;
    stackView.changeAlphaOnSendAnimation = YES;
    [stackView configureWithViews:views];
    stackView.delegate = self;
    stackView.layer.shadowColor = [UIColor blackColor].CGColor;
    stackView.layer.shadowOffset = CGSizeMake(5, 5);
    stackView.layer.shadowOpacity = 0.3;
    stackView.layer.shadowRadius = 1.0;


}

- (ScoreBoard *)viewWithLabel:(NSInteger)index {
    
    NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"ScoreBoard" owner:self options:nil];
    ScoreBoard *header = [viewArray objectAtIndex:0];
    
    header.index = index;
    if (index < _users.count) {
        NSDictionary *user = _users[index];
        [self setScoreWithLetters:[user objectForKey:@"score"] andGameType:[[user objectForKey:@"gametype_id"] integerValue] view:header];
        header.btnClick.tag = index;
        header.lblName.text = [user objectForKey:@"name"];
        header.lblLocation.text = [user objectForKey:@"location"];
        [header.imgUser sd_setImageWithURL:[NSURL URLWithString:[user objectForKey:@"profileurl"]]
                          placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     
                                 }];
    }
    
    return header;
}

-(void)setScoreWithLetters:(NSString*)_letters andGameType:(NSInteger)_gameType view:(UIView*)onView{
    
    float padding = 10;
    NSInteger length = 5 ;
    NSString *letters = _letters;
    if (_gameType == 2) {
        length = 3;
    }
    
    NSMutableArray *chars = [NSMutableArray new];
    [letters enumerateSubstringsInRange:NSMakeRange(0, [letters length])
                                options:(NSStringEnumerationByComposedCharacterSequences)
                             usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                 [chars addObject:substring];
                             }];
    
    NSInteger letterCount = chars.count;
    NSInteger width = 18;
    NSInteger height = 25;
    
    UIView *vwScore = [UIView new];
    vwScore.translatesAutoresizingMaskIntoConstraints = NO;
    vwScore.backgroundColor = [UIColor clearColor];
    [onView addSubview:vwScore];
    
    [vwScore addConstraint:[NSLayoutConstraint constraintWithItem:vwScore
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                         constant:height]];
    [vwScore addConstraint:[NSLayoutConstraint constraintWithItem:vwScore
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:letterCount * width]];
    [onView addConstraint:[NSLayoutConstraint constraintWithItem:vwScore
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:onView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:padding]];
    [onView addConstraint:[NSLayoutConstraint constraintWithItem:vwScore
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:onView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-15]];
    
    UIView *vwLstView ;
    
    for (NSInteger i = 0; i < length; i ++) {
        
        
        UIView *vwChar = [UIView new];
        vwChar.translatesAutoresizingMaskIntoConstraints = NO;
        [vwScore addSubview:vwChar];
        
        UILabel *lblScore = [UILabel new];
        lblScore.translatesAutoresizingMaskIntoConstraints = NO;
        lblScore.backgroundColor = [UIColor clearColor];
        [vwChar addSubview:lblScore];
        [vwChar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lblScore]-2-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblScore)]];
        [vwChar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[lblScore]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblScore)]];
        if (i < chars.count) {
            lblScore.text = chars [i];
        }
        
        lblScore.font = [UIFont fontWithName:CommonFont size:16];
        lblScore.textColor = [UIColor whiteColor];
        lblScore.textAlignment = NSTextAlignmentCenter;
        
        UIView *vwBorder = [UIView new];
        vwBorder.translatesAutoresizingMaskIntoConstraints = NO;
        [vwChar addSubview:vwBorder];
        vwBorder.backgroundColor = [UIColor whiteColor];
        [vwChar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-23-[vwBorder]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwBorder)]];
        [vwChar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[vwBorder]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwBorder)]];
        vwChar.backgroundColor = [UIColor clearColor];
        
        [vwChar addConstraint:[NSLayoutConstraint constraintWithItem:vwChar
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:height]];
        [vwChar addConstraint:[NSLayoutConstraint constraintWithItem:vwChar
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:width]];
        if (!vwLstView) {
            [vwScore addConstraint:[NSLayoutConstraint constraintWithItem:vwChar
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:vwScore
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:0]];
        }else{
            [vwScore addConstraint:[NSLayoutConstraint constraintWithItem:vwChar
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:vwLstView
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:0]];
        }
        
        
        [vwScore addConstraint:[NSLayoutConstraint constraintWithItem:vwChar
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:vwScore
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:0]];
        vwLstView = vwChar;
    }
}


- (void)stackView:(BSStackView *)stackView currentItem:(ScoreBoard *)item direction:(BSStackViewItemDirection)direction{
    
    NSInteger currentIndex = item.index + 1;
    if (currentIndex >= _users.count) {
        currentIndex = 0;
    }
    pageControl.currentPage = currentIndex;
}
- (void)stackView:(BSStackView *)stackView willSendItem:(ScoreBoard *)item direction:(BSStackViewItemDirection)direction{
   
    
    
}
- (void)stackView:(BSStackView *)stackView didSendItem:(ScoreBoard *)item direction:(BSStackViewItemDirection)direction{
    
     // NSLog(@"did send send index %ld",(long)item.index);
   
    
}

-(void)showUserProfileFromScroreBoardWithIndex:(NSInteger)index{
    
    if (index < _users.count) {
        NSDictionary *user = _users[index];
        ProfileViewController *games =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GeneralStoryBoard Identifier:StoryBoardIdentifierForProfile];
        [[self navigationController]pushViewController:games animated:YES];
        games.strUserID = [user objectForKey:@"user_id"];
    }
    
   
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
