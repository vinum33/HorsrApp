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

+ (void)registerUserWithName:(NSString*)userName userEmail:(NSString*)email phoneNumber:(NSString*)phone gender:(NSString*)gender location:(NSString*)location userPassword:(NSString*)password success:(void (^)(AFHTTPRequestOperation *task, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@register",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"name": userName,
                             @"email": email,
                             @"mobile": phone,
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

+ (void)socialMediaRegistrationnWithFirstName:(NSString*)firstName profileImage:(NSString*)profileImg fbID:(NSString*)fbID googleID:(NSString*)googleID email:(NSString*)email gender:(NSString*)gender dob:(long)dob success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@socialmedia",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (email.length)[params setObject:email forKey:@"email"];
    if (profileImg.length)[params setObject:profileImg forKey:@"profileimg"];
    if (firstName.length)[params setObject:firstName forKey:@"firstname"];
    if (fbID.length)[params setObject:fbID forKey:@"fbid"];
    if (googleID.length)[params setObject:googleID forKey:@"googleid"];
    if (gender.length)[params setObject:gender forKey:@"gender"];
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



+ (void)updateProfileWithUserID:(NSString*)userID name:(NSString*)name statusMsg:(NSString*)statusMsg city:(NSString*)city gender:(NSInteger)gender mediaFileName:(NSString*)mediaName success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@profile/list/%@",BaseURLString,text];
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

+ (void)getAllNotificationsPageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@notification",BaseURLString];
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

+ (void)createGameWithGameID:(NSString*)gameID gameType:(NSString*)gameType mediaFileName:(NSString*)mediaFileName thumbFileName:(NSString*)thumbFileName invites:(NSMutableArray*)invites OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"game_id": gameID,
                             @"gametype_id": gameType,
                             @"media_file": mediaFileName,
                             @"thumb_file": thumbFileName,
                             @"participants_id": invites
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

+ (void)getAllGamesWithpageNumber:(NSInteger)pageno Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@game/list",BaseURLString];
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

+ (void)updateUserSettingsWithNotifyValue:(BOOL)notifyStatus inviteStatus:(BOOL)inviteStatus Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@settings",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];;
    if ( [User sharedManager].token) {
        [manager.requestSerializer setValue:[User sharedManager].token forHTTPHeaderField:@"Authorization"];
    }
    NSDictionary *params = @{@"notify_status": [NSNumber numberWithBool:notifyStatus],
                             @"invite_status":  [NSNumber numberWithBool:inviteStatus],
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



@end
