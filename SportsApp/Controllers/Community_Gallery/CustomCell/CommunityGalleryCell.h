//
//  ComposeMessageTableViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommunityGalleryCell : UITableViewCell


@property (nonatomic,weak) IBOutlet UIImageView *imgGallery;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,weak) IBOutlet UIImageView *imgVideo;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *constraintForHeight;




@end
