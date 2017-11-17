//
//  ViewController.h
//  Paging_ObjC
//
//  Created by olxios on 23/10/14.
//  Copyright (c) 2014 olxios. All rights reserved.
//


@protocol LikeOrCommentUsersPopUpDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closeComentOrLikeUserPopUp;


/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end


#import <UIKit/UIKit.h>

@interface LikedUserListViewConbtroller : UIViewController


@property (nonatomic,assign) BOOL isTypeLiked;
@property (nonatomic,strong) NSString *strCommunityID;
@property (nonatomic,weak)  id<LikeOrCommentUsersPopUpDelegate>delegate;

@end

