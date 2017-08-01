//
//  LocationAutoSearchViewController.h
//  Moza
//
//  Created by Purpose Code on 06/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchLocationDelegate <NSObject>


@optional

-(void)locationSearchedWithInfo:(NSString*)city address:(NSString*)address latitude:(double)latitude longitude:(double)longitude;


@end




@interface LocationAutoSearchViewController : UIViewController

@property (nonatomic,weak)  id<SearchLocationDelegate>delegate;

@end
