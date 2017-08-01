//
//  UIColor+Color.m
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "UIColor+Color.h"

@implementation UIColor (Color)



+ (UIColor*)getThemeColor{
    
    return [UIColor colorWithRed:1.00 green:0.51 blue:0.16 alpha:1.0];
}
+ (UIColor*)getSeperatorColor{
    
     return [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];;
}

+ (UIColor*)getBorderColor{
    
    return [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
}

+ (UIColor*)getBackgroundOffWhiteColor{
    
    return [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:244.f/255.f alpha:1];
}
+ (UIColor*)getHeaderOffBlackColor{
    
    return [UIColor colorWithRed:77.f/255.f green:77.f/255.f blue:77.f/255.f alpha:1];
}

+ (UIColor*)getBlackTextColor{
    
    return [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1.0];
}

@end
