//
//  TwitterNetwork.h
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "../SNSocialNetwork.h"
#import "TwitterVC.h"

@interface TwitterNetwork : SNSocialNetwork <TwitterDelegate>

- (void)postMessage;

- (void)postMessage: (NSString *)aPost
               link: (NSString *)aLink;

- (void)postMessage: (NSString *)message;

@end
