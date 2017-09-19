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

@interface NotificationHeader : UIView

@property (nonatomic,weak) IBOutlet UILabel *lblDate;
@property (nonatomic,weak) IBOutlet UIImageView *imgThumb;



@property (nonatomic,weak) IBOutlet UIButton *btnMenu;

@property (nonatomic,weak)  id<RadialMenuDelegate>delegate;



@end
