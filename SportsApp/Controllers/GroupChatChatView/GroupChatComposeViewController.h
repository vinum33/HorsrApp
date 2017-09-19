//
//  ChatComposeViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatComposeViewController : UIViewController

@property (nonatomic,strong) NSString *strGameID;
@property (nonatomic,strong) NSString *strChatCount;

-(void)newChatHasReceivedWithDetails:(NSDictionary*)details;

@end
