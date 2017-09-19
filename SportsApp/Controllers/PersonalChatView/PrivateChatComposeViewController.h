//
//  ChatComposeViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivateChatComposeViewController : UIViewController

@property (nonatomic,strong) NSString *strUserID;
@property (nonatomic,strong) NSString *strUserName;

-(void)newChatHasReceivedWithDetails:(NSDictionary*)details;

@end
