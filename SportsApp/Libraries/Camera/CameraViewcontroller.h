//
//  HomeViewController.h
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"

@protocol CameraRecordDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)recordCompletedWithOutOutURL:(NSURL*)outputURL;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end


@interface CameraViewcontroller : UIViewController

@property (nonatomic,weak)  id<CameraRecordDelegate>delegate;
@property (nonatomic,assign) NSInteger timeLength  ;

@end
