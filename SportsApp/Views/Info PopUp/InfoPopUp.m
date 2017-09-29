//
//  ForgotPasswordPopUp.m
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//



#define kHeightForHeader 50;
#define kHeightForTable 200
#define kWidthForTable 300

#define StatusSucess 200


#import "InfoPopUp.h"
#import "Constants.h"

@interface InfoPopUp (){
    
    NSString *strTitle;
    IBOutlet UIView *vwBG;
    IBOutlet UIButton *btnSend;
    IBOutlet UILabel *lblTitle;
    IBOutlet UITextView *txtView;
    IBOutlet NSLayoutConstraint *bottomConstraint;
    BOOL isUpdated;
    
}

@end

@implementation InfoPopUp

-(void)setUpWithTitle:(NSString*)title{
    
    strTitle = title;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    [self addGestureRecognizer:tap];
    self.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.6];
    
    // Tableview Setup
    
    txtView.layer.borderColor = [[UIColor getSeperatorColor] CGColor];
    txtView.layer.borderWidth = 1.0f;
    txtView.layer.cornerRadius = 10.0f;
    txtView.text = title;
    
    vwBG.layer.borderWidth = 1.f;
    vwBG.layer.borderColor = [UIColor clearColor].CGColor;
    vwBG.layer.cornerRadius = 5.f;
    
    lblTitle.text = title;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    float width = self.frame.size.width - 80;
    UIColor *topColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.16 alpha:1.0];
    UIColor * bottomColor = [UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, width, 40);
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    
    [btnSend.layer addSublayer:gradient];
    [btnSend.layer insertSublayer:gradient atIndex:0];
    btnSend.layer.borderColor = [[UIColor clearColor] CGColor];
    btnSend.layer.borderWidth = 1.0f;
    btnSend.layer.cornerRadius = 17.0f;
    btnSend.clipsToBounds = YES;

    
    // Tap Gesture SetUp
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    // get a rect for the textView frame
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    // set views with new info
    // commit animations
    [UIView commitAnimations];
    [self layoutIfNeeded];
    float constant =  0;
    float bottompos = self.frame.size.height - keyboardBounds.size.height;
    if ((self.frame.size.height / 2 + 125 ) > bottompos ) {
        constant = (self.frame.size.height / 2 + 125) - bottompos;
    }
    bottomConstraint.constant = - constant;
    [UIView animateWithDuration:.5
                     animations:^{
                         [self layoutIfNeeded];
                         // Called on parent view
                     }];
    
    
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // get a rect for the textView frame
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    // set views with new info
    // commit animations
    [UIView commitAnimations];
    bottomConstraint.constant = 0;
    [UIView animateWithDuration:.5
                     animations:^{
                         [self layoutIfNeeded];
                         // Called on parent view
                     }];
}

-(IBAction)submit:(id)sender{
    
    if (txtView.text){
        
        [Utility showLoadingScreenOnView:self withTitle:@"Loading.."];
        [APIMapper updateGameStatusWithGameID:_strGameID statusMsg:txtView.text OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            isUpdated = true;
            [Utility hideLoadingScreenFromView:self];
            [self closePopUp];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            [Utility hideLoadingScreenFromView:self];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        }];
    }
   
}


-(IBAction)closePopUp{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[self delegate]closeInfoPopUp:isUpdated];
    
}

@end
