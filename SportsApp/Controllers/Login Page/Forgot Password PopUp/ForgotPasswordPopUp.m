//
//  ForgotPasswordPopUp.m
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//



#define kCellHeight   120;
#define kHeightForHeader 50;
#define kHeightForFooter 40;
#define kHeightForTable 220
#define kWidthForTable 300

#define StatusSucess 200


#import "ForgotPasswordPopUp.h"
#import "Constants.h"



@implementation ForgotPasswordPopUp

-(void)setUp{
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    // Tableview Setup
    
    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.layer.borderColor = [UIColor clearColor].CGColor;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.allowsSelection = NO;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.layer.borderColor = [[UIColor clearColor] CGColor];
    tableView.layer.borderWidth = 1.0f;
    tableView.layer.cornerRadius = 5.0f;
    [self addSubview:tableView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    NSLayoutConstraint *yValueForTable = [NSLayoutConstraint constraintWithItem:tableView
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1.0
                                                   constant:0.0];
    
    [self addConstraint:yValueForTable];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:kWidthForTable]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:NSLayoutAttributeHeight
                                                 multiplier:1.0
                                                   constant:kHeightForTable]];
    
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    // Tap Gesture SetUp
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [self addGestureRecognizer:gesture];
}



#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor =  [UIColor clearColor];
    // Container with Border
    
    UIView *container = [UIView new];
    [cell.contentView addSubview:container];
    container.backgroundColor = [UIColor clearColor];
    container.layer.borderWidth = 1.f;
    container.layer.cornerRadius = 25.f;
    container.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-35-[container]-35-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(container)]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[container]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(container)]];

    //Email Icon
    
    
    
    // Entry Text Field
    
    UITextField *textField = [UITextField new];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:textField];
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[textField]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textField)]];
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[textField]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textField)]];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter your email address" attributes:@{NSForegroundColorAttributeName: [UIColor getBlackTextColor]}];
    textField.font= [UIFont fontWithName:CommonFont size:15];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.delegate = self;
    textField.textColor = [UIColor getBlackTextColor];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailField = textField;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor clearColor];
    
    UILabel *lblTitle = [UILabel new];
    lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblTitle];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    lblTitle.text = @"Forgot Password";
    lblTitle.font = [UIFont fontWithName:CommonFont size:18];
    lblTitle.textColor = [UIColor getBlackTextColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    
    return vwHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeightForHeader;
}

- (nullable UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section{
    
    UIView *vwFooter = [UIView new];
    vwFooter.backgroundColor = [UIColor clearColor];
    
    UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [vwFooter addSubview:btnSend];
    btnSend.translatesAutoresizingMaskIntoConstraints = NO;
    [btnSend addTarget:self action:@selector(forgetPasswordClicked)
    forControlEvents:UIControlEventTouchUpInside];
    btnSend.layer.borderColor = [UIColor clearColor].CGColor;
    btnSend.titleLabel.font = [UIFont fontWithName:CommonFontBold size:16];
    [btnSend setTitle:@"Submit" forState:UIControlStateNormal];
    [btnSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSend setBackgroundColor:[UIColor getThemeColor]];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[btnSend]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnSend)]];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[btnSend]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnSend)]];
    btnSend.layer.borderColor = [[UIColor clearColor] CGColor];
    btnSend.layer.borderWidth = 1.0f;
    btnSend.layer.cornerRadius = 20.0f;
    btnSend.clipsToBounds = YES;
    
    float width = aTableView.frame.size.width - 20;
    UIColor *topColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.16 alpha:1.0];
    UIColor * bottomColor = [UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, width, 40);
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);

    [btnSend.layer addSublayer:gradient];
    [btnSend.layer insertSublayer:gradient atIndex:0];
    
    return vwFooter;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return kHeightForFooter;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    NSIndexPath *indexPath;
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height - 60 );
    [tableView setContentOffset:contentOffset animated:YES];
    
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height - 60);
    [tableView setContentOffset:contentOffset animated:YES];
    
}





#pragma mark - Common Delegates


-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    
     [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:tableView])
        return NO;
    return YES;
}

-(void)forgetPasswordClicked{
    
    [self checkAllFieldsAreValid:^{
        
         [self showLoadingScreen];
        
        [APIMapper forgotPasswordWithEmail:emailField.text success:^(AFHTTPRequestOperation *operation, id responseObject){
            NSDictionary *responds = (NSDictionary*)responseObject;
            if (NULL_TO_NIL([responds objectForKey:@"text"])) {
                [self showAlertWithTitle:@"Forgot Password" message:[responds objectForKey:@"text"]];
                [self closePopUp];
            }
            [self hideLoadingScreen];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if (operation.responseObject) {
                NSDictionary *responds = (NSDictionary*) operation.responseObject;
                if ([responds objectForKey:@"text"]) {
                    [self showAlertWithTitle:@"Forgot Password" message:[responds objectForKey:@"text"]];
                }
            }

            [self hideLoadingScreen];
        }];

        
        
    } failure:^(NSString *errorMessage) {
    
        if (errorMessage.length) {
           
            [self showAlertWithTitle:@"Forgot Password" message:errorMessage];
        }
       
        
    }];
        
 
}

-(void)checkAllFieldsAreValid:(void (^)())success failure:(void (^)(NSString *errorMessage))failure{
    
    NSString *errorMessage;
    NSString *email = emailField.text;
    BOOL isValid = false;
    errorMessage = @"Enter a valid Email address";
    if ((emailField.text.length) > 0){
        isValid = [email isValidEmail] ? YES : NO;
    }
    if (isValid)success();
    else failure(errorMessage);
    
}


-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self animated:YES];
    
}



-(IBAction)closePopUp{
    
    [[self delegate]closeForgotPwdPopUpAfterADelay:0];
    
}

@end
