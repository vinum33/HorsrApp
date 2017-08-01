//
//  MapViewController.h
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>


-(void)showSelectedCategoryDetailsFromMenuList:(NSInteger)index;

-(void)showOverLay;
-(void)clearUserSessions;
-(IBAction)revealSlider;
-(IBAction)showProfilePageWithID:(id)sender;
@end
