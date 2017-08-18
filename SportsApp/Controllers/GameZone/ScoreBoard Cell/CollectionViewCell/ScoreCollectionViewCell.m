//
//  CollectionViewCell.m
//  SportsApp
//
//  Created by Purpose Code on 27/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "ScoreCollectionViewCell.h"
#import "Constants.h"

@interface ScoreCollectionViewCell(){
    
}

@end

@implementation ScoreCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 25.f;
    _imgUser.layer.borderWidth = 2.f;
    _imgUser.backgroundColor = [UIColor clearColor];
    _imgUser.layer.borderColor =[UIColor colorWithRed:0.97 green:0.89 blue:0.82 alpha:1.0].CGColor;
    
    
    
    // Initialization code
}

-(void)setUpBgWithFrame:(float)frame{
    
    float width = frame;
    UIColor *topColor = [UIColor colorWithRed:1.00 green:0.80 blue:0.16 alpha:1.0];
    UIColor * bottomColor = [UIColor colorWithRed:1.00 green:0.52 blue:0.16 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, width, 80);
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    
    [_vwBG.layer addSublayer:gradient];
    [_vwBG.layer insertSublayer:gradient atIndex:0];
}

-(void)setScoreWithLetters:(NSString*)_letters andGameType:(NSInteger)_gameType{
    
    float trailingSpace = -20;
    NSInteger length = 5 ;
    NSString *letters = _letters;
    if (_gameType == 2) {
        trailingSpace = -40;
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
    NSInteger height = 30;
    
    if ([self.contentView viewWithTag:-1]) {
        [[self.contentView viewWithTag:-1] removeFromSuperview];
    }
    
    UIView *vwScore = [UIView new];
    vwScore.translatesAutoresizingMaskIntoConstraints = NO;
    vwScore.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:vwScore];
    vwScore.tag = -1;
    
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
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:vwScore
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.contentView
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:trailingSpace]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:vwScore
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.contentView
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:-2]];
    
    UIView *vwLstView ;
    
    for (NSInteger i = length - 1; i >= 0; i --) {
        
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
        
        lblScore.font = [UIFont fontWithName:CommonFont size:18];
        lblScore.textColor = [UIColor whiteColor];
        lblScore.textAlignment = NSTextAlignmentCenter;
        
        UIView *vwBorder = [UIView new];
        vwBorder.translatesAutoresizingMaskIntoConstraints = NO;
        [vwChar addSubview:vwBorder];
        vwBorder.backgroundColor = [UIColor whiteColor];
        [vwChar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-28-[vwBorder]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwBorder)]];
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
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:vwScore
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:0]];
        }else{
            [vwScore addConstraint:[NSLayoutConstraint constraintWithItem:vwChar
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:vwLstView
                                                                attribute:NSLayoutAttributeLeading
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




@end
