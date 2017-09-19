//
//  ActionMediaComposeCell.h
//  PurposeColor
//
//  Created by Purpose Code on 25/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MediaCellCellDelegate <NSObject>



/*!
 *This method is invoked when user Clicks "PLAY MEDIA" Button
 */
-(void)playSelectedMediaWithIndex:(NSInteger)tag ;


@optional



@end

@interface MediaCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UIImageView *imgMediaThumbnail;
@property (nonatomic,weak) IBOutlet UIButton *btnDelete;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,weak) IBOutlet UIImageView *videoPlay;

@property (nonatomic,weak)  id<MediaCellCellDelegate>delegate;


@end
