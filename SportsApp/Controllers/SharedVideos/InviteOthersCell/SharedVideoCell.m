//
//  InviteOthersCell.m
//  SportsApp
//
//  Created by Purpose Code on 19/07/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "SharedVideoCell.h"

@implementation SharedVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _imgUser.clipsToBounds = YES;
    _imgUser.layer.cornerRadius = 25.f;
    _imgUser.layer.borderWidth = 1.f;
    _imgUser.backgroundColor = [UIColor whiteColor];
    _imgUser.layer.borderColor = [UIColor clearColor].CGColor;
    
    _lblDescription.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        // Open URLs
        [self attemptOpenURL:[NSURL URLWithString:string]];
    };
    
    

    // Initialization code
}

- (void)attemptOpenURL:(NSURL *)url
{
    
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (!safariCompatible) {
        
        NSString *urlString = url.absoluteString;
        urlString = [NSString stringWithFormat:@"http://%@",url.absoluteString];
        url = [NSURL URLWithString:urlString];
        
    }
    safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problem"
                                                        message:@"The selected link cannot be opened."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
