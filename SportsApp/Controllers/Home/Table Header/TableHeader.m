//
//  AwarenessHeader.m
//  PurposeColor
//
//  Created by Purpose Code on 03/04/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "TableHeader.h"

@interface TableHeader(){
    
    IBOutlet NSLayoutConstraint *vwAnimationHeight;
    IBOutlet NSLayoutConstraint *vwAnimationWidth;
    IBOutlet UIView *vwAnimaiton;

    
    BOOL isOpened;
    
    
}

@end

@implementation TableHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib{
    
    [super awakeFromNib];
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 35.f;
    _imgUser.layer.borderWidth = 3.f;
    _imgUser.backgroundColor = [UIColor whiteColor];
    _imgUser.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _vwRegHolder.clipsToBounds = YES;
    _vwRegHolder.layer.cornerRadius = 15.f;
    _vwRegHolder.layer.borderWidth = 1.f;
    _vwRegHolder.layer.borderColor = [UIColor clearColor].CGColor;
    
    _imgPrviewLeft.clipsToBounds = YES;
    _imgPrviewLeft.layer.cornerRadius = 5.f;
    _imgPrviewLeft.layer.borderWidth = 1.f;
    _imgPrviewLeft.backgroundColor = [UIColor clearColor];
    _imgPrviewLeft.layer.borderColor = [UIColor clearColor].CGColor;
    
    _imgPrviewRight.clipsToBounds = YES;
    _imgPrviewRight.layer.cornerRadius = 5.f;
    _imgPrviewRight.layer.borderWidth = 1.f;
    _imgPrviewRight.backgroundColor = [UIColor clearColor];
    _imgPrviewRight.layer.borderColor = [UIColor clearColor].CGColor;
    
    _btnMenu.layer.cornerRadius = 20.f;
    _btnMenu.layer.borderWidth = 1.f;
    _btnMenu.layer.borderColor = [UIColor clearColor].CGColor;
    
    
    vwAnimaiton.layer.cornerRadius = 80.f;
    vwAnimaiton.layer.borderWidth = 1.f;
    vwAnimaiton.layer.borderColor = [UIColor clearColor].CGColor;
    vwAnimaiton.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
}

-(IBAction)animate:(UIButton*)sender{
    
    if (!isOpened) {
        isOpened = true;
        [sender setBackgroundColor:[UIColor getThemeColor]];
        [sender setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             vwAnimaiton.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                            
                         }];
    }else{
        
        isOpened = false;
        [sender setBackgroundColor:[UIColor blackColor]];
        [sender setImage:[UIImage imageNamed:@"Round_Menu"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                              vwAnimaiton.transform = CGAffineTransformMakeScale(0.1, 0.1);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }

}

-(IBAction)menuSelectedwithIndex:(UIButton*)sender{
    
    [self animate:_btnMenu];
    [[self delegate]radialMenuClickedWithIndex:sender.tag];
}

 


@end
