 //
//  APIMapper.m
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kUnAuthorized           403

#import "APIMapper.h"
#import "Constants.h"

@implementation APIMapper

+ (void)registerUserWithName:(NSString*)userName userEmail:(NSString*)email phoneNumber:(NSString*)phone gender:(NSString*)gender location:(NSString*)location userPassword:(NSString*)password dialCode:(NSString*)dialCode success:(void (^)(AFHTTPRequestOperation *task, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@register",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"name": userName,
                             @"email": email,
                             @"phone": [NSString stringWithFormat:@"%@%@",dialCode,phone],
                             @"location": location,
                             @"gender": gender,
                             @"password": password,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

    
}

+ (void)socialMediaRegistrationnWithFirstName:(NSString*)firstName profileImage:(NSString*)profileImg fbID:(NSString*)fbID googleID:(NSString*)googleID email:(NSString*)email phoneNumber:(NSString*)phoneNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@socialmedia",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (email.length)[params setObject:email forKey:@"email"];
    if (profileImg.length)[params setObject:profileImg forKey:@"profileimg"];
    if (firstName.length)[params setObject:firstName forKey:@"firstname"];
    if (fbID.length)[params setObject:fbID forKey:@"fbid"];
    if (googleID.length)[params setObject:googleID forKey:@"googleid"];
    if (phoneNumber.length)[params setObject:phoneNumber forKey:@"phone"];
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
    
    
}


+ (void)loginUserWithUserName:(NSString*)userName userPassword:(NSString*)password success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@login",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"email": userName,
                             @"password": password,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
}
+ (void)forgotPasswordWithEmail:(NSString*)email success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@forgotpassword",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"email": email,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        failure (operation,error);
    }];
    

}


+ (void)saveUserLocationAndInterestWithUserID:(NSString*)userID latitude:(double)latitude longitude:(double)longitude city:(NSString*)city address:(NSString*)address interests:(NSArray*)interests success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    NSString *urlString = [NSString stringWithFormat:@"%@saveinterestandlocation",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:userID forKey:@"user_id"];
    if (latitude) [params setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    if (longitude) [params setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    if (city.length) [params setObject:city forKey:@"city"];
    if (address.length) [params setObject:address forKey:@"address"];
    if (interests.count) [params setObject:interests forKey:@"id"];
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
    
}
+ (void)logoutFromAccount:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@logout",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"user_id": userID,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure (operation,error);
    }];
    
}



+ (void)updateProfileWithUserID:(NSString*)userID name:(NSString*)name statusMsg:(NSString*)statusMsg city:(NSString*)city gender:(NSInteger)gender mediaFileName:(NSString*)mediaName phoneNumber:(NSString*)phoneNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@profile/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:userID forKey:@"user_id"];
    if (city.length > 0)[params setObject:city forKey:@"location"];
    if (name.length > 0)[params setObject:name forKey:@"name"];
    if (statusMsg.length > 0)[params setObject:statusMsg forKey:@"status_msg"];
    if (gender != 0)[params setObject:[NSNumber numberWithInteger:gender] forKey:@"gender"];
    if (mediaName.length)[params setObject:mediaName forKey:@"profileimg"];
    if (phoneNumber.length)[params setObject:phoneNumber forKey:@"phone"];
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    [manager PUT:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
    
    
}

+ (void)setPushNotificationTokenWithUserID:(NSString*)userID token:(NSString*)token success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@savedevice",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    if (userID.length > 0) {
        NSDictionary *params = @{@"user_id": userID,
                                 @"registration_id": token,
                                 @"device_os" : @"ios"
                                 };
        
        [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            success(operation,responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([operation.response statusCode] == kUnAuthorized) {
                AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [app logoutSinceUnAuthorized:operation.responseObject];
            }
            failure (operation,error);
        }];
    }
    
    
}


+ (void)updateProfileFromEditPageWithUserID:(NSString*)userID latitude:(double)latitude longitude:(double)longitude city:(NSString*)city locationAddress:(NSString*)locationAddress dateOfBirth:(double)dateOfBirth name:(NSString*)name status:(NSString*)status gallery:(NSMutableArray*)dataSource defaultImageIndex:(NSInteger)defaultImageIndex deletedID:(NSMutableArray*)deletedIDs success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@updateprofileIOS",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (latitude != 0)[params setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    if (longitude != 0)[params setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    if (city.length > 0)[params setObject:city forKey:@"city"];
    if (locationAddress.length > 0)[params setObject:locationAddress forKey:@"address"];
    if (dateOfBirth != 0)[params setObject:[NSNumber numberWithLong:dateOfBirth] forKey:@"dob"];
    if (name)[params setObject:name forKey:@"name"];
    if (status)[params setObject:status forKey:@"profile_info"];
    if (deletedIDs.count) {
        NSMutableArray *_deletedIDS = [NSMutableArray new];
        for (NSDictionary *dict in deletedIDs) [_deletedIDS addObject:[dict objectForKey:@"profilegallery_id"]];
        [params setObject:_deletedIDS forKey:@"deleted_id"];
    }
    UIImage *defaultImage;
    NSString *galleryID;
    if (defaultImageIndex < dataSource.count) {
        if ([[dataSource objectAtIndex:defaultImageIndex] isKindOfClass:[UIImage class]]) {
            defaultImage = [dataSource objectAtIndex:defaultImageIndex];
            [dataSource removeObjectAtIndex:defaultImageIndex];
        }else{
            
            NSDictionary *imageinfo = [dataSource objectAtIndex:defaultImageIndex];
            galleryID = [imageinfo objectForKey:@"profilegallery_id"];
            [params setObject:galleryID forKey:@"profilegallery_id"];
        }
    }
    NSInteger mediaCount = 0;
    for (id object in dataSource) {
        if ([object isKindOfClass:[UIImage class]]) {
            mediaCount ++;
        }
        
    }
    
    [params setObject:[NSNumber numberWithInteger:mediaCount] forKey:@"media_count"];
    
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    
    [manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSInteger index = 1;
        for (id object in dataSource) {
            if ([object isKindOfClass:[UIImage class]]) {
                UIImage *image = (UIImage*)object;
                NSData *imageData = UIImageJPEGRepresentation(image,0.1);
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"image/jpeg"];
                index ++;
            }
            
        }
        
        if (defaultImage) {
            NSData *imageData = UIImageJPEGRepresentation(defaultImage,0.1);
            [formData appendPartWithFileData:imageData name:@"default_image" fileName:@"Media" mimeType:@"image/jpeg"];
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
        
    }];
    
    
}

+ (void)getDashboardOnsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@dashboard",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
                AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];

}


+ (void)getAllUserListWithPageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@profile/list/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"pageno": [NSNumber numberWithInteger:pageno]
                             };
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];

}

+ (void)searchUserNameWithText:(NSString*)text pageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@profile/list/",BaseURLString];
    if (text.length) {
        urlString = [NSString stringWithFormat:@"%@profile/list/%@",BaseURLString,text];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"pageno": [NSNumber numberWithInteger:pageno]
                             };
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];

}

+ (void)addFriendWithFriendID:(NSString*)friendID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@friend/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"friend_id": friendID
                             };
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)updateFriendRequestWithReqID:(NSString*)ReqID status:(NSInteger)status OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@friend/request",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"request_id": ReqID,
                             @"status":[NSNumber numberWithInteger:status]
                             };
    [manager PUT:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)getAllNotificationsPageNumber:(NSInteger)pageno type:(NSInteger)type OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@notification",BaseURLString];
    if (type == 1) {
        urlString = [NSString stringWithFormat:@"%@game/request",BaseURLString];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"pageno": [NSNumber numberWithInteger:pageno]
                             };
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)clearAllNotificationsOnsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@notification",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    
    [manager DELETE:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            success(operation,responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if ([operation.response statusCode] == kUnAuthorized) {
                AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [app logoutSinceUnAuthorized:operation.responseObject];
            }
            failure (operation,error);
        }];
}


+ (void)getAllMyFriendsPageNumber:(NSInteger)pageno onSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@friend/list/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
}

+ (void)searchFriendsNameWithText:(NSString*)text pageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@friend/list/%@",BaseURLString,text];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"pageno": [NSNumber numberWithInteger:pageno]
                             };
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)uploadGameMediasWith:(NSURL*)videoURL thumbnail:(UIImage*)thumbnail type:(NSString*)strType Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@iosmediaupload",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"type": strType
                             };
    
    [manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if ([strType isEqualToString:@"video"]) {
            
            UIImage *image = thumbnail;
            NSData *imageData = UIImageJPEGRepresentation(image,0.1);
            [formData appendPartWithFileData:imageData name:@"thumb_file" fileName:@"Media" mimeType:@"image/jpeg"];
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:[videoURL path]];
            [formData appendPartWithFileData:data name:@"media_file" fileName:@"Media" mimeType:@"video/mp4"];
            
        }else{
            
            if (thumbnail) {
                UIImage *image = thumbnail;
                NSData *imageData = UIImageJPEGRepresentation(image,0.1);
                [formData appendPartWithFileData:imageData name:@"media_file" fileName:@"Media" mimeType:@"image/jpeg"];
            }
           
        }
       
        
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
        
    }];
    
    
}

+ (void)createGameWithGameID:(NSString*)gameID gameType:(NSString*)gameType mediaFileName:(NSString*)mediaFileName thumbFileName:(NSString*)thumbFileName invites:(NSMutableArray*)invites statusMsg:(NSString*)statusMsg OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (statusMsg.length > 0)[params setObject:statusMsg forKey:@"status_message"];
    if (gameID.length > 0)[params setObject:gameID forKey:@"game_id"];
    [params setObject:gameType forKey:@"gametype_id"];
    [params setObject:mediaFileName forKey:@"media_file"];
    [params setObject:thumbFileName forKey:@"thumb_file"];
    [params setObject:invites forKey:@"participants_id"];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)getAllGamesWithpageNumber:(NSInteger)pageno gameType:(NSInteger)gameType Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/list",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"pageno": [NSNumber numberWithInteger:pageno],
                             @"type": [NSNumber numberWithInteger:gameType]
                             };
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];

}

+ (void)getPlayedGameDetailsWithGameID:(NSString*)gameID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/%@",BaseURLString,gameID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)getUserProfileWithUserID:(NSString*)userID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@profile/%@",BaseURLString,userID];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
       [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)changePasswordWithCurrentPwd:(NSString*)currentPWD newPWD:(NSString*)newPWD confirmPWD:(NSString*)confirmPWD success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@changepassword",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    NSDictionary *params = @{@"user_id": [User sharedManager].userId,
                             @"old_pass": currentPWD,
                             @"new_pass": newPWD,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)getAllFriendRequestsWithpageNumber:(NSInteger)pageno Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@friend/request/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)updateUserSettingsWithNotifyValue:(BOOL)notifyStatus inviteStatus:(BOOL)inviteStatus mailStatus:(BOOL)mailStatus Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@settings",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"notify_status": [NSNumber numberWithBool:notifyStatus],
                             @"invite_status":  [NSNumber numberWithBool:inviteStatus],
                             @"mailnotify_status":  [NSNumber numberWithBool:mailStatus],
                             };

    [manager PUT:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];

}
+ (void)updateGameRequestWithStatus:(NSInteger)status requestID:(NSString*)reqID Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/request",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"request_id": reqID,
                             @"status":  [NSString stringWithFormat:@"%ld",(long)status],
                             };
    
    [manager PUT:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)replyToGameRequestWithMessage:(NSString*)status requestID:(NSString*)reqID Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/reply",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"request_id": reqID,
                             @"status_msg": status,
                             };
    
    [manager PUT:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)getGameZoneDetailsWithGameID:(NSString*)gameID Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/zone",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"game_id": gameID,
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];

}

+ (void)submitGameWithGameID:(NSString*)gameID mediaFileName:(NSString*)mediaFileName thumbFileName:(NSString*)thumbFileName trickID:(NSString*)trickID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/play",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"game_id": gameID,
                             @"media_file": mediaFileName,
                             @"thumb_file": thumbFileName,
                             @"trick_id": trickID,
                             };
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)verifyVideoWithTrickID:(NSString*)trickID status:(BOOL)status videoID:(NSString*)videoID gameID:(NSString*)gameID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/verify",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"game_id": gameID,
                             @"trick_id": trickID,
                             @"status": [NSNumber numberWithBool:status],
                             @"video_id": videoID,
                             };
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)postChatMessageWithGameID:(NSString*)gameID toUserID:(NSString*)toUserID message:(NSString*)message success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@chat/",BaseURLString];
    if (toUserID.length) {
        urlString = [NSString stringWithFormat:@"%@privatechat/",BaseURLString];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (gameID.length)[params setObject:gameID forKey:@"game_id"];
    if (toUserID.length)[params setObject:toUserID forKey:@"to_id"];
    if (message.length)[params setObject:message forKey:@"msg"];
    
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}



+ (void)loadChatHistoryWithGameID:(NSString*)gameID toUserID:(NSString*)strToUserID page:(NSInteger)pageNo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@chat/",BaseURLString];
    if (strToUserID.length) {
        urlString = [NSString stringWithFormat:@"%@privatechat/",BaseURLString];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (gameID.length)[params setObject:gameID forKey:@"game_id"];
    if (strToUserID.length)[params setObject:strToUserID forKey:@"to_id"];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageno"];

    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)deleteChatWithIDs:(NSArray*)ids success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@deletechat",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    NSDictionary *params = @{@"chat_ids": ids,
                             @"user_id": [User sharedManager].userId,
                             };
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)shareVideoWithVideoID:(NSString*)videoID location:(NSString*)location address:(NSString*)strAddress message:(NSString*)message frieds:(NSArray*)friends success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@share/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (videoID.length)[params setObject:videoID forKey:@"video_id"];
    if (location.length)[params setObject:location forKey:@"location_name"];
    if (strAddress.length)[params setObject:strAddress forKey:@"location_address"];
    if (message.length)[params setObject:message forKey:@"share_msg"];
    if (friends.count)[params setObject:friends forKey:@"tagged_user"];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)getAllSharedVideosWithPageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@share/list/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"pageno": [NSNumber numberWithInteger:pageno]
                             };
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)likeVideoWithVideoID:(NSString*)videoID type:(NSString*)type emojiCode:(NSInteger)emojiCode OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@like/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (videoID.length)[params setObject:videoID forKey:@"community_id"];
    if (type.length)[params setObject:type forKey:@"type"];
    [params setObject:[NSNumber numberWithInteger:emojiCode] forKey:@"emoji_code"];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];

}

+ (void)deleteSharedVideoWithVideoID:(NSString*)videoID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@share/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"community_id": videoID
                             };
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    [manager DELETE:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];

}

+ (void)updateGameStatusWithGameID:(NSString*)gameID statusMsg:(NSString*)statusMsg OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (statusMsg.length > 0)[params setObject:statusMsg forKey:@"status_message"];
    [params setObject:gameID forKey:@"game_id"];
    [manager PUT:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)syncContactsWith:(NSString*)json OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@contacts",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (json.length > 0)[params setObject:json forKey:@"contact_json"];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    

}

+ (void)loadAllCommentsWithCommunityID:(NSString*)communityID page:(NSInteger)pageNo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@comment",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (communityID.length)[params setObject:communityID forKey:@"community_id"];
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)postCommentWithCommunityID:(NSString*)communityID message:(NSString*)message success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@comment",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (message.length)[params setObject:message forKey:@"comment_txt"];
    if (communityID.length)[params setObject:communityID forKey:@"community_id"];
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)deleteCommentWithCommentID:(NSString*)commentID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@comment",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"comment_id": commentID
                             };
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    [manager DELETE:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}


+ (void)getChatListWithPageNumber:(NSInteger)pageno searchText:(NSString*)searchText OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@privatechat/list/",BaseURLString];
    if (searchText.length) urlString = [NSString stringWithFormat:@"%@privatechat/list/%@",BaseURLString,searchText];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"pageno": [NSNumber numberWithInteger:pageno]
                             };
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)getAllMembersInGroupWithGroupID:(NSString*)groupID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@chat/list",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:groupID forKey:@"game_id"];
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)getAllGameRequetsOnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/request",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"type": @"gamerequest"
                             };
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)getStatisticsWithUserID:(NSString*)userID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;{
    
    NSString *urlString = [NSString stringWithFormat:@"%@stats",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"user_id": userID
                             };
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}

+ (void)getCommentedAndLikedUsersWithType:(NSInteger)type communityID:(NSString*)strCommunityID onSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    NSString *strType = @"comment";
    if (type == 1) {
        strType = @"like";
    }
    NSString *urlString = [NSString stringWithFormat:@"%@users/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    NSDictionary *params = @{@"type": strType,
                             @"community_id": strCommunityID
                             };

    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
}

+ (void)getNotificationDetailPageWithID:(NSString*)pageID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@community",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"community_id": pageID
                             };
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];
    
}
+ (void)exitGameWithGameID:(NSString*)gameID trickID:(NSString*)trickID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/exit",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"game_id": gameID,
                             @"trick_id": trickID
                             
                             };
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];

    
}

+ (void)continueGameBy:(NSString*)gameID userID:(NSString*)userID trickID:(NSString*)trickID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/skip",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"game_id": gameID,
                             @"user_id": userID,
                              @"trick_id": trickID,
                             };
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([operation.response statusCode] == kUnAuthorized) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app logoutSinceUnAuthorized:operation.responseObject];
        }
        failure (operation,error);
    }];

    
}
@end
