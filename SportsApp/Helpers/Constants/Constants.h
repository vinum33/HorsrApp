//
//  Utility.h
//  SignSpot
//
//  Created by Purpose Code on 09/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })

extern NSString * const StoryboardForSlider;
extern NSString * const StoryboardForLogin;
extern NSString * const GeneralStoryBoard;

extern NSString * const CommonFont;
extern NSString * const CommonFontBold;
extern NSString * const BaseURLString;
extern NSString * const ExternalWebURL;
extern NSString * const UploadedImageURL;
extern NSString * const AppStoreURL;
extern NSString * const GoogleMapAPIKey;
extern NSString * const PROJECT_NAME;


extern NSString * const StoryBoardIdentifierForLoginPage;
extern NSString * const StoryBoardIdentifierForRegistrationPage;
extern NSString * const StoryBoardIdentifierForMenuPage ;
extern NSString * const StoryBoardIdentifierForHomePage ;
extern NSString * const StoryBoardIdentifierForWelcome;
extern NSString * const StoryBoardIdentifierForLocationDisplayWindow;

extern NSString * const StoryBoardIdentifierForListGames;
extern NSString * const StoryBoardIdentifierForCreateGame;
extern NSString * const StoryBoardIdentifierForSharedVideos;
extern NSString * const StoryBoardIdentifierForSearchFriends;
extern NSString * const StoryBoardIdentifierForProfile;
extern NSString * const StoryBoardIdentifierForSettings;
extern NSString * const StoryBoardIdentifierForInvitedGames;
extern NSString * const StoryBoardIdentifierForPlayedGameDetail;
extern NSString * const StoryBoardIdentifierForPlayedGameZone;
extern NSString * const StoryBoardIdentifierForScoreBoard;
extern NSString * const StoryBoardIdentifierForShareGame;
extern NSString * const StoryBoardIdentifierForNotifications;
extern NSString * const StoryBoardIdentifierForChatComposer;
extern NSString * const StoryBoardIdentifierForInviteOthers;
extern NSString * const StoryBoardIdentifierForContactPicker;

