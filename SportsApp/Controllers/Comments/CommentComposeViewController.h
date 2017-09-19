//
//  ChatComposeViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CommentPopUpDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closePopUp;

-(void)updateCommentCountByCount:(NSInteger)count atIndex:(NSInteger)index;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end


@interface CommentComposeViewController : UIViewController

@property (nonatomic,strong) NSString *strCommunityID;
@property (nonatomic,assign) NSInteger objIndex;
@property (nonatomic,weak)  id<CommentPopUpDelegate>delegate;


@end
