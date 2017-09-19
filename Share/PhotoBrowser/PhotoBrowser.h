//
//  PhotoBrowser.h
//  PurposeColor
//
//  Created by Purpose Code on 08/09/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol PhotoBrowserDelegate <NSObject>


/*!
 *This method is invoked when user close the audio player view.
 */

-(void)closePhotoBrowserView;

@end





@interface PhotoBrowser : UIView

@property (nonatomic,weak)  id<PhotoBrowserDelegate>delegate;
@property (nonatomic,assign) BOOL isFromAwareness;

-(void)setUpWithImages:(NSArray*)images;

@end
