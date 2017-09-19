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


#import "WinnerPopUp.h"
#import "Constants.h"

@interface WinnerPopUp (){
    
    IBOutlet UIView *vwBG;
    IBOutlet UILabel *lblTitle;
}

@end

@implementation WinnerPopUp

-(void)setUp{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    [self addGestureRecognizer:tap];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"You have won the game.Congratulations!"];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithRed:0.30 green:0.64 blue:0.02 alpha:1.0]
                 range:NSMakeRange(22, text.length - 22)];
    [lblTitle setAttributedText: text];
    
    // Tableview Setup
    
    vwBG.layer.cornerRadius = 5.f;
    vwBG.layer.borderWidth = 1.f;
    vwBG.layer.borderColor = [UIColor clearColor].CGColor;

    
    
    // Tap Gesture SetUp
}

-(void)setUpPopUpForOthersWithWinnerName:(NSString*)winnerName;{
    
    NSString *statictxt = @"The game is completed, winner is";
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",statictxt,winnerName]];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithRed:0.30 green:0.64 blue:0.02 alpha:1.0]
                 range:NSMakeRange(statictxt.length, text.length - statictxt.length)];
    [lblTitle setAttributedText: text];
    
}

-(IBAction)closePopUp{
    
    [[self delegate]closeWinnerPopUp];
    
}

@end
