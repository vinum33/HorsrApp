//
//  NotificationDisplayView.m
//  Moza
//
//  Created by Purpose Code on 16/05/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#define ACCEPTABLE_CHARECTERS @"0123456789."

#import "PhoneNumberView.h"
#import "Constants.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "NBPhoneNumberUtil.h"

@interface PhoneNumberView(){
    
    IBOutlet UIButton *btnContinue;
    IBOutlet UITextField *txtField;
    NSString * phoneNumber;
    UIView *inputAccView;
    IBOutlet NSLayoutConstraint *bottomConstraint;
    NSArray *countriesList;
    NSString *dialCode;
    
}

@end

@implementation PhoneNumberView



-(void)intialiseViewWithPhoneNumber:(NSString*)_phoneNumber{
    
    txtField.text = _phoneNumber;
    float width = self.frame.size.width - 60;
    UIColor *topColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.16 alpha:1.0];
    UIColor * bottomColor = [UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, width, 40);
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    [btnContinue.layer addSublayer:gradient];
    [btnContinue.layer insertSublayer:gradient atIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
    
    [self createInputAccessoryView];
}

-(void)createInputAccessoryView{
    
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 40.0)];
    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(inputAccView.frame.size.width - 85, 1.0f, 85.0f, 38.0f)];
    [btnDone setTitle:@"DONE" forState:UIControlStateNormal];
    [btnDone setBackgroundColor:[UIColor getThemeColor]];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone.layer.cornerRadius = 5.f;
    btnDone.layer.borderWidth = 1.f;
    btnDone.layer.borderColor = [UIColor clearColor].CGColor;
    btnDone.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
    [inputAccView addSubview:btnDone];
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
    if ((self.frame.size.height / 2 + 90 ) > bottompos ) {
        constant = (self.frame.size.height / 2 + 90) - bottompos;
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


-(void)doneTyping{
    [self endEditing:YES];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
    
    return YES;
}


-(IBAction)doneButtonApplied:(id)sender{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSString *strNumber;
    NSError *anError = nil;
    if (txtField.text.length) {
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        NBPhoneNumber *myNumber = [phoneUtil parseWithPhoneCarrierRegion:txtField.text error:&anError];
        strNumber = [phoneUtil format:myNumber
                             numberFormat:NBEPhoneNumberFormatE164
                                    error:&anError];
        
    }

    [self.delegate closePopUpWithPhoneNumber:strNumber];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
