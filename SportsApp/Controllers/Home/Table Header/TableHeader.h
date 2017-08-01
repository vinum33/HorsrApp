//
//  AwarenessHeader.h
//  PurposeColor
//
//  Created by Purpose Code on 03/04/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//


@protocol RadialMenuDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)radialMenuClickedWithIndex:(NSInteger)index;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end

#import <UIKit/UIKit.h>

@interface TableHeader : UIView

@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UILabel *lblRegDate;
@property (nonatomic,weak) IBOutlet UIView *vwRegHolder;
@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UILabel *lblRecentTitle;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *imgHeight;
@property (nonatomic,weak) IBOutlet UIView *vwRecentItems;
@property (nonatomic,weak) IBOutlet UIView *vwRecentLeft;
@property (nonatomic,weak) IBOutlet UIView *vwRecentRight;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *recentWidth;

@property (nonatomic,weak) IBOutlet UIImageView *imgPrviewLeft;
@property (nonatomic,weak) IBOutlet UIImageView *imgPrviewRight;
@property (nonatomic,weak) IBOutlet UILabel *lblPrevwTitlelft;
@property (nonatomic,weak) IBOutlet UILabel *lblPrevwTitleRight;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicatorlft;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicatorRight;

@property (nonatomic,weak) IBOutlet UIButton *btnMenu;

@property (nonatomic,weak)  id<RadialMenuDelegate>delegate;



@end
