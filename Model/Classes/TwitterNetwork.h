//
//  TwitterNetwork.h
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "../SNSocialNetwork.h"

@interface TwitterNetwork : SNSocialNetwork

- (void)postMessage;

- (void)postMessage: (NSString *)aPost
               link: (NSString *)aLink;

- (void)postMessage: (NSString *)message;

@end
