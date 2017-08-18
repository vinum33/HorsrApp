//
//  InviteOthersCell.h
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMEmojiableBtn.h"

@interface CommunityActionCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,weak) IBOutlet EMEmojiableBtn *btnEmoji;
@property (nonatomic,weak) IBOutlet UIButton *btnShare;


@end
