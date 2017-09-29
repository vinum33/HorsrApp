//
//  Utility.m
//  SignSpot
//
//  Created by Purpose Code on 24/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kTagForNodataScreen    1111

#import "Utility.h"
#import "Constants.h"
#import <GooglePlaces/GooglePlaces.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@import GoogleMaps;

@implementation Utility

+(void)setUpGoogleMapConfiguration{
    
    [GMSServices provideAPIKey:GoogleMapAPIKey];
    [GMSPlacesClient provideAPIKey:GoogleMapAPIKey];
    
}


+ (void)saveUserObject:(User *)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}


+(void)showNoDataScreenOnView:(UIView*)view withTitle:(NSString*)title{
    
    UIView *noDataScreen =[UIView new];
    noDataScreen.tag = kTagForNodataScreen;
    noDataScreen.backgroundColor = [UIColor whiteColor];
    noDataScreen.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:noDataScreen];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-65-[noDataScreen]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noDataScreen)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[noDataScreen]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noDataScreen)]];
    
    UILabel *lblTitle = [UILabel new];
    lblTitle.text = title;
    lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont fontWithName:CommonFont size:17];
    lblTitle.textColor = [UIColor clearColor];
    [noDataScreen addSubview:lblTitle];
    [noDataScreen addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    [noDataScreen addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
   
}

+(void)removeNoDataScreen:(UIView*)_view{
    
    if ([_view viewWithTag:kTagForNodataScreen]) {
        
        [[_view viewWithTag:kTagForNodataScreen] removeFromSuperview];
    }
}
+(UITableViewCell *)getNoDataCustomCellWith:(UITableView*)aTableView withTitle:(NSString*)title{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    cell.textLabel.text = title;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:CommonFont size:15];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

+(void)removeAViewControllerFromNavStackWithType:(Class)vc from:(NSArray*)array{
    
    for(UIViewController *tempVC in array)
    {
        if([tempVC isKindOfClass:vc])
        {
            [tempVC removeFromParentViewController];
        }
    }

    
}

+(void)getErrorDisplayLabelWithMsg:(NSString*)message onView:(UIView*)view{
    
    UILabel *_lblTitle = [UILabel new];
    _lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:_lblTitle];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
    _lblTitle.text = message;
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    _lblTitle.font = [UIFont fontWithName:CommonFont size:14];
    _lblTitle.textColor = [UIColor getBlackTextColor];
    _lblTitle.numberOfLines = 0;
}

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(NSString*)getDaysBetweenTwoDatesWith:(double)timeInSeconds{
    
    NSDate * today = [NSDate date];
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:refDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:today];
//    NSDateComponents *difference = [calendar components:NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute
//                                               fromDate:fromDate toDate:toDate options:0];
    NSString *msgDate;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy EE h:mm a"];
    msgDate = [dateformater stringFromDate:refDate];
    
    /*
    NSInteger days = [difference day];
    if (days > 7) {
        NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
        [dateformater setDateFormat:@"d MMM,yyyy EE h:mm a"];
        msgDate = [dateformater stringFromDate:refDate];
    }
    else if (days <= 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        NSDate *date = refDate;
        msgDate = [dateFormatter stringFromDate:date];
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EE h:mm a"];
        msgDate = [dateFormatter stringFromDate:refDate];
    }
    */
    return msgDate;
    
}


+(NSInteger)getAgeFromDOBFromDate:(double)timeInSeconds{
    
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unitFlags fromDate:refDate toDate:[NSDate date] options:0];
    NSInteger year  = [components year];
    return year;
  
}

+(void)showLoadingScreenOnView:(UIView*)view withTitle:(NSString*)title{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = title;
    hud.removeFromSuperViewOnHide = YES;
    
}
+(void)hideLoadingScreenFromView:(UIView*)view{
    
    [MBProgressHUD hideHUDForView:view animated:YES];
    
}

+(UIImage*)getThumbNailFromVideoURL:(NSURL*)url{
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    //  Get thumbnail at the very start of the video
    CMTime thumbnailTime = [asset duration];
    thumbnailTime.value = 0;
    //  Get image from the video at the given time
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = true;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return thumbnail;
}

+ (UIImage *)fixrotation:(UIImage *)image{
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

+(NSString*)getDateDescriptionForChat:(double)timeInSeconds{
    
    NSDate * today = [NSDate date];
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:refDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:today];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute
                                               fromDate:fromDate toDate:toDate options:0];
    
    NSString *msgDate;
    NSInteger days = [difference day];
    if (days > 7) {
        NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
        [dateformater setDateFormat:@"d MMM,yyyy"];
        msgDate = [dateformater stringFromDate:refDate];
    }
    else if (days <= 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        NSDate *date = refDate;
        msgDate = [dateFormatter stringFromDate:date];
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EE h:mm a"];
        msgDate = [dateFormatter stringFromDate:refDate];
    }
    
    return msgDate;
    
}


@end
