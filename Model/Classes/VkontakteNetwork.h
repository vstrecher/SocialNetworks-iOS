//
//  VkontakteNetwork.h
//  MTSSharing
//
//  Created by Dymov Eugene on 08.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "../SNSocialNetwork.h"
#import "VkontakteVCDelegate.h"

@interface VkontakteNetwork : SNSocialNetwork <VkontakteVCDelegate> {
    BOOL _isCaptcha, _isAuth;

}
- (BOOL)isLogged;
- (void)login;
- (void)logout;

- (void)showAuthViewController;

- (void)hideAuthViewController;

- (void)postMessage;

- (void)postMessage: (NSString *)vkMessage
               link: (NSString *)vkLink;

- (void)postMessage: (NSString *)vkMessage
               link: (NSString *)vkLink
            picture: (NSString *)vkPicture;


@end
