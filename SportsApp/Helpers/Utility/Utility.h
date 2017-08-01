//
//  Utility.h
//  SignSpot
//
//  Created by Purpose Code on 24/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utility : NSObject

+(void)setUpGoogleMapConfiguration;
+ (void)saveUserObject:(User *)object key:(NSString *)key;
+(void)showNoDataScreenOnView:(UIView*)view withTitle:(NSString*)title;
+(void)removeNoDataScreen:(UIView*)_view;
+(UITableViewCell *)getNoDataCustomCellWith:(UITableView*)table withTitle:(NSString*)title;
+(void)removeAViewControllerFromNavStackWithType:(Class)vc from:(NSArray*)array;
+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;
+(void)getErrorDisplayLabelWithMsg:(NSString*)message onView:(UIView*)view;
+(NSString*)getDaysBetweenTwoDatesWith:(double)time;
+(NSInteger)getAgeFromDOBFromDate:(double)timeInSeconds;
+(void)showLoadingScreenOnView:(UIView*)view withTitle:(NSString*)title;
+(void)hideLoadingScreenFromView:(UIView*)view;
+(UIImage*)getThumbNailFromVideoURL:(NSURL*)videoURL;
+ (UIImage *)fixrotation:(UIImage *)image;

@end
