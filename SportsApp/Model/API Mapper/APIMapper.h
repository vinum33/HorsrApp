//
//  APIMapper.h
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface APIMapper : NSObject

+ (void)registerUserWithName:(NSString*)userName userEmail:(NSString*)email phoneNumber:(NSString*)phone gender:(NSString*)gender location:(NSString*)location userPassword:(NSString*)password success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)loginUserWithUserName:(NSString*)userName userPassword:(NSString*)password success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)forgotPasswordWithEmail:(NSString*)email success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)socialMediaRegistrationnWithFirstName:(NSString*)firstName profileImage:(NSString*)profileImg fbID:(NSString*)fbID googleID:(NSString*)googleID email:(NSString*)email gender:(NSString*)gender dob:(long)dob success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)setPushNotificationTokenWithUserID:(NSString*)userID token:(NSString*)token success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getDashboardOnsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)saveUserLocationAndInterestWithUserID:(NSString*)userID latitude:(double)latitude longitude:(double)longitude city:(NSString*)city address:(NSString*)address interests:(NSArray*)interests success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)logoutFromAccount:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateProfileWithUserID:(NSString*)userID name:(NSString*)name statusMsg:(NSString*)statusMsg city:(NSString*)city gender:(NSInteger)gender mediaFileName:(NSString*)mediaName success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateProfileFromEditPageWithUserID:(NSString*)userID latitude:(double)latitude longitude:(double)longitude city:(NSString*)city locationAddress:(NSString*)locationAddress dateOfBirth:(double)dateOfBirth name:(NSString*)name status:(NSString*)status gallery:(NSMutableArray*)dataSource defaultImageIndex:(NSInteger)defaultImageIndex deletedID:(NSMutableArray*)deletedIDs success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllUserListWithPageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)searchUserNameWithText:(NSString*)text pageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)addFriendWithFriendID:(NSString*)friendID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateFriendRequestWithReqID:(NSString*)ReqID status:(NSInteger)status OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllNotificationsPageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)clearAllNotificationsOnsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllMyFriendsPageNumber:(NSInteger)pageno onSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)searchFriendsNameWithText:(NSString*)text pageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)uploadGameMediasWith:(NSURL*)videoURL thumbnail:(UIImage*)thumbnail type:(NSString*)strType Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)createGameWithGameID:(NSString*)gameID gameType:(NSString*)gameType mediaFileName:(NSString*)mediaFileName thumbFileName:(NSString*)thumbFileName invites:(NSMutableArray*)invites OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllGamesWithpageNumber:(NSInteger)pageno Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getPlayedGameDetailsWithGameID:(NSString*)gameID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getUserProfileWithUserID:(NSString*)userID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)changePasswordWithCurrentPwd:(NSString*)currentPWD newPWD:(NSString*)newPWD confirmPWD:(NSString*)confirmPWD success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllFriendRequestsWithpageNumber:(NSInteger)pageno Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateUserSettingsWithNotifyValue:(BOOL)notifyStatus inviteStatus:(BOOL)inviteStatus Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateGameRequestWithStatus:(NSInteger)status requestID:(NSString*)reqID Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

@end
