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


#import "StatisticsPopUp.h"
#import "Constants.h"

@interface StatisticsPopUp (){
    
    IBOutlet UIView *vwBG;
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblScore;
}

@end

@implementation StatisticsPopUp

-(void)setUp{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    [self addGestureRecognizer:tap];
    
    // Tableview Setup
    
    vwBG.layer.cornerRadius = 5.f;
    vwBG.layer.borderWidth = 1.f;
    vwBG.layer.borderColor = [UIColor clearColor].CGColor;

    
    
    // Tap Gesture SetUp
}

-(void)setUpPopWithName:(NSString*)name andScore:(NSString*)score;{
    
    NSString *statictxt = [NSString stringWithFormat:@"Your record playing against"] ;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Your record playing against \n %@",name]];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor blackColor]
                 range:NSMakeRange(statictxt.length, text.length - statictxt.length)];
    [text addAttribute:NSFontAttributeName
                 value:[UIFont fontWithName:CommonFontBold size:15]
                 range:NSMakeRange(statictxt.length, text.length - statictxt.length)];
    [lblTitle setAttributedText: text];
    lblScore.text = score;
    
    NSRange range = [score rangeOfString:@"W"];
    if (range.location == NSNotFound) {
    } else {
        text = [[NSMutableAttributedString alloc] initWithString:score];
        [text addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithRed:0.04 green:0.71 blue:0.00 alpha:1.0]
                     range:range];
        [lblScore setAttributedText: text];
    }
    range = [score rangeOfString:@"L"];
    if (range.location == NSNotFound) {
    } else {
        [text addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithRed:0.84 green:0.01 blue:0.01 alpha:1.0]
                     range:range];
        
        [lblScore setAttributedText: text];
    }
    
}

-(IBAction)closePopUp{
    
    [[self delegate]closeStatisticsPopUp];
    
}

@end
