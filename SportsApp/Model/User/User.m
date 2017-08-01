//
//  User.m
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "User.h"

@implementation User

+(User*)sharedManager {
    
    static User *currentUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentUser = [[self alloc] init];
    });
    return currentUser;
    
}


- (User*)init {
    if ( (self = [super init]) ) {
        // your custom initialization
        self.userId = [NSString new];
        self.name = [NSString new];
        self.email = [NSString new];
        self.gender = [NSString new];
        self.age = [NSString new];
        self.profileurl = [NSString new];
        self.regDate = [NSString new];
        self.phoneNumber = [NSString new];
        self.token = [NSString new];
        self.location = [NSString new];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.userId forKey:@"userID"];
    [encoder encodeObject:self.name forKey:@"Name"];
    [encoder encodeObject:self.email forKey:@"Email"];
    [encoder encodeObject:self.regDate forKey:@"RegDate"];
    [encoder encodeObject:self.profileurl forKey:@"ProfileURL"];
    [encoder encodeObject:self.phoneNumber forKey:@"PhoneNumber"];
    [encoder encodeObject:self.age forKey:@"Age"];
    [encoder encodeObject:self.gender forKey:@"Gender"];
    [encoder encodeObject:self.token forKey:@"Token"];
    [encoder encodeObject:self.location forKey:@"Location"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.userId = [decoder decodeObjectForKey:@"userID"];
        self.name = [decoder decodeObjectForKey:@"Name"];
        self.email = [decoder decodeObjectForKey:@"Email"];
        self.regDate = [decoder decodeObjectForKey:@"RegDate"];
        self.profileurl = [decoder decodeObjectForKey:@"ProfileURL"];
        self.phoneNumber = [decoder decodeObjectForKey:@"PhoneNumber"];
        self.age = [decoder decodeObjectForKey:@"Age"];
        self.gender = [decoder decodeObjectForKey:@"Gender"];
        self.token = [decoder decodeObjectForKey:@"Token"];
        self.location = [decoder decodeObjectForKey:@"Location"];
    }
    return self;
}

@end
