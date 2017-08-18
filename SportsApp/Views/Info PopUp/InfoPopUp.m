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
    IBOutlet UILabel *lblTitle;
    
}

@end

@implementation InfoPopUp

-(void)setUpWithTitle:(NSString*)title{
    
    strTitle = title;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    [self addGestureRecognizer:tap];
    self.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.6];
    
    // Tableview Setup
    
    vwBG.layer.borderWidth = 1.f;
    vwBG.layer.borderColor = [UIColor clearColor].CGColor;
    vwBG.layer.cornerRadius = 5.f;
    
    lblTitle.text = title;
    
    
    // Tap Gesture SetUp
}



-(IBAction)closePopUp{
    
    [[self delegate]closeInfoPopUp];
    
}

@end
