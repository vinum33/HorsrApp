//
//  ChatComposeViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CommunityGalleryPopUpDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closeGalleryPopUp;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end


@interface CommunityGalleryViewController : UIViewController

@property (nonatomic,strong) NSArray *gallery;
@property (nonatomic,weak)  id<CommunityGalleryPopUpDelegate>delegate;


@end
