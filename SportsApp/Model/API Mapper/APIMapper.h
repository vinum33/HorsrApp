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

+ (void)registerUserWithName:(NSString*)userName userEmail:(NSString*)email phoneNumber:(NSString*)phone gender:(NSString*)gender location:(NSString*)location userPassword:(NSString*)password dialCode:(NSString*)dialCode success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)loginUserWithUserName:(NSString*)userName userPassword:(NSString*)password success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)forgotPasswordWithEmail:(NSString*)email success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)socialMediaRegistrationnWithFirstName:(NSString*)firstName profileImage:(NSString*)profileImg fbID:(NSString*)fbID googleID:(NSString*)googleID email:(NSString*)email phoneNumber:(NSString*)phoneNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)setPushNotificationTokenWithUserID:(NSString*)userID token:(NSString*)token success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getDashboardOnsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)saveUserLocationAndInterestWithUserID:(NSString*)userID latitude:(double)latitude longitude:(double)longitude city:(NSString*)city address:(NSString*)address interests:(NSArray*)interests success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)logoutFromAccount:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateProfileWithUserID:(NSString*)userID name:(NSString*)name statusMsg:(NSString*)statusMsg city:(NSString*)city gender:(NSInteger)gender mediaFileName:(NSString*)mediaName phoneNumber:(NSString*)phoneNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;


+ (void)getAllUserListWithPageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)searchUserNameWithText:(NSString*)text pageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)addFriendWithFriendID:(NSString*)friendID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateFriendRequestWithReqID:(NSString*)ReqID status:(NSInteger)status OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllNotificationsPageNumber:(NSInteger)pageno type:(NSInteger)type OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)clearAllNotificationsOnsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllMyFriendsPageNumber:(NSInteger)pageno onSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)searchFriendsNameWithText:(NSString*)text pageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)uploadGameMediasWith:(NSURL*)videoURL thumbnail:(UIImage*)thumbnail type:(NSString*)strType Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)createGameWithGameID:(NSString*)gameID gameType:(NSString*)gameType mediaFileName:(NSString*)mediaFileName thumbFileName:(NSString*)thumbFileName invites:(NSMutableArray*)invites statusMsg:(NSString*)statusMsg OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllGamesWithpageNumber:(NSInteger)pageno gameType:(NSInteger)gameType Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failuree;

+ (void)getPlayedGameDetailsWithGameID:(NSString*)gameID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getUserProfileWithUserID:(NSString*)userID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)changePasswordWithCurrentPwd:(NSString*)currentPWD newPWD:(NSString*)newPWD confirmPWD:(NSString*)confirmPWD success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllFriendRequestsWithpageNumber:(NSInteger)pageno Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateUserSettingsWithNotifyValue:(BOOL)notifyStatus inviteStatus:(BOOL)inviteStatus Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateGameRequestWithStatus:(NSInteger)status requestID:(NSString*)reqID Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getGameZoneDetailsWithGameID:(NSString*)gameID Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)submitGameWithGameID:(NSString*)gameID mediaFileName:(NSString*)mediaFileName thumbFileName:(NSString*)thumbFileName trickID:(NSString*)trickID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)verifyVideoWithTrickID:(NSString*)trickID status:(BOOL)status videoID:(NSString*)videoID gameID:(NSString*)gameID nextUserID:(NSString*)nextID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)deleteChatWithIDs:(NSArray*)ids success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;


+ (void)loadChatHistoryWithGameID:(NSString*)gameID toUserID:(NSString*)strToUserID page:(NSInteger)pageNo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;


+ (void)postChatMessageWithGameID:(NSString*)gameID toUserID:(NSString*)toUserID message:(NSString*)message success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)shareVideoWithVideoID:(NSString*)videoID location:(NSString*)location address:(NSString*)strAddress message:(NSString*)message frieds:(NSArray*)friends success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllSharedVideosWithPageNumber:(NSInteger)pageno OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)likeVideoWithVideoID:(NSString*)videoID type:(NSString*)type emojiCode:(NSInteger)emojiCode OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)deleteSharedVideoWithVideoID:(NSString*)videoID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)submitGameStatus:(NSString*)videoID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateGameStatusWithGameID:(NSString*)gameID statusMsg:(NSString*)statusMsg OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)syncContactsWith:(NSString*)json OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)loadAllCommentsWithCommunityID:(NSString*)communityID page:(NSInteger)pageNo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)postCommentWithCommunityID:(NSString*)communityID message:(NSString*)message success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)deleteCommentWithCommentID:(NSString*)commentID OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getChatListWithPageNumber:(NSInteger)pageno searchText:(NSString*)searchText OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllMembersInGroupWithGroupID:(NSString*)groupID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)replyToGameRequestWithMessage:(NSString*)status requestID:(NSString*)reqID Onsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

@end
