//
//  User.h
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic,strong) NSString * userId;
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * email;
@property (nonatomic,strong) NSString * profileurl;
@property (nonatomic,strong) NSString * phoneNumber;
@property (nonatomic,strong) NSString * gender;
@property (nonatomic,strong) NSString * age;
@property (nonatomic,strong) NSString * regDate;
@property (nonatomic,strong) NSString * token;
@property (nonatomic,strong) NSString * location;

+ (User*)sharedManager;

@end
